# ``ACPClient``

The protocol that a host implements to lend file-system and terminal capabilities to an agent and to receive streaming session updates.

## Overview

`ACPClient` defines the **client side** of the Agent Client Protocol: the set of methods an agent may call back on its host. The host is typically an editor, a mobile app, or a CLI that manages the user-facing UI. Conforming to `ACPClient` lets any such host be plugged into the transport layer provided by `ACPTransport`.

The protocol is organized around three concerns. The update channel method (`sessionUpdate(_:)`) is the most critical: the agent calls it for every streamed progress notification during a `prompt` turn, and the host is expected to render these to the user in real time. The file-system methods (`writeTextFile`, `readTextFile`) expose the host's file system to the agent — a host advertises support for them via `ClientCapabilities` during `initialize`. The terminal methods (`createTerminal`, `terminalOutput`, `releaseTerminal`, `waitForTerminalExit`, `killTerminal`) give the agent a supervised shell. Permission gating (`requestPermission`) lets the host approve or deny tool invocations before they execute. Extension methods (`ext`, `extNotification`) handle non-spec additions.

A host that only wants to observe updates without providing file-system or terminal access can use `StreamingSessionClient` from `ACPTransport` directly, which implements the protocol with sensible defaults.

```swift
import ACPCore
import ACPClient

// A minimal observer-only client that collects updates in an array.
actor CollectingClient: ACPClient {
    private(set) var received: [SessionUpdate] = []

    func sessionUpdate(_ notification: SessionNotification) async throws {
        received.append(notification.update)
    }

    func requestPermission(_ r: RequestPermissionRequest) async throws -> RequestPermissionResponse {
        fatalError("permissions not supported")
    }

    // File-system and terminal methods would go here; not supported in this stub.
    func writeTextFile(_ r: WriteTextFileRequest) async throws -> WriteTextFileResponse { fatalError() }
    func readTextFile(_ r: ReadTextFileRequest) async throws -> ReadTextFileResponse { fatalError() }
    func createTerminal(_ r: CreateTerminalRequest) async throws -> CreateTerminalResponse { fatalError() }
    func terminalOutput(_ r: TerminalOutputRequest) async throws -> TerminalOutputResponse { fatalError() }
    func releaseTerminal(_ r: ReleaseTerminalRequest) async throws -> ReleaseTerminalResponse { fatalError() }
    func waitForTerminalExit(_ r: WaitForTerminalExitRequest) async throws -> WaitForTerminalExitResponse { fatalError() }
    func killTerminal(_ r: KillTerminalRequest) async throws -> KillTerminalResponse { fatalError() }
    func ext(_ r: ExtRequest) async throws -> ExtResponse { fatalError() }
    func extNotification(_ n: ExtNotification) async throws {}
}
```

## Topics

### Role Contract

- ``ACPClient``
