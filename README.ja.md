# swift-acp

[English](./README.md) | 日本語

[Agent Client Protocol](https://agentclientprotocol.com) の Swift 実装。エディタ・ホストとエージェントを繋ぐ JSON-RPC の標準。

> **非公式。** Agent Client Protocol の作者とは何の関係もなく、承認も受けていない。仕様に準拠することはこのプロジェクトの目標ではない。

![Swift 6.0+](https://img.shields.io/badge/Swift-6.0+-orange.svg)
![ACP v1](https://img.shields.io/badge/ACP-schema%200.13.6%20%2F%20v1-green.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2016+%20%7C%20macOS%2013+%20%7C%20tvOS%2016+%20%7C%20watchOS%209+%20%7C%20visionOS%201+-blue.svg)
![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)

## 特徴

- **ワイヤースキーマをバージョン固定で同梱** — `$defs` の各エントリにモデル型があること・メソッド表がレジストリと一致すること・同梱のワイヤーサンプルがラウンドトリップすることをテストで確かめている。各チェックが何を見て何を見ていないかは [Architecture](https://no-problem-dev.github.io/swift-acp/documentation/acpcore/architecture) に書いてある
- **トランスポートは 2 つ、エージェントは 1 つ** — ロールコントラクトに対して一度書けば、同一プロセスで直列化なしにも、stdio 経由の JSON-RPC でも動く
- **前方互換が構造で担保される** — オープンな文字列列挙と `unknown` ケースにより、新しいリビジョンの相手が来てもデコードは壊れず、未知の値はそのまま再エンコードされる
- **コーディングエージェント専用ではない** — コアは「プロンプト → 更新をストリーム → キャンセル」。ファイルシステムとターミナルはホストが貸し出す任意のケーパビリティ
- **層をターゲットで分離** — ワイヤー型だけ、ロールコントラクトだけ、トランスポートまで、必要な分だけ取れる。アンブレラなし
- **標準ライブラリ以外の依存なし**

## クイックスタート

同一プロセス、直列化なし：

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

stdio 経由で、任意の ACP クライアントと相互運用：

```swift
let connection = AgentConnection(transport: StdioTransport())
await connection.start { client in MyAgent(client: client) }
try await connection.run()
```

## ドキュメント

ライブラリごとに DocC ページがある：

- [ACPCore](https://no-problem-dev.github.io/swift-acp/documentation/acpcore/) — ドメイン型。層構成とテストが見ている範囲は [Architecture](https://no-problem-dev.github.io/swift-acp/documentation/acpcore/architecture)
- [ACPJSONRPC](https://no-problem-dev.github.io/swift-acp/documentation/acpjsonrpc/) — エンベロープ
- [ACPAgent](https://no-problem-dev.github.io/swift-acp/documentation/acpagent/) · [ACPClient](https://no-problem-dev.github.io/swift-acp/documentation/acpclient/) — 2 つのロールコントラクト
- [ACPTransport](https://no-problem-dev.github.io/swift-acp/documentation/acptransport/) — 両者の接続

## インストール

`Package.swift` に追加する：

```swift
dependencies: [
    .package(url: "https://github.com/no-problem-dev/swift-acp.git", from: "0.1.0")
]
```

必要な product をターゲットに足す：

```swift
.target(name: "YourTarget", dependencies: [
    .product(name: "ACPTransport", package: "swift-acp"),   // トランスポート＋ロールコントラクト＋型
    // .product(name: "ACPCore", package: "swift-acp"),     // ドメイン型のみ
])
```

## 動作環境

| swift-acp | Swift | プラットフォーム | ACP |
|---|---|---|---|
| 0.x | 6.0+ | iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+ | schema 0.13.6 / protocol v1 |

テストは `swift test` で回る。

## ライセンス

Apache-2.0（参照プロトコルに合わせる）。[LICENSE](LICENSE) を参照。
