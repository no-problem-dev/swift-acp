# ``ACPJSONRPC``

The JSON-RPC 2.0 envelope, and the protocol that binds every ACP type to the pinned wire schema.

## Overview

This is the bottom of the dependency graph, and it knows nothing about ACP. `ACPCore`
re-exports it, so `import ACPCore` is normally enough — import this module directly only when you
want the envelope without the domain types.

Three things live here.

**The envelope.** ``JSONRPCRequest``, ``JSONRPCNotification`` and ``JSONRPCResponse`` are generic
over their payload, so a typed value travels without the envelope knowing what it is.
``JSONRPCVersion`` models the one legal value of the `jsonrpc` field, which means a message
declaring any other version fails to decode rather than being processed as 2.0.

**``JSONValue``.** A recursive enum covering every JSON node, for the places ACP leaves the shape
open: `_meta`, extension methods, and MCP tool input and output. It is a concrete type rather than
`Any`, which is what keeps `Codable`, `Equatable` and `Sendable` intact all the way down. Numbers
are `Double`, so an integer beyond 2^53 does not survive a round trip exactly.

**``ACPSchemaType``.** The protocol that enrols a type in the schema-coverage check. The suite reads
the pinned schema, collects every type listed in ``ACPJSONRPCSchema`` and `ACPCoreSchema`, and
requires the two sets to match exactly — then decodes and re-encodes the vendored wire samples
through them. Adopting the protocol is not enough on its own: a type absent from those registries
is invisible to the check.

```swift
import ACPJSONRPC

let value: JSONValue = .object(["version": .number(1), "tag": .string("stable")])

// Every schema type round-trips.
let data = try JSONEncoder().encode(RequestId.number(42))
let copy = try JSONDecoder().decode(RequestId.self, from: data)
assert(copy == .number(42))
```

### Where the model is looser than the wire

``RequestId`` models `null` because JSON-RPC permits it, but the frame classifier in
`ACPTransport` cannot tell a null id from an absent one. A request with a null id is read as a
notification and answered by nothing; a response with one is rejected as malformed.

``ErrorCode`` keeps an unrecognized code verbatim in `other`, so a peer can introduce a code
without breaking this one.

## Topics

### Schema Contract

- ``ACPSchemaType``
- ``ACPJSONRPCSchema``

### JSON

- ``JSONValue``

### Envelope

- ``JSONRPCRequest``
- ``JSONRPCNotification``
- ``JSONRPCResponse``
- ``JSONRPCVersion``
- ``RequestId``

### Errors

- ``RPCError``
- ``ErrorCode``
