import Foundation
import ACPCore
import ACPAgent
import ACPClient

/// Serves an `ACPAgent` over a JSON-RPC frame transport: it decodes incoming
/// client requests/notifications by method, dispatches them to the agent, and
/// sends back responses. The agent is handed a `RemoteClient` whose calls
/// (`session/update`, `session/request_permission`, `fs/*`, `terminal/*`) are
/// marshalled back over the same transport.
///
/// This is the serialized counterpart to `InProcessConnection` — the same agent
/// contract, reachable by any ACP client over stdio.
public actor AgentConnection {
    private let transport: any ACPMessageTransport
    private let codec = JSONRPCCodec()
    private var agent: (any ACPAgent)?
    private var nextId = 0
    private var pending: [String: CheckedContinuation<JSONValue, any Error>] = [:]

    public init(transport: any ACPMessageTransport) {
        self.transport = transport
    }

    /// Wire up the agent before starting the read loop.
    ///
    /// Call this once before `run()`. The `makeAgent` closure receives the
    /// `RemoteClient` the agent should use to send `session/update`
    /// notifications and make `fs/*`/`terminal/*` requests back to the client.
    ///
    /// - Parameter makeAgent: A closure that returns the concrete `ACPAgent`
    ///   implementation, bound to the provided client proxy.
    public func start(makeAgent: (any ACPClient) -> any ACPAgent) {
        agent = makeAgent(RemoteClient(connection: self))
    }

    /// Run the read/dispatch loop until the transport closes or throws.
    ///
    /// Reads frames from the transport, classifies each one, and dispatches it
    /// to the agent (for client → agent requests/notifications) or resolves a
    /// pending continuation (for agent → client responses). When the transport
    /// ends, all outstanding pending requests are cancelled with
    /// `ACPTransportError.closed`.
    ///
    /// Call `start(makeAgent:)` before calling `run()`.
    public func run() async throws {
        for try await frame in transport.messages() {
            let classified = try codec.decode(frame)
            Task { await self.handle(classified) }
        }
        for (_, continuation) in pending { continuation.resume(throwing: ACPTransportError.closed) }
        pending.removeAll()
    }

    private func key(for id: RequestId) -> String {
        switch id {
        case .null: "null"
        case let .number(n): "n\(n)"
        case let .string(s): "s\(s)"
        }
    }

    private func handle(_ frame: JSONRPCFrame) async {
        switch frame {
        case let .request(id, method, params):
            await respond(to: id, method: method, params: params)
        case let .notification(method, params):
            await notify(method: method, params: params)
        case let .success(id, result):
            pending.removeValue(forKey: key(for: id))?.resume(returning: result)
        case let .failure(id, error):
            pending.removeValue(forKey: key(for: id))?.resume(throwing: error)
        }
    }

    // MARK: - Inbound (client → agent)

    private func respond(to id: RequestId, method: String, params: JSONValue?) async {
        guard let agent else { return }
        do {
            let result = try await dispatch(agent, method: method, params: params)
            try await transport.send(try codec.encodeSuccess(id: id, result: result))
        } catch {
            let rpcError = (error as? RPCError) ?? RPCError(code: .internalError, message: "\(error)")
            if let data = try? codec.encodeFailure(id: id, error: rpcError) {
                try? await transport.send(data)
            }
        }
    }

    private func dispatch(_ agent: any ACPAgent, method: String, params: JSONValue?) async throws -> JSONValue {
        func decode<T: Decodable>(_ type: T.Type) throws -> T { try codec.decodePayload(type, from: params) }
        switch method {
        case ACPMethod.Agent.initialize:
            return try codec.jsonValue(from: try await agent.initialize(decode(InitializeRequest.self)))
        case ACPMethod.Agent.authenticate:
            return try codec.jsonValue(from: try await agent.authenticate(decode(AuthenticateRequest.self)))
        case ACPMethod.Agent.logout:
            return try codec.jsonValue(from: try await agent.logout(decode(LogoutRequest.self)))
        case ACPMethod.Agent.sessionNew:
            return try codec.jsonValue(from: try await agent.newSession(decode(NewSessionRequest.self)))
        case ACPMethod.Agent.sessionLoad:
            return try codec.jsonValue(from: try await agent.loadSession(decode(LoadSessionRequest.self)))
        case ACPMethod.Agent.sessionList:
            return try codec.jsonValue(from: try await agent.listSessions(decode(ListSessionsRequest.self)))
        case ACPMethod.Agent.sessionDelete:
            return try codec.jsonValue(from: try await agent.deleteSession(decode(DeleteSessionRequest.self)))
        case ACPMethod.Agent.sessionResume:
            return try codec.jsonValue(from: try await agent.resumeSession(decode(ResumeSessionRequest.self)))
        case ACPMethod.Agent.sessionClose:
            return try codec.jsonValue(from: try await agent.closeSession(decode(CloseSessionRequest.self)))
        case ACPMethod.Agent.sessionSetMode:
            return try codec.jsonValue(from: try await agent.setSessionMode(decode(SetSessionModeRequest.self)))
        case ACPMethod.Agent.sessionSetConfigOption:
            return try codec.jsonValue(from: try await agent.setSessionConfigOption(decode(SetSessionConfigOptionRequest.self)))
        case ACPMethod.Agent.sessionPrompt:
            return try codec.jsonValue(from: try await agent.prompt(decode(PromptRequest.self)))
        default:
            let response = try await agent.ext(ExtRequest(method: method, params: params ?? .null))
            return response.params
        }
    }

    private func notify(method: String, params: JSONValue?) async {
        guard let agent else { return }
        do {
            switch method {
            case ACPMethod.Agent.sessionCancel:
                try await agent.cancel(codec.decodePayload(CancelNotification.self, from: params))
            default:
                try await agent.extNotification(ExtNotification(method: method, params: params ?? .null))
            }
        } catch {
            // Notifications have no reply; surface nothing.
        }
    }

    // MARK: - Outbound (agent → client), used by RemoteClient

    fileprivate func request(method: String, params: JSONValue?) async throws -> JSONValue {
        let id = nextId
        nextId += 1
        let frameKey = "n\(id)"
        let data = try codec.encodeRequest(id: .number(Int64(id)), method: method, params: params)
        return try await withCheckedThrowingContinuation { continuation in
            pending[frameKey] = continuation
            Task { await self.deliver(data, key: frameKey) }
        }
    }

    private func deliver(_ data: Data, key: String) async {
        do {
            try await transport.send(data)
        } catch {
            pending.removeValue(forKey: key)?.resume(throwing: error)
        }
    }

    fileprivate func notification(method: String, params: JSONValue?) async throws {
        try await transport.send(try codec.encodeNotification(method: method, params: params))
    }
}

