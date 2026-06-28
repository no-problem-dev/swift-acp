# ``ACPTransport``

Concrete transport adapters that wire `ACPAgent` and `ACPClient` implementations to in-process channels or JSON-RPC-over-stdio for out-of-process interop.

## Overview

`ACPTransport` is the top of the `swift-acp` dependency stack. It depends on all four other modules and converts the abstract role contracts from `ACPAgent` and `ACPClient` into running communication channels.

Two connection styles are provided. `InProcessConnection` is the zero-copy, zero-serialization path: it binds an `ACPAgent` and a `StreamingSessionClient` in one process, exposes the agent's progress notifications as an `AsyncStream<SessionNotification>`, and lets the host drive turns directly. This is ideal for testing, embedding an agent in an app, or any scenario where both sides live in the same Swift process.

`AgentConnection` is the serialized path. It wraps any `ACPMessageTransport` — for instance `StdioTransport`, which reads and writes `Data` frames on standard in/out — and runs the full JSON-RPC dispatch loop. Incoming client requests are decoded by method name, dispatched to the concrete `ACPAgent`, and the response is encoded and sent back. The agent receives a `RemoteClient` proxy whose calls (such as `sessionUpdate`, `fs/*`, `terminal/*`) are marshalled back over the same transport. This is the standard path for agents that need to interoperate with external ACP clients.

`JSONRPCFrame` and `JSONRPCCodec` are the lower-level framing primitives used internally by `AgentConnection`; they are public for callers that need direct access to the encode/decode layer.

```swift
import ACPCore
import ACPTransport

// In-process: no serialization, direct Swift value passing.
let conn = InProcessConnection { client in
    MyResearchAgent(client: client)
}

Task {
    for await notification in conn.updates {
        print(notification.update) // render streamed progress
    }
}

let response = try await conn.agent.prompt(
    PromptRequest(sessionId: SessionId(rawValue: "s1"), content: Content(blocks: []))
)
conn.finish()
```

## Topics

### In-Process Channel

- ``InProcessConnection``
- ``StreamingSessionClient``

### Serialized Channel

- ``AgentConnection``
- ``StdioTransport``

### Transport Protocol

- ``ACPMessageTransport``
- ``ACPTransportError``

### Framing

- ``JSONRPCFrame``
- ``JSONRPCCodec``
