# ``ACPAgent``

The protocol that any ACP-compliant agent must conform to — a transport-agnostic Swift contract over the v1 method set.

## Overview

`ACPAgent` defines the **agent side** of the Agent Client Protocol: the full set of methods a client may call on an agent. Conforming to `ACPAgent` is the only requirement for a type to be wired up by `ACPTransport` — whether over stdio, an in-process channel, or any future transport.

The protocol covers four logical groups of operations. Handshake methods (`initialize`, `authenticate`, `logout`) negotiate the protocol version, exchange capabilities, and manage authentication. Session lifecycle methods (`newSession`, `loadSession`, `listSessions`, `resumeSession`, `deleteSession`, `closeSession`, `setSessionMode`, `setSessionConfigOption`) let the client manage named, persistent conversations. The prompt method (`prompt`) drives one turn of agent reasoning; the agent is expected to push streaming progress to the client via `ACPClient.sessionUpdate(_:)` as it works. Extension methods (`ext`, `extNotification`, `cancel`) handle cancellation and non-spec additions.

All methods are `async throws`. An agent that does not support a given capability can throw `ACPTransportError.methodNotSupported(_:)` to signal this cleanly to the transport.

```swift
import ACPCore
import ACPAgent

struct EchoAgent: ACPAgent {
    func initialize(_ request: InitializeRequest) async throws -> InitializeResponse {
        InitializeResponse(
            protocolVersion: .latest,
            agentCapabilities: AgentCapabilities(),
            authMethods: []
        )
    }

    func prompt(_ request: PromptRequest) async throws -> PromptResponse {
        PromptResponse(stopReason: StopReason(rawValue: "end_turn"))
    }

    // Remaining methods omitted for brevity — each throws in a real minimal stub.
    func authenticate(_ r: AuthenticateRequest) async throws -> AuthenticateResponse { fatalError() }
    func newSession(_ r: NewSessionRequest) async throws -> NewSessionResponse { fatalError() }
    func loadSession(_ r: LoadSessionRequest) async throws -> LoadSessionResponse { fatalError() }
    func listSessions(_ r: ListSessionsRequest) async throws -> ListSessionsResponse { fatalError() }
    func resumeSession(_ r: ResumeSessionRequest) async throws -> ResumeSessionResponse { fatalError() }
    func deleteSession(_ r: DeleteSessionRequest) async throws -> DeleteSessionResponse { fatalError() }
    func closeSession(_ r: CloseSessionRequest) async throws -> CloseSessionResponse { fatalError() }
    func setSessionMode(_ r: SetSessionModeRequest) async throws -> SetSessionModeResponse { fatalError() }
    func setSessionConfigOption(_ r: SetSessionConfigOptionRequest) async throws -> SetSessionConfigOptionResponse { fatalError() }
    func cancel(_ n: CancelNotification) async throws {}
    func logout(_ r: LogoutRequest) async throws -> LogoutResponse { fatalError() }
    func ext(_ r: ExtRequest) async throws -> ExtResponse { fatalError() }
    func extNotification(_ n: ExtNotification) async throws {}
}
```

## Topics

### Role Contract

- ``ACPAgent``