/// The client proxy an agent talks to when served over a transport. Each call
/// is marshalled to a JSON-RPC request/notification on the `AgentConnection`.
private struct RemoteClient: ACPClient {
    let connection: AgentConnection
    private let codec = JSONRPCCodec()

    private func call<Response: Decodable>(
        _ method: String,
        _ request: some Encodable,
        as _: Response.Type
    ) async throws -> Response {
        let result = try await connection.request(method: method, params: try codec.jsonValue(from: request))
        return try codec.decodePayload(Response.self, from: result)
    }

    func requestPermission(_ request: RequestPermissionRequest) async throws -> RequestPermissionResponse {
        try await call(ACPMethod.Client.sessionRequestPermission, request, as: RequestPermissionResponse.self)
    }
    func writeTextFile(_ request: WriteTextFileRequest) async throws -> WriteTextFileResponse {
        try await call(ACPMethod.Client.fsWriteTextFile, request, as: WriteTextFileResponse.self)
    }
    func readTextFile(_ request: ReadTextFileRequest) async throws -> ReadTextFileResponse {
        try await call(ACPMethod.Client.fsReadTextFile, request, as: ReadTextFileResponse.self)
    }
    func createTerminal(_ request: CreateTerminalRequest) async throws -> CreateTerminalResponse {
        try await call(ACPMethod.Client.terminalCreate, request, as: CreateTerminalResponse.self)
    }
    func terminalOutput(_ request: TerminalOutputRequest) async throws -> TerminalOutputResponse {
        try await call(ACPMethod.Client.terminalOutput, request, as: TerminalOutputResponse.self)
    }
    func releaseTerminal(_ request: ReleaseTerminalRequest) async throws -> ReleaseTerminalResponse {
        try await call(ACPMethod.Client.terminalRelease, request, as: ReleaseTerminalResponse.self)
    }
    func waitForTerminalExit(_ request: WaitForTerminalExitRequest) async throws -> WaitForTerminalExitResponse {
        try await call(ACPMethod.Client.terminalWaitForExit, request, as: WaitForTerminalExitResponse.self)
    }
    func killTerminal(_ request: KillTerminalRequest) async throws -> KillTerminalResponse {
        try await call(ACPMethod.Client.terminalKill, request, as: KillTerminalResponse.self)
    }
    func sessionUpdate(_ notification: SessionNotification) async throws {
        try await connection.notification(method: ACPMethod.Client.sessionUpdate, params: try codec.jsonValue(from: notification))
    }
    func ext(_ request: ExtRequest) async throws -> ExtResponse {
        ExtResponse(params: try await connection.request(method: request.method, params: request.params))
    }
    func extNotification(_ notification: ExtNotification) async throws {
        try await connection.notification(method: notification.method, params: notification.params)
    }
}
