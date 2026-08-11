import Foundation
import ACPCore
import ACPAgent
import ACPClient

/// Serves an `ACPAgent` over a frame transport, and gives that agent a client proxy pointing back
/// down the same connection.
///
/// The serialized counterpart of `InProcessConnection`: the same agent contract, reached over
/// stdio. Incoming requests and notifications are decoded by method name and dispatched; the
/// agent's own calls — updates, permission requests, file-system and terminal work — are marshalled
/// back out as JSON-RPC.
///
/// - Important: Frames are dispatched on independent tasks, so **handling order is not the order
///   they arrived in**. Two notifications sent back to back may be processed in either order. An
///   agent that depends on ordering must impose it itself.
///
/// A frame that fails to decode ends `run()` by throwing, and the pending-request cleanup that
/// follows the read loop does not run in that case — outstanding calls stay suspended.
public actor AgentConnection {
    private let transport: any ACPMessageTransport
    private let codec = JSONRPCCodec()
    private var agent: (any ACPAgent)?
    private var nextId = 0
    private var pending: [String: CheckedContinuation<JSONValue, any Error>] = [:]

    public init(transport: any ACPMessageTransport) {
        self.transport = transport
    }

    /// Installs the agent. Call once, before `run()`.
    ///
    /// Without it, incoming requests are dropped without an answer — the caller waits forever
    /// rather than receiving an error.
    ///
    /// - Parameter makeAgent: Builds the agent, receiving the client proxy it should report
    ///   through. Every call on that proxy is marshalled over this connection.
    public func start(makeAgent: (any ACPClient) -> any ACPAgent) {
        agent = makeAgent(RemoteClient(connection: self))
    }

    /// Reads and dispatches until the transport closes or fails.
    ///
    /// Each frame is either dispatched to the agent — for an inbound request or notification — or
    /// used to resolve a call the agent made. On a clean close, every outstanding call fails with
    /// `ACPTransportError.closed`.
    ///
    /// Dispatch is fire-and-forget: each frame gets its own task, so handling may overlap and may
    /// complete out of order. Only the reading is sequential.
    ///
    /// - Throws: Whatever the transport throws, and a decoding error if a frame is malformed. In
    ///   the throwing cases outstanding calls are left suspended rather than failed.
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

/// The client an agent sees when it is served over a transport. Every call becomes an outbound
/// JSON-RPC request or notification on the connection.
///
/// Requests carry a monotonically increasing numeric id and suspend until the matching response
/// arrives; there is no timeout, so a peer that never answers leaves the call suspended until the
/// transport closes.
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
