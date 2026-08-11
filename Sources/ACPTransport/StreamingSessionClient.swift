import ACPCore
import ACPClient

/// A client for a host that watches an agent rather than lending it anything.
///
/// Updates go into an `AsyncStream` for a UI to render, and permission requests go to the handler
/// supplied at construction. Every file-system and terminal method throws — a host using this
/// should advertise no such capabilities during initialization.
public final class StreamingSessionClient: ACPClient, Sendable {
    /// The agent's updates, in the order it published them.
    ///
    /// Buffers without bound, so nothing is dropped if the consumer falls behind. There is one
    /// stream and it is single-consumer: a second iteration sees only what arrives afterwards.
    /// Finishes when `finish()` is called, never on its own.
    public let updates: AsyncStream<SessionNotification>

    private let continuation: AsyncStream<SessionNotification>.Continuation
    private let permissionHandler:
        @Sendable (RequestPermissionRequest) async throws -> RequestPermissionResponse

    public init(
        onPermission: @escaping @Sendable (RequestPermissionRequest) async throws -> RequestPermissionResponse = { _ in
            throw ACPTransportError.methodNotSupported(ACPMethod.Client.sessionRequestPermission)
        }
    ) {
        var continuation: AsyncStream<SessionNotification>.Continuation!
        updates = AsyncStream(bufferingPolicy: .unbounded) { continuation = $0 }
        self.continuation = continuation
        permissionHandler = onPermission
    }

    /// Closes the update stream, ending the consumer's loop. Idempotent, and not reversible —
    /// updates published afterwards are dropped.
    public func finish() {
        continuation.finish()
    }

    public func sessionUpdate(_ notification: SessionNotification) async throws {
        continuation.yield(notification)
    }

    public func requestPermission(
        _ request: RequestPermissionRequest
    ) async throws -> RequestPermissionResponse {
        try await permissionHandler(request)
    }

    public func writeTextFile(_ request: WriteTextFileRequest) async throws -> WriteTextFileResponse {
        throw ACPTransportError.methodNotSupported(ACPMethod.Client.fsWriteTextFile)
    }

    public func readTextFile(_ request: ReadTextFileRequest) async throws -> ReadTextFileResponse {
        throw ACPTransportError.methodNotSupported(ACPMethod.Client.fsReadTextFile)
    }

    public func createTerminal(_ request: CreateTerminalRequest) async throws -> CreateTerminalResponse {
        throw ACPTransportError.methodNotSupported(ACPMethod.Client.terminalCreate)
    }

    public func terminalOutput(_ request: TerminalOutputRequest) async throws -> TerminalOutputResponse {
        throw ACPTransportError.methodNotSupported(ACPMethod.Client.terminalOutput)
    }

    public func releaseTerminal(_ request: ReleaseTerminalRequest) async throws -> ReleaseTerminalResponse {
        throw ACPTransportError.methodNotSupported(ACPMethod.Client.terminalRelease)
    }

    public func waitForTerminalExit(
        _ request: WaitForTerminalExitRequest
    ) async throws -> WaitForTerminalExitResponse {
        throw ACPTransportError.methodNotSupported(ACPMethod.Client.terminalWaitForExit)
    }

    public func killTerminal(_ request: KillTerminalRequest) async throws -> KillTerminalResponse {
        throw ACPTransportError.methodNotSupported(ACPMethod.Client.terminalKill)
    }

    public func ext(_ request: ExtRequest) async throws -> ExtResponse {
        throw ACPTransportError.methodNotSupported(request.method)
    }

    public func extNotification(_ notification: ExtNotification) async throws {}
}
