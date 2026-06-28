# ``ACPClient``

ホストがエージェントにファイルシステム・ターミナルケーパビリティを提供し、ストリーミングセッション更新を受信するためのプロトコル。

## Overview

`ACPClient` は Agent Client Protocol の**クライアント側**を定義する：エージェントがホストにコールバックし得るメソッドのセット。ホストは通常、エディタ・モバイルアプリ・ユーザー向け UI を管理する CLI。`ACPClient` に準拠することで任意のホストを `ACPTransport` が提供するトランスポート層に接続できる。

プロトコルは 3 つの関心事に整理される。更新チャネルメソッド（`sessionUpdate(_:)`）が最も重要で、エージェントが `prompt` ターン中のすべてのストリーミング進捗通知でこれを呼び出し、ホストはリアルタイムでユーザーに描画する。ファイルシステムメソッド（`writeTextFile`・`readTextFile`）はホストのファイルシステムをエージェントに公開し、ホストは `initialize` 中に `ClientCapabilities` でサポートを通知する。ターミナルメソッド（`createTerminal`・`terminalOutput`・`releaseTerminal`・`waitForTerminalExit`・`killTerminal`）はエージェントに監視付きシェルを与える。パーミッションゲーティング（`requestPermission`）はツール呼び出しの実行前にホストが承認・拒否できるようにする。拡張メソッド（`ext`・`extNotification`）は仕様外追加を処理する。

ファイルシステムやターミナルを提供せずに更新を観察するだけのホストには、`ACPTransport` の `StreamingSessionClient` を直接使える。これが妥当なデフォルトでプロトコルを実装する。

```swift
import ACPCore
import ACPClient

// 更新を配列に収集するだけの最小観察者クライアント。
actor CollectingClient: ACPClient {
    private(set) var received: [SessionUpdate] = []

    func sessionUpdate(_ notification: SessionNotification) async throws {
        received.append(notification.update)
    }

    func requestPermission(_ r: RequestPermissionRequest) async throws -> RequestPermissionResponse {
        fatalError("permissions not supported")
    }

    // ファイルシステム・ターミナルメソッドはここに実装する（このスタブでは未サポート）。
    func writeTextFile(_ r: WriteTextFileRequest) async throws -> WriteTextFileResponse { fatalError() }
    func readTextFile(_ r: ReadTextFileRequest) async throws -> ReadTextFileResponse { fatalError() }
    func createTerminal(_ r: CreateTerminalRequest) async throws -> CreateTerminalResponse { fatalError() }
    func terminalOutput(_ r: TerminalOutputRequest) async throws -> TerminalOutputResponse { fatalError() }
    func releaseTerminal(_ r: ReleaseTerminalRequest) async throws -> ReleaseTerminalResponse { fatalError() }
    func waitForTerminalExit(_ r: WaitForTerminalExitRequest) async throws -> WaitForTerminalExitResponse { fatalError() }
    func killTerminal(_ r: KillTerminalRequest) async throws -> KillTerminalResponse { fatalError() }
    func ext(_ r: ExtRequest) async throws -> ExtResponse { fatalError() }
    func extNotification(_ n: ExtNotification) async throws {}
}
```

## Topics

### ロール契約

- ``ACPClient``
