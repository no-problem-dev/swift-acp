import ACPCore

/// What a host implements: the channel an agent reports progress on, plus the capabilities the host
/// lends the agent.
///
/// Only `sessionUpdate(_:)` is required in practice. The file-system and terminal methods are
/// optional bolt-ons the host advertises in the `ClientCapabilities` it sends at initialization;
/// declining them is the norm for a host that only observes, and the ones it does not offer should
/// throw. Nothing here checks that what a host advertises matches what it implements.
///
/// A conforming type must be safe to call concurrently: an agent may ask for a permission decision
/// while updates are still streaming.
public protocol ACPClient: Sendable {
    /// Asks the user to approve a tool call and returns what they chose.
    ///
    /// The agent blocks on this, so a host that shows a dialog holds the turn open until it is
    /// answered. Cancelling the turn is the way out of an unanswered prompt.
    func requestPermission(
        _ request: RequestPermissionRequest
    ) async throws -> RequestPermissionResponse

    /// Writes a text file on the host's file system.
    func writeTextFile(_ request: WriteTextFileRequest) async throws -> WriteTextFileResponse

    /// Reads a text file from the host's file system.
    func readTextFile(_ request: ReadTextFileRequest) async throws -> ReadTextFileResponse

    /// Starts a command in a new terminal and returns its identifier.
    func createTerminal(_ request: CreateTerminalRequest) async throws -> CreateTerminalResponse

    /// Returns what a terminal has produced so far, and its exit status if it has finished.
    func terminalOutput(_ request: TerminalOutputRequest) async throws -> TerminalOutputResponse

    /// Releases a terminal and frees its resources. The identifier is invalid afterwards.
    func releaseTerminal(_ request: ReleaseTerminalRequest) async throws -> ReleaseTerminalResponse

    /// Waits for a terminal's command to exit.
    func waitForTerminalExit(
        _ request: WaitForTerminalExitRequest
    ) async throws -> WaitForTerminalExitResponse

    /// Kills a terminal's command without releasing the terminal, so its output stays readable.
    func killTerminal(_ request: KillTerminalRequest) async throws -> KillTerminalResponse

    /// Receives one streamed update from the agent — the progress channel a host renders.
    ///
    /// A notification: it has no reply, so throwing reaches nobody and does not stop the stream.
    func sessionUpdate(_ notification: SessionNotification) async throws

    /// Handles a method the specification does not define.
    func ext(_ request: ExtRequest) async throws -> ExtResponse

    /// Handles a notification the specification does not define. Has no reply.
    func extNotification(_ notification: ExtNotification) async throws
}
