# ``ACPCore``

A Swift implementation of the Agent Client Protocol (ACP) v1 — shared domain types, JSON-RPC primitives, and role contracts for building ACP-compliant agents and clients.

## Overview

The `swift-acp` package provides a complete, test-driven Swift surface for the Agent Client Protocol. ACP defines a bidirectional JSON-RPC 2.0 channel between an **agent** (an LLM loop, an orchestrator, or any autonomous process) and a **client** (an editor, an iOS app, or any host UI). The five libraries in this package divide that surface into focused layers.

``ACPJSONRPC`` is the foundation. It supplies the generic JSON-RPC 2.0 envelope types (`JSONRPCRequest`, `JSONRPCResponse`, `JSONRPCNotification`) and the `ACPSchemaType` conformance protocol that every domain type satisfies. Because `ACPCore` re-exports `ACPJSONRPC`, a single `import ACPCore` statement is sufficient for most users.

``ACPCore`` (this module) holds all ACP domain types: a faithful, transport-agnostic Swift mirror of the pinned v1 schema. The types are pure `Codable` value types with no I/O. They cover handshake (`InitializeRequest`, `InitializeResponse`), session lifecycle (`NewSessionRequest`, `PromptRequest`), streaming updates (`SessionUpdate`, `SessionNotification`), content blocks (`ContentBlock`, `TextContent`, `ImageContent`), auth (`AuthMethod`, `AuthenticateRequest`), and the routing envelopes (`AgentRequest`, `ClientRequest`, etc.).

``ACPAgent`` and ``ACPClient`` expose the two role contracts as Swift protocols. A concrete agent conforms to `ACPAgent`; a host UI conforms to `ACPClient`. Both protocols are transport-agnostic — they operate on the typed domain values from ``ACPCore`` directly.

``ACPTransport`` wires the contracts to real channels. `InProcessConnection` runs agent and client in the same process with zero serialization. `AgentConnection` adapts any `ACPMessageTransport` (such as `StdioTransport`) to serve an `ACPAgent` over JSON-RPC — the standard interop path for out-of-process agents.

```swift
import ACPCore

// Build an initialize request that a host sends to open a connection.
let req = InitializeRequest(
    protocolVersion: .latest,
    clientCapabilities: ClientCapabilities(),
    clientInfo: Implementation(name: "MyHost", version: "1.0")
)

// Inspect the protocol version the host proposes.
print(req.protocolVersion.value) // 1
```

## Topics

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

### Prompting

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

### Wire Envelopes

- ``AgentRequest``
- ``ClientRequest``
- ``AgentResponse``
- ``ClientResponse``
- ``AgentNotification``
- ``ClientNotification``

### Method Registry

- ``ACPMethod``

### Support Types

- ``ACPCoreSchema``
- ``MaybeUndefined``
- ``Meta``
