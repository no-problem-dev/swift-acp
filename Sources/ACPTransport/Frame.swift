import Foundation
import ACPCore

/// An incoming frame, classified into the four things it can be.
///
/// Classification is by field presence, not by a type tag: a method with an id is a request, a
/// method without one is a notification, and a frame with no method is a response — a failure if it
/// carries `error`, a success otherwise.
///
/// One consequence: a request whose id is JSON `null` is indistinguishable from an absent id and is
/// classified as a notification, so it is answered by nothing.
public enum JSONRPCFrame: Sendable {
    case request(id: RequestId, method: String, params: JSONValue?)
    case notification(method: String, params: JSONValue?)
    case success(id: RequestId, result: JSONValue)
    case failure(id: RequestId, error: RPCError)
}

/// Encodes and decodes frames, and converts between typed ACP payloads and the untyped `JSONValue`
/// that rides inside them.
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

    /// Classifies one incoming frame.
    ///
    /// - Throws: A decoding error if the bytes are not JSON, or if the object matches none of the
    ///   four shapes — which includes a response whose id is `null`.
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

    /// Converts a typed payload into the `JSONValue` tree a frame carries.
    ///
    /// Goes through an encode-then-decode round trip, so this is not free — it is the price of
    /// keeping the frame types free of generics over the payload.
    public func jsonValue(from payload: some Encodable) throws -> JSONValue {
        try decoder.decode(JSONValue.self, from: try encoder.encode(payload))
    }

    /// Decodes a typed payload out of a frame's `params` or `result`.
    ///
    /// A `nil` value is treated as JSON `null`, so a type that cannot decode from null throws here
    /// rather than reporting a missing parameter.
    public func decodePayload<T: Decodable>(_ type: T.Type, from value: JSONValue?) throws -> T {
        try decoder.decode(T.self, from: try encoder.encode(value ?? .null))
    }

    /// Encodes a request frame.
    public func encodeRequest(id: RequestId, method: String, params: JSONValue?) throws -> Data {
        try encoder.encode(JSONRPCRequest(id: id, method: method, params: params))
    }

    /// Encodes a notification frame, which carries no id and expects no reply.
    public func encodeNotification(method: String, params: JSONValue?) throws -> Data {
        try encoder.encode(JSONRPCNotification(method: method, params: params))
    }

    /// Encodes a successful response frame.
    public func encodeSuccess(id: RequestId, result: JSONValue) throws -> Data {
        try encoder.encode(JSONRPCResponse.success(id: id, result: result))
    }

    /// Encodes a failed response frame.
    public func encodeFailure(id: RequestId, error: RPCError) throws -> Data {
        try encoder.encode(JSONRPCResponse<JSONValue>.failure(id: id, error: error))
    }
}
