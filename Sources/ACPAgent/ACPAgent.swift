import ACPCore

/// The agent side of the Agent Client Protocol: the methods an agent handles
/// when driven by a client.
///
/// This is the behavioural contract over the v1 wire types — transport-agnostic
/// and UI-independent. A concrete agent (an LLM loop, an A2A orchestrator, …)
/// conforms to it; a transport adapts it to JSON-RPC or an in-process channel.
/// Only stable v1 methods are included.
public protocol ACPAgent: Sendable {
    /// Negotiate protocol version and exchange capabilities.
    func initialize(_ request: InitializeRequest) async throws -> InitializeResponse

    /// Authenticate with the agent using a previously advertised method.
    func authenticate(_ request: AuthenticateRequest) async throws -> AuthenticateResponse

    /// Create a new session.
    func newSession(_ request: NewSessionRequest) async throws -> NewSessionResponse

    /// Resume a previously created session by loading its history.
    func loadSession(_ request: LoadSessionRequest) async throws -> LoadSessionResponse

    /// List the sessions the agent knows about.
    func listSessions(_ request: ListSessionsRequest) async throws -> ListSessionsResponse

    /// Resume a session for further prompting.
    func resumeSession(_ request: ResumeSessionRequest) async throws -> ResumeSessionResponse

    /// Delete a session and its history.
    func deleteSession(_ request: DeleteSessionRequest) async throws -> DeleteSessionResponse

    /// Close a session without deleting it.
    func closeSession(_ request: CloseSessionRequest) async throws -> CloseSessionResponse

    /// Switch the session's current mode.
    func setSessionMode(_ request: SetSessionModeRequest) async throws -> SetSessionModeResponse

    /// Set a session configuration option.
    func setSessionConfigOption(
        _ request: SetSessionConfigOptionRequest
    ) async throws -> SetSessionConfigOptionResponse

    /// Run a prompt turn. The agent streams progress to the client via
    /// `session/update` notifications and returns a `StopReason`.
    func prompt(_ request: PromptRequest) async throws -> PromptResponse

    /// Cancel the in-flight prompt turn for a session (notification — no reply).
    func cancel(_ notification: CancelNotification) async throws

    /// End the agent's authenticated session.
    func logout(_ request: LogoutRequest) async throws -> LogoutResponse

    /// Handle a non-spec extension request.
    func ext(_ request: ExtRequest) async throws -> ExtResponse

    /// Handle a non-spec extension notification.
    func extNotification(_ notification: ExtNotification) async throws
}
