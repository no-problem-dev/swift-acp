# ``ACPAgent``

The one protocol an ACP agent implements.

## Overview

``ACPAgent`` is the agent half of the protocol: every method a client may call. Conforming to it is
the whole requirement for being served by `ACPTransport` — over stdio, in-process, or anything else
that carries frames.

The methods fall into four groups. **Handshake** — `initialize`, `authenticate`, `logout` — agrees
the protocol version, exchanges capabilities and manages credentials. **Session lifecycle** —
`newSession`, `loadSession`, `listSessions`, `resumeSession`, `deleteSession`, `closeSession`,
`setSessionMode`, `setSessionConfigOption` — lets a client manage named, persistent conversations.
**Prompting** — `prompt` — runs one turn, during which the agent pushes progress to the client
through `ACPClient.sessionUpdate(_:)`. **Cancellation and extensions** — `cancel`, `ext`,
`extNotification` — cover stopping a turn and anything the specification does not define.

There are no default implementations, so every method must be answered. Throw
`RPCError(code: .methodNotFound, …)` for the ones you do not offer, and say so in the capabilities
returned from `initialize` — the failure should be a refusal the client can read, not a crash.

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
        PromptResponse(stopReason: .endTurn)
    }

    // Everything this agent does not offer refuses in a way the client can read.
    func authenticate(_ r: AuthenticateRequest) async throws -> AuthenticateResponse {
        throw RPCError(code: .methodNotFound, message: "authenticate is not supported")
    }
    // …and so on for the remaining methods.
}
```

### What a conforming type must guarantee

**Safe to call concurrently.** Nothing serializes these calls. A client may send `cancel` while
`prompt` is still running — that is the point of the method — and may issue other requests during a
turn.

**A turn ends by returning, not by throwing.** A cancelled turn returns normally with a stop reason
of cancelled. Throwing from `prompt` reports a failure of the call itself.

**Resumable after an interruption.** Stopping a turn to ask for input ends that `prompt` call; the
client's answer arrives as a new one. Whatever the agent needs to continue must survive in the
session, not in the call.

**Unknown methods arrive at `ext`.** The stdio connection routes every unrecognized method there
rather than answering method-not-found, so an agent that wants no extensions should throw from it.

## Topics

### Role Contract

- ``ACPAgent``
