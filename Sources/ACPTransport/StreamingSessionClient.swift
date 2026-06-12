import ACPCore
import ACPClient

/// An `ACPClient` for hosts that observe an agent: it funnels `session/update`
/// notifications into an `AsyncStream` (the progress channel a UI renders) and
/// routes permission requests to an async handler. File-system and terminal
/// methods are unsupported by default — a pure observer advertises neither
/// capability.
public final class StreamingSessionClient: ACPClient, Sendable {
    /// The live stream of session updates from the agent.
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

    /// Close the update stream; consumers iterating `updates` finish.
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
