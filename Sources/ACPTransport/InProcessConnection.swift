import ACPCore
import ACPAgent
import ACPClient

/// エージェントとホストを同一プロセス内で、直列化なしに接続するチャネル。
///
/// ホストは `ACPAgent` プロトコルを直接使ってエージェントを駆動し、
/// エージェントは `client.sessionUpdate(_:)` を呼び出して進捗を報告し、
/// ホストはその更新を `AsyncStream` として消費する。JSON-RPC ワイヤーは関与せず、
/// 型付き Swift 値がそのまま受け渡される。
///
/// ```swift
/// let connection = InProcessConnection { client in
///     MyResearchAgent(client: client)   // エージェントは client を通じて進捗を報告する
/// }
/// Task {
///     for await update in connection.updates { render(update) }
/// }
/// _ = try await connection.agent.prompt(promptRequest)
/// connection.finish()
/// ```
public struct InProcessConnection: Sendable {
    /// `ACPAgent` コントラクトを通じて直接駆動されるエージェント。
    public let agent: any ACPAgent

    /// エージェントに渡される観察クライアント。
    public let client: StreamingSessionClient

    /// エージェントのセッション更新ストリーム（進捗チャネル）。
    public var updates: AsyncStream<SessionNotification> { client.updates }

    /// - Parameters:
    ///   - onPermission: ホスト側のパーミッションリクエストへの応答方法。
    ///   - makeAgent: エージェントを構築するクロージャ。報告先のクライアントを受け取る。
    public init(
        onPermission: @escaping @Sendable (RequestPermissionRequest) async throws -> RequestPermissionResponse = { _ in
            throw ACPTransportError.methodNotSupported(ACPMethod.Client.sessionRequestPermission)
        },
        makeAgent: (any ACPClient) -> any ACPAgent
    ) {
        let client = StreamingSessionClient(onPermission: onPermission)
        self.client = client
        agent = makeAgent(client)
    }

    /// 会話終了後に更新ストリームをクローズする。
    public func finish() {
        client.finish()
    }
}
