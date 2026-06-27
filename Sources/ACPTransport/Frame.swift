import Foundation
import ACPCore

/// A classified incoming JSON-RPC frame.
///
/// The codec produces one of these values for every frame received over the
/// transport. A dispatch loop matches on the case to route requests,
/// notifications, and correlated responses.
public enum JSONRPCFrame: Sendable {
    case request(id: RequestId, method: String, params: JSONValue?)
    case notification(method: String, params: JSONValue?)
    case success(id: RequestId, result: JSONValue)
    case failure(id: RequestId, error: RPCError)
}

/// Encodes and decodes JSON-RPC frames over `Data`, bridging the typed ACP
/// payloads and the wire.
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

    /// Classify one received frame.
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

    /// Convert a typed payload to the `JSONValue` form carried as `params`/`result`.
    ///
    /// Round-trips the value through JSON encoding, producing a `JSONValue`
    /// tree that can be embedded in a JSON-RPC frame.
    public func jsonValue(from payload: some Encodable) throws -> JSONValue {
        try decoder.decode(JSONValue.self, from: try encoder.encode(payload))
    }

    /// Decode a typed payload from a `params`/`result` `JSONValue`.
    public func decodePayload<T: Decodable>(_ type: T.Type, from value: JSONValue?) throws -> T {
        try decoder.decode(T.self, from: try encoder.encode(value ?? .null))
    }

    /// Encode a JSON-RPC request frame.
    public func encodeRequest(id: RequestId, method: String, params: JSONValue?) throws -> Data {
        try encoder.encode(JSONRPCRequest(id: id, method: method, params: params))
    }

    /// Encode a JSON-RPC notification frame (no id, no reply expected).
    public func encodeNotification(method: String, params: JSONValue?) throws -> Data {
        try encoder.encode(JSONRPCNotification(method: method, params: params))
    }

    /// Encode a successful JSON-RPC response frame.
    public func encodeSuccess(id: RequestId, result: JSONValue) throws -> Data {
        try encoder.encode(JSONRPCResponse.success(id: id, result: result))
    }

    /// Encode a JSON-RPC error response frame.
    public func encodeFailure(id: RequestId, error: RPCError) throws -> Data {
        try encoder.encode(JSONRPCResponse<JSONValue>.failure(id: id, error: error))
    }
}
