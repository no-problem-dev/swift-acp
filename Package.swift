// swift-tools-version: 6.0
import PackageDescription

// swift-acp — a test-driven, fully-conformant Swift implementation of the
// Agent Client Protocol (https://agentclientprotocol.com).
//
// Conformance target: schema crate 0.13.6 / protocol v1 (the LATEST stable).
// The authoritative wire schema (schema/v1/schema.json) and method registry
// (meta.json) are vendored under Tests/ACPConformanceTests/Spec/v1 and pinned
// to that version; every type is proven against them rather than assumed.
let package = Package(
    name: "swift-acp",
    platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1)],
    products: [
        .library(name: "ACPJSONRPC", targets: ["ACPJSONRPC"]),
        .library(name: "ACPCore", targets: ["ACPCore"]),
        .library(name: "ACPAgent", targets: ["ACPAgent"]),
        .library(name: "ACPClient", targets: ["ACPClient"]),
        .library(name: "ACPTransport", targets: ["ACPTransport"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.0"),
    ],
    targets: [
        // JSON-RPC 2.0 envelope, decoupled from ACP domain types (mirrors src/rpc.rs).
        .target(name: "ACPJSONRPC"),

        // The ACP domain types: a faithful, transport-agnostic Swift mirror of
        // schema/v1/schema.json. Pure Codable value types, no I/O.
        .target(name: "ACPCore", dependencies: ["ACPJSONRPC"]),

        // The two role contracts. Behaviour is scoped; the types stay complete.
        .target(name: "ACPAgent", dependencies: ["ACPCore"]),
        .target(name: "ACPClient", dependencies: ["ACPCore"]),

        // Transport boundary: an in-process typed channel (no serialization) and
        // a JSON-RPC-over-stdio adapter for interop.
        .target(name: "ACPTransport", dependencies: ["ACPCore", "ACPJSONRPC", "ACPAgent", "ACPClient"]),

        .testTarget(name: "ACPJSONRPCTests", dependencies: ["ACPJSONRPC"]),
        .testTarget(name: "ACPCoreTests", dependencies: ["ACPCore"]),
        .testTarget(name: "ACPTransportTests", dependencies: ["ACPTransport"]),

        // Conformance: validates the Swift surface against the vendored spec.
        .testTarget(
            name: "ACPConformanceTests",
            dependencies: ["ACPCore", "ACPJSONRPC"],
            resources: [.copy("Spec")]
        ),
    ]
)
