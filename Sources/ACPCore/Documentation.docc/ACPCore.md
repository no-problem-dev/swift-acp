# ``ACPCore``

Every type ACP v1 defines, as Codable Swift values with no I/O.

## Overview

ACP is a bidirectional JSON-RPC channel between an agent — an LLM loop, an orchestrator, any
autonomous process — and a client that hosts it. Its core is domain-agnostic: prompt an agent,
watch plans, thoughts, tool calls and permission requests stream back, cancel when you want to.
The file-system and terminal capabilities are optional bolt-ons the host lends, so this is as
usable as the progress plane for a non-coding agent as for a coding one.

This module holds the vocabulary. Every type here mirrors one `$defs` entry of the pinned wire
schema, and the conformance suite refuses to let the two drift apart: it requires an exact
correspondence between schema definitions and modelled types, then round-trips the vendored wire
samples through them.

The package splits into five libraries. `ACPJSONRPC` carries the envelope and is re-exported by
this module, so `import ACPCore` is normally the only import you need. `ACPAgent` and `ACPClient`
state the two role contracts. `ACPTransport` connects them, either in one process with nothing
serialized, or over stdio as JSON-RPC.

```swift
import ACPCore

let request = InitializeRequest(
    protocolVersion: .latest,
    clientCapabilities: ClientCapabilities(),
    clientInfo: Implementation(name: "MyHost", version: "1.0")
)

print(request.protocolVersion.value) // 1
```

### Three conventions that explain most of the encoding

**Unknown values are kept, not rejected.** String enumerations such as ``Role`` and ``ToolKind``
are open newtypes, and tagged unions such as ``ContentBlock``, ``SessionUpdate`` and ``AuthMethod``
carry an `unknown` case holding the original JSON. A peer on a newer revision does not break
decoding, and an unknown value re-encodes byte for byte. The cost is that a `switch` over these
types is never exhaustive.

**Defaults are omitted.** A field equal to its default — an empty collection, `false`, a zero — is
left off the wire, matching the reference implementation. Absence therefore means the default, not
"unset".

**Except where absence is meaningful.** ``MaybeUndefined`` exists for the fields where ACP
distinguishes absent from null: on ``SessionInfoUpdate``, absence leaves a title alone while
`null` clears it. That type cannot omit its own key, so the containing type checks `isUndefined`
and skips it — getting that wrong turns "leave unchanged" into "clear" with nothing failing.

### The routing envelopes are a convenience, not the dispatch path

``AgentRequest``, ``ClientRequest`` and their siblings union every method's payload for one
direction. A transport dispatches by JSON-RPC method name and does not use them. They decode by
trying each variant in order and taking the first that succeeds, so a payload valid as two
variants resolves to whichever is tried first — reach for them only when a single typed value per
channel is genuinely what you want.

## Topics

### Essentials

- <doc:Architecture>

### Handshake

- ``InitializeRequest``
- ``InitializeResponse``
- ``ProtocolVersion``
- ``Implementation``
- ``AgentCapabilities``
- ``ClientCapabilities``

### Session Lifecycle

- ``NewSessionRequest``
- ``NewSessionResponse``
- ``LoadSessionRequest``
- ``LoadSessionResponse``
- ``ListSessionsRequest``
- ``ListSessionsResponse``
- ``ResumeSessionRequest``
- ``ResumeSessionResponse``
- ``DeleteSessionRequest``
- ``DeleteSessionResponse``
- ``CloseSessionRequest``
- ``CloseSessionResponse``
- ``SessionInfo``
- ``SessionId``

### Prompts

- ``PromptRequest``
- ``PromptResponse``
- ``StopReason``

### Session Updates

- ``SessionNotification``
- ``SessionUpdate``
- ``ContentChunk``
- ``UsageUpdate``
- ``SessionInfoUpdate``

### Content

- ``ContentBlock``
- ``Content``
- ``TextContent``
- ``ImageContent``
- ``AudioContent``
- ``EmbeddedResource``
- ``ResourceLink``
- ``Role``
- ``Annotations``

### Authentication

- ``AuthMethod``
- ``AuthMethodAgent``
- ``AuthenticateRequest``
- ``AuthenticateResponse``
- ``LogoutRequest``
- ``LogoutResponse``

### Routing Envelopes

- ``AgentRequest``
- ``ClientRequest``
- ``AgentResponse``
- ``ClientResponse``
- ``AgentNotification``
- ``ClientNotification``

### Method Registry

- ``ACPMethod``

### Supporting Types

- ``ACPCoreSchema``
- ``MaybeUndefined``
- ``Meta``
