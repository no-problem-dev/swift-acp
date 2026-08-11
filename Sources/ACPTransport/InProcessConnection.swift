import ACPCore
import ACPAgent
import ACPClient

/// Runs an agent and its host in one process, with nothing serialized.
///
/// The host drives the agent through the `ACPAgent` protocol directly and reads its progress from
/// an `AsyncStream`; no JSON-RPC frame is ever built. Because the messages never round-trip through
/// JSON, this path does not exercise the wire format — a payload that would fail to encode passes
/// unnoticed here. Moving to a real agent later is a change of connection and nothing else.
///
/// ```swift
/// let connection = InProcessConnection { client in
///     MyResearchAgent(client: client)   // the agent reports progress through `client`
/// }
/// Task {
///     for await update in connection.updates { render(update) }
/// }
/// _ = try await connection.agent.prompt(promptRequest)
/// connection.finish()
/// ```
public struct InProcessConnection: Sendable {
    /// The agent, called directly through its protocol.
    public let agent: any ACPAgent

    /// The client the agent was handed, which is what turns its reports into the update stream.
    public let client: StreamingSessionClient

    /// The agent's updates, in the order it published them. Buffers without bound; finishes only
    /// when `finish()` is called.
    public var updates: AsyncStream<SessionNotification> { client.updates }

    /// Builds the connection and the agent together.
    ///
    /// - Parameters:
    ///   - onPermission: How the host answers a permission request. Refuses every request by
    ///     default, which surfaces to the agent as a thrown error rather than a denial.
    ///   - makeAgent: Builds the agent, receiving the client it should report to.
    public init(
        onPermission: @escaping @Sendable (RequestPermissionRequest) async throws -> RequestPermissionResponse = { _ in
            throw ACPTransportError.methodNotSupported(ACPMethod.Client.sessionRequestPermission)
        },
        makeAgent: (any ACPClient) -> any ACPAgent
    ) {
        let client = StreamingSessionClient(onPermission: onPermission)
        self.client = client
        agent = makeAgent(client)
    }

    /// Closes the update stream once the conversation is over, ending the host's loop. The agent
    /// is not stopped by this.
    public func finish() {
        client.finish()
    }
}
