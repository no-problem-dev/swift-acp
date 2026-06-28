/// JSON-RPC プロトコルバージョンを示す sentinel 値。
///
/// JSON-RPC 2.0 仕様はすべてのメッセージに `"jsonrpc": "2.0"` フィールドを要求する。
/// この enum は唯一の既知値をモデル化し、正しくラウンドトリップすることを保証する。
public enum JSONRPCVersion: String, Codable, Sendable {
    case v2 = "2.0"
}

/// JSON-RPC リクエスト。`id`・`method`・省略可能な型付き `params` を持つ。
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

/// JSON-RPC 通知。`method` と省略可能な型付き `params` を持ち、`id` も応答もない。
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

/// JSON-RPC レスポンス。型付き `result` またはエラーを持ち、`id` でリクエストと対応付ける。
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
