import ACPCore
import ACPAgent
import ACPClient

/// Wires an agent and a host together in one process, with no serialization.
///
/// This is the in-process realization of the ACP contract the user reasoned
/// toward: the host drives the agent through the `ACPAgent` protocol directly,
/// the agent reports progress by calling `client.sessionUpdate(_:)`, and the
/// host consumes those updates as an `AsyncStream`. The JSON-RPC wire is never
/// involved; the same typed messages cross as Swift values.
///
/// ```swift
/// let connection = InProcessConnection { client in
///     MyResearchAgent(client: client)   // agent keeps the client to report updates
/// }
/// Task {
///     for await update in connection.updates { render(update) }
/// }
/// _ = try await connection.agent.prompt(promptRequest)
/// connection.finish()
/// ```
public struct InProcessConnection: Sendable {
    /// The agent, driven directly through the `ACPAgent` contract.
    public let agent: any ACPAgent

    /// The observing client handed to the agent.
    public let client: StreamingSessionClient

    /// The agent's session-update stream (the progress channel).
    public var updates: AsyncStream<SessionNotification> { client.updates }

    /// - Parameters:
    ///   - onPermission: how host-side permission requests are answered.
    ///   - makeAgent: builds the agent, receiving the client it should report to.
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

    /// Close the update stream once the conversation is over.
    public func finish() {
        client.finish()
    }
}
