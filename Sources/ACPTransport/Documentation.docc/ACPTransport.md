# ``ACPTransport``

`ACPAgent` と `ACPClient` の実装をインプロセスチャネルまたは JSON-RPC-over-stdio に接続する具体的なトランスポートアダプタ。

## Overview

`ACPTransport` は `swift-acp` 依存スタックの最上位。他の 4 モジュールすべてに依存し、`ACPAgent` と `ACPClient` の抽象ロールコントラクトを実際の通信チャネルに変換する。

2 つの接続スタイルを提供する。`InProcessConnection` はゼロコピー・ゼロ直列化パス：同一プロセスで `ACPAgent` と `StreamingSessionClient` を結合し、エージェントの進捗通知を `AsyncStream<SessionNotification>` として公開し、ホストが直接ターンを駆動できる。テスト・アプリへのエージェント埋め込み・両側が同一 Swift プロセスに存在する任意のシナリオに最適。

`AgentConnection` は直列化パス。任意の `ACPMessageTransport`（例: stdin/stdout で `Data` フレームを読み書きする `StdioTransport`）をラップし、完全な JSON-RPC ディスパッチループを実行する。受信するクライアントリクエストはメソッド名でデコードされて具体的な `ACPAgent` へディスパッチされ、レスポンスが符号化されて返送される。エージェントは `RemoteClient` プロキシを受け取り、`sessionUpdate`・`fs/*`・`terminal/*` などの呼び出しが同一トランスポート経由でマーシャリングされる。外部 ACP クライアントと相互運用が必要なエージェントの標準パス。

`JSONRPCFrame` と `JSONRPCCodec` は `AgentConnection` が内部で使用する下位レベルのフレーミングプリミティブで、符号化・復号層に直接アクセスする呼び出し元のために公開されている。

```swift
import ACPCore
import ACPTransport

// インプロセス: 直列化なし、Swift 値を直接受け渡す。
let conn = InProcessConnection { client in
    MyResearchAgent(client: client)
}

Task {
    for await notification in conn.updates {
        print(notification.update) // ストリーミング進捗を描画する
    }
}

let response = try await conn.agent.prompt(
    PromptRequest(sessionId: SessionId("s1"), prompt: [])
)
conn.finish()
```

## Topics

### インプロセスチャネル

- ``InProcessConnection``
- ``StreamingSessionClient``

### 直列化チャネル

- ``AgentConnection``
- ``StdioTransport``

### トランスポートプロトコル

- ``ACPMessageTransport``
- ``ACPTransportError``

### フレーミング

- ``JSONRPCFrame``
- ``JSONRPCCodec``
