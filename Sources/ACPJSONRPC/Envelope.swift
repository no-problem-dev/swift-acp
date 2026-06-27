/// The JSON-RPC protocol version sentinel.
///
/// The JSON-RPC 2.0 specification requires every message to include a
/// `"jsonrpc": "2.0"` field. This enum models that single known value and
/// ensures it round-trips correctly.
public enum JSONRPCVersion: String, Codable, Sendable {
    case v2 = "2.0"
}

/// A JSON-RPC request: an `id`, a `method`, and optional typed `params`.
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

/// A JSON-RPC notification: a `method` and optional typed `params`, with no id
/// and no response.
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

/// A JSON-RPC response: either a typed `result` or an `error`, correlated to a
/// request by `id`.
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
