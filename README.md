# swift-acp

English | [日本語](./README.ja.md)

A Swift implementation of the [Agent Client Protocol](https://agentclientprotocol.com) — the JSON-RPC standard that connects any editor or host to any agent.

> **Unofficial.** Not affiliated with or endorsed by the authors of the Agent Client Protocol. Conforming to the specification is not a goal of this project.

![Swift 6.0+](https://img.shields.io/badge/Swift-6.0+-orange.svg)
![ACP v1](https://img.shields.io/badge/ACP-schema%200.13.6%20%2F%20v1-green.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2016+%20%7C%20macOS%2013+%20%7C%20tvOS%2016+%20%7C%20watchOS%209+%20%7C%20visionOS%201+-blue.svg)
![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)

## Features

- **The wire schema is vendored and version-pinned** — the test suite checks that each `$defs` entry has a modelled type, that the method tables match the registry, and that the vendored wire samples round-trip. What each check does and does not cover is written on the [Architecture](https://no-problem-dev.github.io/swift-acp/documentation/acpcore/architecture) page
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

- [ACPCore](https://no-problem-dev.github.io/swift-acp/documentation/acpcore/) — the domain types, and [Architecture](https://no-problem-dev.github.io/swift-acp/documentation/acpcore/architecture) for the layering and what the test suite checks
- [ACPJSONRPC](https://no-problem-dev.github.io/swift-acp/documentation/acpjsonrpc/) — the envelope
- [ACPAgent](https://no-problem-dev.github.io/swift-acp/documentation/acpagent/) · [ACPClient](https://no-problem-dev.github.io/swift-acp/documentation/acpclient/) — the two role contracts
- [ACPTransport](https://no-problem-dev.github.io/swift-acp/documentation/acptransport/) — connecting them

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/no-problem-dev/swift-acp.git", .upToNextMinor(from: "0.2.0"))
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

Run the test suite with `swift test`.

## License

Apache-2.0, matching the reference protocol. See [LICENSE](LICENSE).
