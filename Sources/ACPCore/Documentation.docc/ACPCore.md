# ``ACPCore``

Agent Client Protocol (ACP) v1 の Swift 実装——共有ドメイン型・JSON-RPC プリミティブ・ACP 準拠エージェントとクライアントを構築するためのロールコントラクト。

## Overview

`swift-acp` パッケージは Agent Client Protocol の完全なテスト駆動 Swift サーフェスを提供する。ACP はエージェント（LLM ループ・オーケストレーター・その他の自律プロセス）とクライアント（エディタ・iOS アプリ・ホスト UI）の間の双方向 JSON-RPC 2.0 チャネルを定義する。このパッケージの 5 つのライブラリがサーフェスをフォーカスしたレイヤに分割する。

``ACPJSONRPC`` は基盤層。汎用 JSON-RPC 2.0 エンベロープ型（`JSONRPCRequest`・`JSONRPCResponse`・`JSONRPCNotification`）と、すべてのドメイン型が満たす `ACPSchemaType` 準拠プロトコルを提供する。`ACPCore` が `ACPJSONRPC` を再エクスポートするため、大半のユーザーは `import ACPCore` 1 文で足りる。

``ACPCore``（このモジュール）はすべての ACP ドメイン型を保持する：ピン留めされた v1 スキーマの忠実かつトランスポート非依存な Swift ミラー。型は純粋な `Codable` 値型で I/O を持たない。ハンドシェイク（`InitializeRequest`・`InitializeResponse`）・セッションライフサイクル（`NewSessionRequest`・`PromptRequest`）・ストリーミング更新（`SessionUpdate`・`SessionNotification`）・コンテンツブロック（`ContentBlock`・`TextContent`・`ImageContent`）・認証（`AuthMethod`・`AuthenticateRequest`）・ルーティングエンベロープ（`AgentRequest`・`ClientRequest` 等）を網羅する。

``ACPAgent`` と ``ACPClient`` は 2 つのロールコントラクトを Swift プロトコルとして公開する。具体的なエージェントは `ACPAgent` に準拠し、ホスト UI は `ACPClient` に準拠する。どちらのプロトコルもトランスポート非依存で、``ACPCore`` のドメイン値を直接操作する。

``ACPTransport`` はコントラクトを実際のチャネルに接続する。`InProcessConnection` はエージェントとクライアントを同一プロセスで直列化ゼロで稼働させる。`AgentConnection` は任意の `ACPMessageTransport`（例: `StdioTransport`）を適合させてプロセス外エージェントを JSON-RPC 経由で提供する。

```swift
import ACPCore

// ホストが接続を開くために送信する initialize リクエストを構築する。
let req = InitializeRequest(
    protocolVersion: .latest,
    clientCapabilities: ClientCapabilities(),
    clientInfo: Implementation(name: "MyHost", version: "1.0")
)

// ホストが提案するプロトコルバージョンを確認する。
print(req.protocolVersion.value) // 1
```

## Topics

### ハンドシェイク

- ``InitializeRequest``
- ``InitializeResponse``
- ``ProtocolVersion``
- ``Implementation``
- ``AgentCapabilities``
- ``ClientCapabilities``

### セッションライフサイクル

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

### プロンプト

- ``PromptRequest``
- ``PromptResponse``
- ``StopReason``

### セッション更新

- ``SessionNotification``
- ``SessionUpdate``
- ``ContentChunk``
- ``UsageUpdate``
- ``SessionInfoUpdate``

### コンテンツ

- ``ContentBlock``
- ``Content``
- ``TextContent``
- ``ImageContent``
- ``AudioContent``
- ``EmbeddedResource``
- ``ResourceLink``
- ``Role``
- ``Annotations``

### 認証

- ``AuthMethod``
- ``AuthMethodAgent``
- ``AuthenticateRequest``
- ``AuthenticateResponse``
- ``LogoutRequest``
- ``LogoutResponse``

### ワイヤーエンベロープ

- ``AgentRequest``
- ``ClientRequest``
- ``AgentResponse``
- ``ClientResponse``
- ``AgentNotification``
- ``ClientNotification``

### メソッドレジストリ

- ``ACPMethod``

### サポート型

- ``ACPCoreSchema``
- ``MaybeUndefined``
- ``Meta``
