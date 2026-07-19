English | [日本語](./README.ja.md)

# swift-acp

A test-driven, fully-conformant Swift implementation of the
[Agent Client Protocol](https://agentclientprotocol.com) (ACP) — the JSON-RPC
standard that connects any editor/host to any agent.

Conformance target: schema crate **0.13.6 / protocol v1** (the latest stable).
Every type is proven against the authoritative wire schema, the reference
crate's serialization vectors, and the method registry — not assumed.

## Why

ACP's core (`session/prompt` → streamed `session/update` of plans, thoughts,
tool calls, and permission requests → `session/cancel`) is a domain-agnostic
contract for **a host observing and steering a single agent's working session**.
The file-system and terminal capabilities are optional client-side bolt-ons, so
this is just as usable as the progress/control plane for a non-coding agent as
for a coding one. The transport is a swappable boundary: in-process the messages
cross as Swift values with no serialization; over stdio they are JSON-RPC.

## Targets

| Target | Role |
|---|---|
| `ACPJSONRPC` | JSON-RPC 2.0 envelope (`RequestId`, `RPCError`, `ErrorCode`, `JSONValue`), decoupled from ACP |
| `ACPCore` | The 135 ACP v1 `$defs` as Codable value types — sum-typed unions, open string enums, `unknown` cases for forward-compat |
| `ACPAgent` | The agent-role contract (`protocol ACPAgent`) |
| `ACPClient` | The client/host-role contract (`protocol ACPClient`) |
| `ACPTransport` | `InProcessConnection` (typed, no serialization) + `StdioTransport`/`AgentConnection` (JSON-RPC) + `StreamingSessionClient` |

## Installation

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/no-problem-dev/swift-acp.git", from: "0.1.0")
]
```

```swift
.target(name: "YourTarget", dependencies: [
    .product(name: "ACPTransport", package: "swift-acp"),   // transports + role contracts + types
    // .product(name: "ACPCore", package: "swift-acp"),     // domain types only
])
```

## In-process (no serialization)

```swift
import ACPTransport

let connection = InProcessConnection { client in
    MyResearchAgent(client: client)   // the agent reports progress via `client`
}

Task {
    for await update in connection.updates {   // the progress channel a UI renders
        render(update)
    }
}

let response = try await connection.agent.prompt(promptRequest)
connection.finish()
```

## Over stdio (interop)

```swift
let connection = AgentConnection(transport: StdioTransport())
await connection.start { client in MyAgent(client: client) }
try await connection.run()   // serves the agent to any ACP client over stdin/stdout
```

## Conformance

The `ACPConformanceTests` suite enforces three independent guarantees against the
version-pinned spec vendored under `Tests/ACPConformanceTests/Spec/v1`:

- **Schema coverage** — every one of the 135 `$defs` maps to exactly one modelled type.
- **Golden round-trip** — 30 wire samples harvested verbatim from the reference
  crate's `#[test]` assertions decode and re-encode losslessly (field-level conformance).
- **Method parity** — the Swift method-name tables equal `meta.json` exactly.

```
swift test
```

Apache-2.0, matching the reference protocol.
