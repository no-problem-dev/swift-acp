import ACPCore

/// Agent Client Protocol のエージェント側コントラクト。クライアントに駆動されるエージェントが実装するメソッドを定義する。
///
/// v1 ワイヤー型に対するトランスポート非依存・UI 非依存の振る舞いコントラクト。
/// 具体的なエージェント（LLM ループ・A2A オーケストレーター等）が準拠し、
/// トランスポートがこれを JSON-RPC またはインプロセスチャネルに適合させる。
/// 安定した v1 メソッドのみを含む。
public protocol ACPAgent: Sendable {
    /// プロトコルバージョンを交渉し、ケーパビリティを交換する。
    func initialize(_ request: InitializeRequest) async throws -> InitializeResponse

    /// 事前に通知された認証メソッドでエージェントと認証する。
    func authenticate(_ request: AuthenticateRequest) async throws -> AuthenticateResponse

    /// 新しいセッションを作成する。
    func newSession(_ request: NewSessionRequest) async throws -> NewSessionResponse

    /// 過去のセッションを履歴をロードして再開する。
    func loadSession(_ request: LoadSessionRequest) async throws -> LoadSessionResponse

    /// エージェントが認識しているセッションの一覧を取得する。
    func listSessions(_ request: ListSessionsRequest) async throws -> ListSessionsResponse

    /// セッションを再開して追加のプロンプトを受け付ける。
    func resumeSession(_ request: ResumeSessionRequest) async throws -> ResumeSessionResponse

    /// セッションとその履歴を削除する。
    func deleteSession(_ request: DeleteSessionRequest) async throws -> DeleteSessionResponse

    /// セッションを削除せずにクローズする。
    func closeSession(_ request: CloseSessionRequest) async throws -> CloseSessionResponse

    /// セッションの現在モードを切り替える。
    func setSessionMode(_ request: SetSessionModeRequest) async throws -> SetSessionModeResponse

    /// セッション設定オプションを設定する。
    func setSessionConfigOption(
        _ request: SetSessionConfigOptionRequest
    ) async throws -> SetSessionConfigOptionResponse

    /// プロンプトターンを実行する。エージェントは `session/update` 通知で進捗をストリームし、`StopReason` を返す。
    func prompt(_ request: PromptRequest) async throws -> PromptResponse

    /// セッションの進行中プロンプトターンをキャンセルする（通知のみ・応答なし）。
    func cancel(_ notification: CancelNotification) async throws

    /// エージェントの認証済みセッションを終了する。
    func logout(_ request: LogoutRequest) async throws -> LogoutResponse

    /// 仕様外の拡張リクエストを処理する。
    func ext(_ request: ExtRequest) async throws -> ExtResponse

    /// 仕様外の拡張通知を処理する。
    func extNotification(_ notification: ExtNotification) async throws
}
