import ACPCore

/// What an agent implements: the thirteen v1 methods a client may call, plus the two extension
/// escape hatches.
///
/// Behaviour only — no transport and no UI. A concrete agent conforms to this and a transport
/// adapts it, either to JSON-RPC over a wire or to direct Swift calls in the same process. The
/// protocol carries no default implementations, so every method must be answered; throw
/// `RPCError(code: .methodNotFound, …)` for the ones an agent does not offer, and say so in the
/// capabilities it returns from `initialize`.
///
/// A conforming type must be safe to call concurrently: nothing serializes these calls, and a
/// client may issue a cancellation while a prompt is still running — which is the whole point of
/// that method.
public protocol ACPAgent: Sendable {
    /// Agrees the protocol version and exchanges capabilities. The first call of any session.
    func initialize(_ request: InitializeRequest) async throws -> InitializeResponse

    /// Authenticates using one of the methods advertised during initialization.
    func authenticate(_ request: AuthenticateRequest) async throws -> AuthenticateResponse

    /// Creates a session.
    func newSession(_ request: NewSessionRequest) async throws -> NewSessionResponse

    /// Reopens an earlier session, replaying its history to the client as it goes.
    func loadSession(_ request: LoadSessionRequest) async throws -> LoadSessionResponse

    /// Lists the sessions the agent knows about.
    func listSessions(_ request: ListSessionsRequest) async throws -> ListSessionsResponse

    /// Resumes a session so it can take further prompts.
    func resumeSession(_ request: ResumeSessionRequest) async throws -> ResumeSessionResponse

    /// Deletes a session and its history.
    func deleteSession(_ request: DeleteSessionRequest) async throws -> DeleteSessionResponse

    /// Closes a session without deleting it, so it can be resumed later.
    func closeSession(_ request: CloseSessionRequest) async throws -> CloseSessionResponse

    /// Switches which mode the session is operating in.
    func setSessionMode(_ request: SetSessionModeRequest) async throws -> SetSessionModeResponse

    /// Sets one of the session's configuration options.
    func setSessionConfigOption(
        _ request: SetSessionConfigOptionRequest
    ) async throws -> SetSessionConfigOptionResponse

    /// Runs one turn.
    ///
    /// The agent streams its progress as `session/update` notifications on the client while this
    /// call is outstanding, and returns a stop reason when the turn ends. A turn stopped by
    /// `cancel(_:)` returns normally with `.cancelled`, not by throwing.
    func prompt(_ request: PromptRequest) async throws -> PromptResponse

    /// Asks the agent to stop the turn in progress.
    ///
    /// A notification: it has no reply, so a failure here reaches nobody. The turn's own `prompt`
    /// call is what reports the outcome.
    func cancel(_ notification: CancelNotification) async throws

    /// Ends the authenticated session with the agent.
    func logout(_ request: LogoutRequest) async throws -> LogoutResponse

    /// Handles a method the specification does not define.
    ///
    /// The stdio connection routes every unrecognized method here rather than answering
    /// method-not-found, so an agent that does not want extensions should throw from this.
    func ext(_ request: ExtRequest) async throws -> ExtResponse

    /// Handles a notification the specification does not define. Has no reply.
    func extNotification(_ notification: ExtNotification) async throws
}
