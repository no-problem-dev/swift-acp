# ``ACPJSONRPC``

JSON-RPC 2.0 エンベロープ型と、`swift-acp` パッケージ全体のドメイン型を支える `ACPSchemaType` 準拠コントラクト。

## Overview

`ACPJSONRPC` は `swift-acp` 依存グラフの最底層。他のすべてのモジュールが直接または推移的にこれに依存し、`ACPCore` が再エクスポートするため、大半のユーザーは `import ACPCore` 1 文で JSON-RPC プリミティブをスコープに取り込める。

このモジュールは 3 種類の型を提供する。第 1 に、汎用 JSON-RPC 2.0 エンベロープ構造体 `JSONRPCRequest`・`JSONRPCNotification`・`JSONRPCResponse` は、任意のトランスポートで型付きペイロードを運ぶ。`JSONRPCVersion` は各エンベロープでプロトコルリビジョンを識別する。

第 2 に、`JSONValue` は任意の JSON ノード（null・bool・number・string・array・object）をモデル化する再帰的 sum 型。拡張ペイロードや `_meta` ディクショナリなど、ACP スキーマがオープンエンドな JSON を許容する箇所で使用する。

第 3 に、`ACPSchemaType` は ACP ワイヤースキーマの各名前付き定義がちょうど 1 つの Swift 型に対応することを保証するプロトコル。準拠型はデフォルトの `schemaName` と、コンフォーマンステストスイートがロスレス符号化を検証するための `roundTripJSON(_:using:)` ヘルパーを得る。

```swift
import ACPJSONRPC

// JSONValue は任意の JSON をロスなく表現する。
let value: JSONValue = .object(["version": .number(1), "tag": .string("stable")])

// すべてのスキーマ型は JSON をラウンドトリップする。
let data = try JSONEncoder().encode(RequestId.number(42))
let copy = try JSONDecoder().decode(RequestId.self, from: data)
assert(copy == .number(42))
```

## Topics

### スキーマ契約

- ``ACPSchemaType``

### JSON プリミティブ

- ``JSONValue``

### リクエスト識別子

- ``RequestId``

### エンベロープ

- ``JSONRPCRequest``
- ``JSONRPCNotification``
- ``JSONRPCResponse``
- ``JSONRPCVersion``

### エラー

- ``RPCError``
- ``ErrorCode``

### スキーマレジストリ

- ``ACPJSONRPCSchema``
