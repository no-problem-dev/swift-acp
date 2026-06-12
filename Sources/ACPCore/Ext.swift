/// An arbitrary request that is not part of the ACP spec.
///
/// `method` is carried out-of-band by the JSON-RPC envelope (used for routing,
/// not serialized); only `params` is on the wire, so this type encodes
/// transparently as its `params` value.
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

/// An arbitrary response to an [`ExtRequest`] that is not part of the ACP spec.
///
/// Encodes transparently as its `params` value.
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

/// An arbitrary one-way notification that is not part of the ACP spec.
///
/// `method` is carried out-of-band by the JSON-RPC envelope (used for routing,
/// not serialized); only `params` is on the wire, so this type encodes
/// transparently as its `params` value.
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

/// Notification to cancel ongoing operations for a session.
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
