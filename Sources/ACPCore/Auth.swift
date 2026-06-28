/// エージェント自身が認証を処理するデフォルトの認証メソッド型。
public struct AuthMethodAgent: ACPSchemaType {
    public var id: String
    public var name: String
    public var description: String?
    public var meta: Meta?

    public init(id: String, name: String, description: String? = nil, meta: Meta? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, description
        case meta = "_meta"
    }
}

/// 利用可能な認証メソッド。
///
/// `type` フィールドで判別される。`type` が存在しない場合はデフォルトの `agent` として扱う。
/// 未知の `type` は `.unknown` として保持する。
public enum AuthMethod: ACPSchemaType {
    case agent(AuthMethodAgent)
    case unknown(type: String, raw: JSONValue)

    private enum DiscriminatorKey: String, CodingKey { case type }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: DiscriminatorKey.self)
        let type = try container.decodeIfPresent(String.self, forKey: .type)
        switch type {
        case "agent", nil: self = .agent(try AuthMethodAgent(from: decoder))
        case let type?: self = .unknown(type: type, raw: try JSONValue(from: decoder))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .agent(value): try value.encode(to: encoder)
        case let .unknown(_, raw): try raw.encode(to: encoder)
        }
    }
}

/// `authenticate` メソッドのリクエストパラメータ。
public struct AuthenticateRequest: ACPSchemaType {
    public var methodId: String
    public var meta: Meta?

    public init(methodId: String, meta: Meta? = nil) {
        self.methodId = methodId
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case methodId
        case meta = "_meta"
    }
}

/// `authenticate` メソッドへのレスポンス。
public struct AuthenticateResponse: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// `logout` メソッドのリクエストパラメータ。
public struct LogoutRequest: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// `logout` メソッドへのレスポンス。
public struct LogoutResponse: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}
