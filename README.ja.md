[English](./README.md) | 日本語

# swift-acp

[Agent Client Protocol](https://agentclientprotocol.com) (ACP)——エディタ・ホストとエージェントを接続する JSON-RPC 標準——のテスト駆動・完全準拠 Swift 実装。

適合対象: スキーマクレート **0.13.6 / protocol v1**（最新安定版）。すべての型はピン留めされた公式ワイヤースキーマ・リファレンスクレートの直列化ベクタ・メソッドレジストリに対して検証済み——仮定ではなく証明済み。

## なぜ ACP か

ACP のコア（`session/prompt` → ストリーミング `session/update`（プラン・思考・ツール呼び出し・パーミッションリクエスト）→ `session/cancel`）は、**ホストが単一エージェントの作業セッションを観察・操作するためのドメイン非依存なコントラクト**。ファイルシステム・ターミナルケーパビリティはオプションのクライアント側拡張なので、コーディング用途のエージェントだけでなく非コーディングエージェントの進捗・制御プレーンとしても同様に利用できる。トランスポートは交換可能な境界：インプロセスではメッセージが直列化なしに Swift 値として受け渡され、stdio 経由では JSON-RPC になる。

## ターゲット

| ターゲット | 役割 |
|---|---|
| `ACPJSONRPC` | JSON-RPC 2.0 エンベロープ（`RequestId`・`RPCError`・`ErrorCode`・`JSONValue`）、ACP から分離 |
| `ACPCore` | ACP v1 の 135 `$defs` を `Codable` 値型として実装——sum 型ユニオン・オープン文字列列挙・前方互換のための `unknown` ケース |
| `ACPAgent` | エージェントロールコントラクト（`protocol ACPAgent`） |
| `ACPClient` | クライアント/ホストロールコントラクト（`protocol ACPClient`） |
| `ACPTransport` | `InProcessConnection`（型付き・直列化なし）＋ `StdioTransport`/`AgentConnection`（JSON-RPC）＋ `StreamingSessionClient` |

## インプロセス（直列化なし）

```swift
import ACPTransport

let connection = InProcessConnection { client in
    MyResearchAgent(client: client)   // エージェントは client を通じて進捗を報告する
}

Task {
    for await update in connection.updates {   // UI が描画する進捗チャネル
        render(update)
    }
}

let response = try await connection.agent.prompt(promptRequest)
connection.finish()
```

## stdio 経由（相互運用）

```swift
let connection = AgentConnection(transport: StdioTransport())
await connection.start { client in MyAgent(client: client) }
try await connection.run()   // stdin/stdout 経由で任意の ACP クライアントにエージェントを提供する
```

## 準拠

`ACPConformanceTests` スイートは `Tests/ACPConformanceTests/Spec/v1` にバージョン固定された仕様に対して 3 つの独立した保証を施行する：

- **スキーマカバレッジ** — 135 個の `$defs` それぞれがちょうど 1 つのモデル型に対応する。
- **ゴールデンラウンドトリップ** — リファレンスクレートの `#[test]` アサーションから採取した 30 個のワイヤーサンプルがロスレスにデコード・再エンコードされる（フィールドレベルの準拠）。
- **メソッドパリティ** — Swift のメソッド名テーブルが `meta.json` と完全に一致する。

```
swift test
```

Apache-2.0（リファレンスプロトコルに準拠）。
