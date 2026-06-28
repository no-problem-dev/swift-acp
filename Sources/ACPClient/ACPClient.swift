import ACPCore

/// Agent Client Protocol のクライアント側コントラクト。クライアント（ホスト：エディタ・iOS アプリ・進捗 UI 等）が
/// エージェントに提供するケーパビリティと `session/update` 通知の受信を定義する。
///
/// v1 ワイヤー型に対するトランスポート非依存・UI 非依存の振る舞いコントラクト。
/// 安定した v1 メソッドのみを含む。クライアントはファイルシステム・ターミナルメソッドのどれをサポートするかを
/// `ClientCapabilities` で通知する。
public protocol ACPClient: Sendable {
    /// ツール呼び出しのユーザー承認を求め、結果を返す。
    func requestPermission(
        _ request: RequestPermissionRequest
    ) async throws -> RequestPermissionResponse

    /// クライアントのファイルシステムにテキストファイルを書き込む。
    func writeTextFile(_ request: WriteTextFileRequest) async throws -> WriteTextFileResponse

    /// クライアントのファイルシステムからテキストファイルを読み取る。
    func readTextFile(_ request: ReadTextFileRequest) async throws -> ReadTextFileResponse

    /// ターミナルを作成してコマンドを実行する。
    func createTerminal(_ request: CreateTerminalRequest) async throws -> CreateTerminalResponse

    /// ターミナルの現在の出力と終了ステータスを取得する。
    func terminalOutput(_ request: TerminalOutputRequest) async throws -> TerminalOutputResponse

    /// ターミナルを解放してリソースを開放する。
    func releaseTerminal(_ request: ReleaseTerminalRequest) async throws -> ReleaseTerminalResponse

    /// ターミナルのコマンドが終了するまで待機する。
    func waitForTerminalExit(
        _ request: WaitForTerminalExitRequest
    ) async throws -> WaitForTerminalExitResponse

    /// ターミナルを解放せずにコマンドをキルする。
    func killTerminal(_ request: KillTerminalRequest) async throws -> KillTerminalResponse

    /// エージェントからのストリーミングセッション更新を受信する（通知のみ・応答なし）。ホストが描画する進捗チャネル。
    func sessionUpdate(_ notification: SessionNotification) async throws

    /// 仕様外の拡張リクエストを処理する。
    func ext(_ request: ExtRequest) async throws -> ExtResponse

    /// 仕様外の拡張通知を処理する。
    func extNotification(_ notification: ExtNotification) async throws
}
