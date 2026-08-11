/// A request for a method the specification does not define.
///
/// - Important: `method` is *not* part of this type's JSON. It travels in the JSON-RPC envelope,
///   and the value encodes as its `params` alone. Decoding therefore leaves `method` empty, and
///   equality ignores it — two extensions with the same params compare equal whatever they are
///   named.
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

/// The reply to an extension request.
///
/// Encodes as its `params` alone, with no wrapper.
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

/// A notification for a method the specification does not define. Has no reply.
///
/// - Important: `method` is *not* part of this type's JSON. It travels in the JSON-RPC envelope,
///   and the value encodes as its `params` alone. Decoding therefore leaves `method` empty, and
///   equality ignores it — two extensions with the same params compare equal whatever they are
///   named.
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

/// Asks the agent to stop the turn in progress. Has no reply — the turn's own response reports the
/// outcome, with a stop reason of cancelled.
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
