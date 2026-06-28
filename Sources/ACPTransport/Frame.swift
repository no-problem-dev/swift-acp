import Foundation
import ACPCore

/// 分類済みの受信 JSON-RPC フレーム。
///
/// コーデックがトランスポートから受信したフレームごとにこの値を生成する。
/// ディスパッチループがケースにマッチしてリクエスト・通知・対応するレスポンスをルーティングする。
public enum JSONRPCFrame: Sendable {
    case request(id: RequestId, method: String, params: JSONValue?)
    case notification(method: String, params: JSONValue?)
    case success(id: RequestId, result: JSONValue)
    case failure(id: RequestId, error: RPCError)
}

/// `Data` 上で JSON-RPC フレームを符号化・復号するコーデック。型付き ACP ペイロードとワイヤーを橋渡しする。
public struct JSONRPCCodec: Sendable {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init() {}

    private struct RawFrame: Decodable {
        var id: RequestId?
        var method: String?
        var params: JSONValue?
        var result: JSONValue?
        var error: RPCError?
    }

    /// 受信したフレームを 1 件分類する。
    public func decode(_ data: Data) throws -> JSONRPCFrame {
        let raw = try decoder.decode(RawFrame.self, from: data)
        switch (raw.method, raw.id, raw.error) {
        case let (method?, id?, _):
            return .request(id: id, method: method, params: raw.params)
        case let (method?, nil, _):
            return .notification(method: method, params: raw.params)
        case let (nil, id?, error?):
            return .failure(id: id, error: error)
        case let (nil, id?, nil):
            return .success(id: id, result: raw.result ?? .null)
        default:
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "not a valid JSON-RPC frame")
            )
        }
    }

    /// 型付きペイロードを `params`/`result` として運ぶ `JSONValue` 形式に変換する。
    ///
    /// JSON 符号化を経由してラウンドトリップし、JSON-RPC フレームに埋め込める `JSONValue` ツリーを生成する。
    public func jsonValue(from payload: some Encodable) throws -> JSONValue {
        try decoder.decode(JSONValue.self, from: try encoder.encode(payload))
    }

    /// `params`/`result` の `JSONValue` から型付きペイロードをデコードする。
    public func decodePayload<T: Decodable>(_ type: T.Type, from value: JSONValue?) throws -> T {
        try decoder.decode(T.self, from: try encoder.encode(value ?? .null))
    }

    /// JSON-RPC リクエストフレームを符号化する。
    public func encodeRequest(id: RequestId, method: String, params: JSONValue?) throws -> Data {
        try encoder.encode(JSONRPCRequest(id: id, method: method, params: params))
    }

    /// JSON-RPC 通知フレームを符号化する（id なし・応答不要）。
    public func encodeNotification(method: String, params: JSONValue?) throws -> Data {
        try encoder.encode(JSONRPCNotification(method: method, params: params))
    }

    /// 成功した JSON-RPC レスポンスフレームを符号化する。
    public func encodeSuccess(id: RequestId, result: JSONValue) throws -> Data {
        try encoder.encode(JSONRPCResponse.success(id: id, result: result))
    }

    /// JSON-RPC エラーレスポンスフレームを符号化する。
    public func encodeFailure(id: RequestId, error: RPCError) throws -> Data {
        try encoder.encode(JSONRPCResponse<JSONValue>.failure(id: id, error: error))
    }
}
