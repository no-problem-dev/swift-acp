# ``ACPTransport``

Connects a role contract to a channel — in-process with nothing serialized, or JSON-RPC over stdio.

## Overview

The top of the stack, and the only module that moves bytes. It offers two ways to connect an
`ACPAgent` to an `ACPClient`, and the choice is the swappable part of the design: the agent and
the host are written once and work either way.

``InProcessConnection`` runs both sides in one process. The host drives the agent through its
protocol directly and reads progress from an `AsyncStream`; no frame is ever built. Right for
tests, and for embedding an agent in the app that hosts it.

``AgentConnection`` serves an agent over a frame transport — ``StdioTransport`` for the newline-
delimited JSON that ACP standardizes on, or anything else conforming to ``ACPMessageTransport``.
Incoming requests are decoded by method name and dispatched; the agent is handed a client proxy
whose calls are marshalled back out over the same connection. This is the path for interoperating
with an ACP client you did not write.

``JSONRPCFrame`` and ``JSONRPCCodec`` are the framing primitives `AgentConnection` uses, public for
callers building their own dispatch.

```swift
import ACPCore
import ACPTransport

let connection = InProcessConnection { client in
    MyResearchAgent(client: client)
}

Task {
    for await notification in connection.updates {
        render(notification.update)
    }
}

let response = try await connection.agent.prompt(
    PromptRequest(sessionId: SessionId("s1"), prompt: [])
)
connection.finish()
```

### What the two paths do not share

**In-process never encodes anything.** A payload that would fail to serialize passes unnoticed
there, so a passing in-process test is evidence about the agent, not about the wire format. Run at
least one path over ``AgentConnection`` before trusting interoperability.

**Order is preserved only in-process.** ``AgentConnection`` reads frames sequentially but dispatches
each on its own task, so two notifications sent back to back may be handled in either order. An
agent that depends on ordering must impose it itself.

**A malformed frame ends the connection.** ``AgentConnection/run()`` throws on a frame it cannot
decode, and the cleanup that fails outstanding calls does not run in that case — they stay
suspended. Only a clean close fails them with ``ACPTransportError/closed``.

**Nothing times out.** A request the peer never answers waits until the transport closes.

## Topics

### In-Process

- ``InProcessConnection``
- ``StreamingSessionClient``

### Serialized

- ``AgentConnection``
- ``StdioTransport``
- ``ACPMessageTransport``
- ``ACPTransportError``

### Framing

- ``JSONRPCFrame``
- ``JSONRPCCodec``
