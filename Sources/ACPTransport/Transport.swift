import Foundation
import ACPCore

/// JSON-RPC メッセージフレームの双方向トランスポートプロトコル。
///
/// stdio アダプタ（および任意のネットワークアダプタ）が使用する直列化境界。
/// インプロセスパスは意図的にこれを経由しない——そこでは ACP 型が符号化なしに Swift 値として受け渡される（`InProcessConnection` 参照）。
public protocol ACPMessageTransport: Sendable {
    /// 符号化済みの JSON-RPC メッセージフレームを 1 件送信する。
    func send(_ frame: Data) async throws

    /// 受信する JSON-RPC メッセージフレームのストリーム（1 要素 = 1 フレーム）。
    func messages() -> AsyncThrowingStream<Data, any Error>
}

/// トランスポート層が送出するエラー。
public enum ACPTransportError: Error, Equatable, Sendable {
    /// 対向が実装していないメソッドを送信してきた。
    case methodNotSupported(String)
    /// 保留中でないリクエスト ID に対するレスポンスが到着した。
    case unexpectedResponse(RequestId)
    /// 保留中のリクエストが完了する前にトランスポートがクローズされた。
    case closed
}
