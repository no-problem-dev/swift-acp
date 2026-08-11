/// The `"jsonrpc"` field every JSON-RPC 2.0 message must carry.
///
/// Modelled as an enum with one case so the value cannot be wrong on the way out, and so a message
/// declaring any other version fails to decode rather than being processed as 2.0.
public enum JSONRPCVersion: String, Codable, Sendable {
    case v2 = "2.0"
}

/// A request: an id the peer must echo, a method name, and optional parameters.
public struct JSONRPCRequest<Params: Codable & Sendable>: Codable, Sendable {
    public var jsonrpc: JSONRPCVersion
    public var id: RequestId
    public var method: String
    public var params: Params?

    public init(id: RequestId, method: String, params: Params? = nil) {
        self.jsonrpc = .v2
        self.id = id
        self.method = method
        self.params = params
    }
}

/// A notification: a method name and optional parameters, with no id and therefore no reply.
///
/// A failure while handling one cannot be reported back to the sender.
public struct JSONRPCNotification<Params: Codable & Sendable>: Codable, Sendable {
    public var jsonrpc: JSONRPCVersion
    public var method: String
    public var params: Params?

    public init(method: String, params: Params? = nil) {
        self.jsonrpc = .v2
        self.method = method
        self.params = params
    }
}

/// A response, carrying either a result or an error, matched to its request by `id`.
///
/// Decoding checks `error` first: a message carrying both fields — which JSON-RPC forbids — is read
/// as a failure and the result is dropped.
public enum JSONRPCResponse<Result: Codable & Sendable>: Codable, Sendable {
    case success(id: RequestId, result: Result)
    case failure(id: RequestId, error: RPCError)

    private enum CodingKeys: String, CodingKey {
        case jsonrpc, id, result, error
    }

    public var id: RequestId {
        switch self {
        case let .success(id, _), let .failure(id, _): id
        }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(RequestId.self, forKey: .id)
        if let error = try container.decodeIfPresent(RPCError.self, forKey: .error) {
            self = .failure(id: id, error: error)
        } else {
            self = .success(id: id, result: try container.decode(Result.self, forKey: .result))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(JSONRPCVersion.v2, forKey: .jsonrpc)
        switch self {
        case let .success(id, result):
            try container.encode(id, forKey: .id)
            try container.encode(result, forKey: .result)
        case let .failure(id, error):
            try container.encode(id, forKey: .id)
            try container.encode(error, forKey: .error)
        }
    }
}
