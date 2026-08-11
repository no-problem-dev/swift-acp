# swift-acp

English | [日本語](./README.ja.md)

A Swift implementation of the [Agent Client Protocol](https://agentclientprotocol.com) — the JSON-RPC standard that connects any editor or host to any agent.

![Swift 6.0+](https://img.shields.io/badge/Swift-6.0+-orange.svg)
![ACP v1](https://img.shields.io/badge/ACP-schema%200.13.6%20%2F%20v1-green.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2016+%20%7C%20macOS%2013+%20%7C%20tvOS%2016+%20%7C%20watchOS%209+%20%7C%20visionOS%201+-blue.svg)
![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)

## Features

- **Proven against the specification, not assumed** — the wire schema and method registry are vendored and version-pinned, and the test suite requires every one of the 135 `$defs` to be modelled, the method tables to equal the registry exactly, and the reference crate's own wire samples to round-trip
- **Two transports, one agent** — write the agent once against a role contract; run it in-process with nothing serialized, or over stdio as JSON-RPC
- **Forward-compatible by construction** — open string enumerations and `unknown` cases mean a peer on a newer revision does not break decoding, and unrecognized values re-encode unchanged
- **Not just for coding agents** — the core is prompt, stream updates, cancel; file-system and terminal access are optional capabilities the host lends
- **Layered targets** — take the wire types alone, or the role contracts, or the transports. No umbrella
- **No dependencies** beyond the standard library

## Quick Start

In-process, with nothing serialized:

```swift
import ACPTransport

let connection = InProcessConnection { client in
    MyResearchAgent(client: client)   // the agent reports progress through `client`
}

Task {
    for await update in connection.updates {   // the progress channel a UI renders
        render(update)
    }
}

let response = try await connection.agent.prompt(promptRequest)
connection.finish()
```

Over stdio, to interoperate with any ACP client:

```swift
let connection = AgentConnection(transport: StdioTransport())
await connection.start { client in MyAgent(client: client) }
try await connection.run()
```

## Documentation

Each library has its own DocC page:

- [ACPCore](https://no-problem-dev.github.io/swift-acp/documentation/acpcore/) — the domain types, and [Architecture](https://no-problem-dev.github.io/swift-acp/documentation/acpcore/architecture) for the layering and exactly what the conformance suite checks
- [ACPJSONRPC](https://no-problem-dev.github.io/swift-acp/documentation/acpjsonrpc/) — the envelope
- [ACPAgent](https://no-problem-dev.github.io/swift-acp/documentation/acpagent/) · [ACPClient](https://no-problem-dev.github.io/swift-acp/documentation/acpclient/) — the two role contracts
- [ACPTransport](https://no-problem-dev.github.io/swift-acp/documentation/acptransport/) — connecting them

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/no-problem-dev/swift-acp.git", from: "0.1.0")
]
```

Then add the products you need:

```swift
.target(name: "YourTarget", dependencies: [
    .product(name: "ACPTransport", package: "swift-acp"),   // transports, role contracts, types
    // .product(name: "ACPCore", package: "swift-acp"),     // domain types only
])
```

## Requirements

| swift-acp | Swift | Platforms | ACP |
|---|---|---|---|
| 0.x | 6.0+ | iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+ | schema 0.13.6 / protocol v1 |

Run the conformance suite with `swift test`.

## License

Apache-2.0, matching the reference protocol. See [LICENSE](LICENSE).
