/// ACP 仕様外の任意のリクエスト。
///
/// `method` は JSON-RPC エンベロープ経由でアウトオブバンドに運ばれ（ルーティング用・非シリアル化）、
/// ワイヤー上には `params` のみが存在する。したがってこの型は `params` 値として透過的に符号化される。
public struct ExtRequest: ACPSchemaType {
    public var method: String
    public var params: JSONValue

    public init(method: String, params: JSONValue) {
        self.method = method
        self.params = params
    }

    public init(from decoder: any Decoder) throws {
        method = ""
        params = try JSONValue(from: decoder)
    }

    public func encode(to encoder: any Encoder) throws {
        try params.encode(to: encoder)
    }

    public static func == (lhs: ExtRequest, rhs: ExtRequest) -> Bool {
        lhs.params == rhs.params
    }
}

/// ACP 仕様外の任意のリクエスト（`ExtRequest`）へのレスポンス。
///
/// `params` 値として透過的に符号化される。
public struct ExtResponse: ACPSchemaType {
    public var params: JSONValue

    public init(params: JSONValue) { self.params = params }

    public init(from decoder: any Decoder) throws {
        params = try JSONValue(from: decoder)
    }

    public func encode(to encoder: any Encoder) throws {
        try params.encode(to: encoder)
    }
}

/// ACP 仕様外の任意の一方向通知。
///
/// `method` は JSON-RPC エンベロープ経由でアウトオブバンドに運ばれ（ルーティング用・非シリアル化）、
/// ワイヤー上には `params` のみが存在する。したがってこの型は `params` 値として透過的に符号化される。
public struct ExtNotification: ACPSchemaType {
    public var method: String
    public var params: JSONValue

    public init(method: String, params: JSONValue) {
        self.method = method
        self.params = params
    }

    public init(from decoder: any Decoder) throws {
        method = ""
        params = try JSONValue(from: decoder)
    }

    public func encode(to encoder: any Encoder) throws {
        try params.encode(to: encoder)
    }

    public static func == (lhs: ExtNotification, rhs: ExtNotification) -> Bool {
        lhs.params == rhs.params
    }
}

/// セッションの進行中操作をキャンセルする通知。
public struct CancelNotification: ACPSchemaType {
    public var sessionId: SessionId
    public var meta: Meta?

    public init(sessionId: SessionId, meta: Meta? = nil) {
        self.sessionId = sessionId
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId
        case meta = "_meta"
    }
}
