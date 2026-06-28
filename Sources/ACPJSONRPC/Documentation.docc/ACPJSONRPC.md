# ``ACPJSONRPC``

JSON-RPC 2.0 envelope types and the `ACPSchemaType` conformance contract that underpins every domain type in the `swift-acp` package.

## Overview

`ACPJSONRPC` is the lowest layer in the `swift-acp` dependency graph. All other modules depend on it directly or transitively, and `ACPCore` re-exports it so that a single `import ACPCore` statement brings the JSON-RPC primitives into scope for most users.

The module provides three categories of types. First, the generic JSON-RPC 2.0 envelope structs — `JSONRPCRequest`, `JSONRPCNotification`, and `JSONRPCResponse` — carry typed payloads across any transport. `JSONRPCVersion` identifies the protocol revision in each envelope.

Second, `JSONValue` is a recursive sum type that models any JSON node (null, bool, number, string, array, object). It is used wherever the ACP schema allows open-ended JSON, such as extension payloads and the `_meta` dictionary.

Third, `ACPSchemaType` is the protocol that every named definition in the ACP wire schema maps to exactly one Swift type through. Conforming types gain a default `schemaName` and a `roundTripJSON(_:using:)` helper used by the conformance test suite to prove lossless encoding.

```swift
import ACPJSONRPC

// JSONValue models arbitrary JSON without loss.
let value: JSONValue = .object(["version": .number(1), "tag": .string("stable")])

// Every schema type round-trips through JSON.
let data = try JSONEncoder().encode(RequestId.number(42))
let copy = try JSONDecoder().decode(RequestId.self, from: data)
assert(copy == .number(42))
```

## Topics

### Schema Contract

- ``ACPSchemaType``

### JSON Primitives

- ``JSONValue``

### Request Identifiers

- ``RequestId``

### Envelopes

- ``JSONRPCRequest``
- ``JSONRPCNotification``
- ``JSONRPCResponse``
- ``JSONRPCVersion``

### Errors

- ``RPCError``
- ``ErrorCode``

### Schema Registry

- ``ACPJSONRPCSchema``
