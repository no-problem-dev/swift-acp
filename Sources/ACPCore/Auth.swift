/// Agent handles authentication itself. The default authentication method type.
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

/// An available authentication method.
///
/// Discriminated on `type`; when no `type` is present, the method is the
/// default `agent`. An unrecognised `type` is preserved as `.unknown`.
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

/// Request parameters for the `authenticate` method.
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

/// Response to the `authenticate` method.
public struct AuthenticateResponse: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// Request parameters for the `logout` method.
public struct LogoutRequest: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// Response to the `logout` method.
public struct LogoutResponse: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}
