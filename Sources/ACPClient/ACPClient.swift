import ACPCore

/// The client side of the Agent Client Protocol: the capabilities a client
/// (the host — an editor, an iOS app, a progress UI) lends to the agent, plus
/// receipt of `session/update` notifications.
///
/// This is the behavioural contract over the v1 wire types — transport-agnostic
/// and UI-independent. Only stable v1 methods are included; a client advertises
/// which of the file-system and terminal methods it actually supports via
/// `ClientCapabilities`.
public protocol ACPClient: Sendable {
    /// Ask the user to authorize a tool call, returning their decision.
    func requestPermission(
        _ request: RequestPermissionRequest
    ) async throws -> RequestPermissionResponse

    /// Write a text file in the client's file system.
    func writeTextFile(_ request: WriteTextFileRequest) async throws -> WriteTextFileResponse

    /// Read a text file from the client's file system.
    func readTextFile(_ request: ReadTextFileRequest) async throws -> ReadTextFileResponse

    /// Create a terminal and execute a command.
    func createTerminal(_ request: CreateTerminalRequest) async throws -> CreateTerminalResponse

    /// Get a terminal's current output and exit status.
    func terminalOutput(_ request: TerminalOutputRequest) async throws -> TerminalOutputResponse

    /// Release a terminal and free its resources.
    func releaseTerminal(_ request: ReleaseTerminalRequest) async throws -> ReleaseTerminalResponse

    /// Wait for a terminal's command to exit.
    func waitForTerminalExit(
        _ request: WaitForTerminalExitRequest
    ) async throws -> WaitForTerminalExitResponse

    /// Kill a terminal's command without releasing the terminal.
    func killTerminal(_ request: KillTerminalRequest) async throws -> KillTerminalResponse

    /// Receive a streamed session update from the agent (notification — no
    /// reply). This is the progress channel a host renders.
    func sessionUpdate(_ notification: SessionNotification) async throws

    /// Handle a non-spec extension request.
    func ext(_ request: ExtRequest) async throws -> ExtResponse

    /// Handle a non-spec extension notification.
    func extNotification(_ notification: ExtNotification) async throws
}
