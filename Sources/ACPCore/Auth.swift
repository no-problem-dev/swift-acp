/// The authentication method where the agent handles credentials itself — the default when a
/// method carries no type.
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

/// One way to authenticate, as advertised during initialization.
///
/// Tagged by a `type` member, whose absence means `agent`. An unrecognized type decodes to
/// `.unknown` holding the original JSON, so it survives a round trip.
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

/// Names the method to authenticate with — one the agent advertised.
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

/// The reply to authentication, carrying nothing but `_meta`.
public struct AuthenticateResponse: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// Ends the authenticated session with the agent.
public struct LogoutRequest: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// The reply to a logout, carrying nothing but `_meta`.
public struct LogoutResponse: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}
