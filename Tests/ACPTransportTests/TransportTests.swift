import Foundation
import Testing
import ACPCore
import ACPAgent
import ACPClient
@testable import ACPTransport

private enum TestError: Error { case unused }

/// An agent that, on `prompt`, streams two message chunks back through its
/// client and then ends the turn. Every other method is unused by these tests.
private final class StreamingAgent: ACPAgent, @unchecked Sendable {
    let client: any ACPClient
    init(client: any ACPClient) { self.client = client }

    func prompt(_ request: PromptRequest) async throws -> PromptResponse {
        for text in ["hello", "world"] {
            try await client.sessionUpdate(SessionNotification(
                sessionId: request.sessionId,
                update: .agentMessageChunk(ContentChunk(content: .text(TextContent(text: text))))
            ))
        }
        return PromptResponse(stopReason: .endTurn)
    }

    func initialize(_ request: InitializeRequest) async throws -> InitializeResponse { throw TestError.unused }
    func authenticate(_ request: AuthenticateRequest) async throws -> AuthenticateResponse { throw TestError.unused }
    func newSession(_ request: NewSessionRequest) async throws -> NewSessionResponse { throw TestError.unused }
    func loadSession(_ request: LoadSessionRequest) async throws -> LoadSessionResponse { throw TestError.unused }
    func listSessions(_ request: ListSessionsRequest) async throws -> ListSessionsResponse { throw TestError.unused }
    func resumeSession(_ request: ResumeSessionRequest) async throws -> ResumeSessionResponse { throw TestError.unused }
    func deleteSession(_ request: DeleteSessionRequest) async throws -> DeleteSessionResponse { throw TestError.unused }
    func closeSession(_ request: CloseSessionRequest) async throws -> CloseSessionResponse { throw TestError.unused }
    func setSessionMode(_ request: SetSessionModeRequest) async throws -> SetSessionModeResponse { throw TestError.unused }
    func setSessionConfigOption(_ request: SetSessionConfigOptionRequest) async throws -> SetSessionConfigOptionResponse { throw TestError.unused }
    func cancel(_ notification: CancelNotification) async throws {}
    func logout(_ request: LogoutRequest) async throws -> LogoutResponse { throw TestError.unused }
    func ext(_ request: ExtRequest) async throws -> ExtResponse { throw TestError.unused }
    func extNotification(_ notification: ExtNotification) async throws {}
}

/// A paired in-memory frame transport: whatever one side sends, the other reads.
private final class InMemoryTransport: ACPMessageTransport, @unchecked Sendable {
    private let inbound: AsyncStream<Data>
    private let outbound: AsyncStream<Data>.Continuation

    private init(inbound: AsyncStream<Data>, outbound: AsyncStream<Data>.Continuation) {
        self.inbound = inbound
        self.outbound = outbound
    }

    func send(_ frame: Data) async throws { outbound.yield(frame) }

    func messages() -> AsyncThrowingStream<Data, any Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                for await frame in inbound { continuation.yield(frame) }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    static func pair() -> (InMemoryTransport, InMemoryTransport) {
        var a: AsyncStream<Data>.Continuation!
        let aStream = AsyncStream<Data> { a = $0 }
        var b: AsyncStream<Data>.Continuation!
        let bStream = AsyncStream<Data> { b = $0 }
        return (InMemoryTransport(inbound: aStream, outbound: b),
                InMemoryTransport(inbound: bStream, outbound: a))
    }
}

@Suite("Transport")
struct TransportTests {
    @Test func inProcessStreamsUpdatesWithoutSerialization() async throws {
        let connection = InProcessConnection { client in StreamingAgent(client: client) }
        let collector = Task {
            var updates: [SessionNotification] = []
            for await update in connection.updates { updates.append(update) }
            return updates
        }

        let response = try await connection.agent.prompt(
            PromptRequest(sessionId: "s1", prompt: [.text(TextContent(text: "hi"))])
        )
        connection.finish()

        #expect(response.stopReason == .endTurn)
        let updates = await collector.value
        #expect(updates.count == 2)
        #expect(updates.map(\.sessionId) == ["s1", "s1"])
    }

    @Test func codecClassifiesFrames() throws {
        let codec = JSONRPCCodec()

        let request = try codec.decode(try codec.encodeRequest(id: .number(7), method: "session/prompt", params: .null))
        guard case let .request(id, method, _) = request else { Issue.record("expected request"); return }
        #expect(id == .number(7))
        #expect(method == "session/prompt")

        let note = try codec.decode(try codec.encodeNotification(method: "session/update", params: .null))
        guard case let .notification(noteMethod, _) = note else { Issue.record("expected notification"); return }
        #expect(noteMethod == "session/update")

        let ok = try codec.decode(try codec.encodeSuccess(id: .number(7), result: .string("done")))
        guard case let .success(okId, result) = ok else { Issue.record("expected success"); return }
        #expect(okId == .number(7))
        #expect(result == .string("done"))

        let bad = try codec.decode(try codec.encodeFailure(id: .number(7), error: RPCError(code: .methodNotFound, message: "no")))
        guard case let .failure(badId, error) = bad else { Issue.record("expected failure"); return }
        #expect(badId == .number(7))
        #expect(error.code == .methodNotFound)
    }

    @Test func agentConnectionServesPromptOverTransport() async throws {
        let (agentTransport, clientTransport) = InMemoryTransport.pair()
        let connection = AgentConnection(transport: agentTransport)
        await connection.start { client in StreamingAgent(client: client) }
        let loop = Task { try await connection.run() }
        defer { loop.cancel() }

        let codec = JSONRPCCodec()
        let params = try codec.value(PromptRequest(sessionId: "s1", prompt: [.text(TextContent(text: "hi"))]))
        try await clientTransport.send(
            try codec.encodeRequest(id: .number(1), method: ACPMethod.Agent.sessionPrompt, params: params)
        )

        var updates = 0
        var stopReason: StopReason?
        for try await frame in clientTransport.messages() {
            switch try codec.decode(frame) {
            case let .notification(method, _) where method == ACPMethod.Client.sessionUpdate:
                updates += 1
            case let .success(id, result) where id == .number(1):
                stopReason = try codec.decodePayload(PromptResponse.self, from: result).stopReason
            default:
                break
            }
            if stopReason != nil { break }
        }

        #expect(updates == 2)
        #expect(stopReason == .endTurn)
    }
}
