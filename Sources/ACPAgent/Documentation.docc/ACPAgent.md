# ``ACPAgent``

ACP 準拠エージェントが実装しなければならないプロトコル——v1 メソッドセットに対するトランスポート非依存 Swift コントラクト。

## Overview

`ACPAgent` は Agent Client Protocol の**エージェント側**を定義する：クライアントがエージェントに呼び出し得るメソッドの全セット。`ACPAgent` に準拠することが `ACPTransport` に接続される唯一の要件であり、stdio・インプロセスチャネル・任意のトランスポートで動作する。

プロトコルは 4 つの論理グループに分かれる。ハンドシェイクメソッド（`initialize`・`authenticate`・`logout`）はプロトコルバージョンを交渉しケーパビリティを交換して認証を管理する。セッションライフサイクルメソッド（`newSession`・`loadSession`・`listSessions`・`resumeSession`・`deleteSession`・`closeSession`・`setSessionMode`・`setSessionConfigOption`）はクライアントが名前付き永続会話を管理できるようにする。プロンプトメソッド（`prompt`）はエージェント推論の 1 ターンを駆動し、エージェントは `ACPClient.sessionUpdate(_:)` を通じてストリーミング進捗をクライアントにプッシュする。拡張メソッド（`ext`・`extNotification`・`cancel`）はキャンセルと仕様外追加を処理する。

すべてのメソッドは `async throws`。特定のケーパビリティをサポートしないエージェントは `ACPTransportError.methodNotSupported(_:)` をスローしてトランスポートに明示的に通知できる。

```swift
import ACPCore
import ACPAgent

struct EchoAgent: ACPAgent {
    func initialize(_ request: InitializeRequest) async throws -> InitializeResponse {
        InitializeResponse(
            protocolVersion: .latest,
            agentCapabilities: AgentCapabilities(),
            authMethods: []
        )
    }

    func prompt(_ request: PromptRequest) async throws -> PromptResponse {
        PromptResponse(stopReason: .endTurn)
    }

    // 残りのメソッドは省略——実際の最小スタブでは各メソッドがスローする。
    func authenticate(_ r: AuthenticateRequest) async throws -> AuthenticateResponse { fatalError() }
    func newSession(_ r: NewSessionRequest) async throws -> NewSessionResponse { fatalError() }
    func loadSession(_ r: LoadSessionRequest) async throws -> LoadSessionResponse { fatalError() }
    func listSessions(_ r: ListSessionsRequest) async throws -> ListSessionsResponse { fatalError() }
    func resumeSession(_ r: ResumeSessionRequest) async throws -> ResumeSessionResponse { fatalError() }
    func deleteSession(_ r: DeleteSessionRequest) async throws -> DeleteSessionResponse { fatalError() }
    func closeSession(_ r: CloseSessionRequest) async throws -> CloseSessionResponse { fatalError() }
    func setSessionMode(_ r: SetSessionModeRequest) async throws -> SetSessionModeResponse { fatalError() }
    func setSessionConfigOption(_ r: SetSessionConfigOptionRequest) async throws -> SetSessionConfigOptionResponse { fatalError() }
    func cancel(_ n: CancelNotification) async throws {}
    func logout(_ r: LogoutRequest) async throws -> LogoutResponse { fatalError() }
    func ext(_ r: ExtRequest) async throws -> ExtResponse { fatalError() }
    func extNotification(_ n: ExtNotification) async throws {}
}
```

## Topics

### ロール契約

- ``ACPAgent``
