/// What a session has cost so far, in whatever currency the agent reports.
public struct Cost: ACPSchemaType {
    public var amount: Double
    public var currency: String

    public init(amount: Double, currency: String) {
        self.amount = amount
        self.currency = currency
    }
}

/// How much of the context window is used and what the session has cost.
public struct UsageUpdate: ACPSchemaType {
    public var used: UInt64
    public var size: UInt64
    public var cost: Cost?
    public var meta: Meta?

    public init(used: UInt64, size: UInt64, cost: Cost? = nil, meta: Meta? = nil) {
        self.used = used
        self.size = size
        self.cost = cost
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case used, size, cost
        case meta = "_meta"
    }
}

/// Announces that the active mode changed — including when the agent changed it itself.
public struct CurrentModeUpdate: ACPSchemaType {
    public var currentModeId: SessionModeId
    public var meta: Meta?

    public init(currentModeId: SessionModeId, meta: Meta? = nil) {
        self.currentModeId = currentModeId
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case currentModeId
        case meta = "_meta"
    }
}

/// Announces the configuration options as they now stand.
public struct ConfigOptionUpdate: ACPSchemaType {
    public var configOptions: [SessionConfigOption]
    public var meta: Meta?

    public init(configOptions: [SessionConfigOption], meta: Meta? = nil) {
        self.configOptions = configOptions
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case configOptions
        case meta = "_meta"
    }
}

/// Revises a session's metadata.
///
/// `title` and `updatedAt` are three-state: absent leaves the field alone, `null` clears it, and a
/// value sets it. Encoding omits the key entirely for the absent case, which is what keeps "leave
/// alone" distinct from "clear".
public struct SessionInfoUpdate: ACPSchemaType {
    public var title: MaybeUndefined<String>
    public var updatedAt: MaybeUndefined<String>
    public var meta: Meta?

    public init(
        title: MaybeUndefined<String> = .undefined,
        updatedAt: MaybeUndefined<String> = .undefined,
        meta: Meta? = nil
    ) {
        self.title = title
        self.updatedAt = updatedAt
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case title, updatedAt
        case meta = "_meta"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = container.contains(.title)
            ? try container.decode(MaybeUndefined<String>.self, forKey: .title)
            : .undefined
        updatedAt = container.contains(.updatedAt)
            ? try container.decode(MaybeUndefined<String>.self, forKey: .updatedAt)
            : .undefined
        meta = try container.decodeIfPresent(Meta.self, forKey: .meta)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !title.isUndefined { try container.encode(title, forKey: .title) }
        if !updatedAt.isUndefined { try container.encode(updatedAt, forKey: .updatedAt) }
        try container.encodeIfPresent(meta, forKey: .meta)
    }
}

/// One thing that happened during a turn: a message chunk, a thought, a plan, a tool call, or a
/// change to the session itself.
///
/// Tagged by a `sessionUpdate` member. An unrecognized tag decodes to `.unknown` holding the
/// original JSON, so a host on an older revision can still render what it understands and pass the
/// rest through untouched.
public enum SessionUpdate: ACPSchemaType {
    case userMessageChunk(ContentChunk)
    case agentMessageChunk(ContentChunk)
    case agentThoughtChunk(ContentChunk)
    case toolCall(ToolCall)
    case toolCallUpdate(ToolCallUpdate)
    case plan(Plan)
    case availableCommandsUpdate(AvailableCommandsUpdate)
    case currentModeUpdate(CurrentModeUpdate)
    case configOptionUpdate(ConfigOptionUpdate)
    case sessionInfoUpdate(SessionInfoUpdate)
    case usageUpdate(UsageUpdate)
    case unknown(sessionUpdate: String, raw: JSONValue)

    private enum DiscriminatorKey: String, CodingKey { case sessionUpdate }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: DiscriminatorKey.self)
        switch try container.decode(String.self, forKey: .sessionUpdate) {
        case "user_message_chunk": self = .userMessageChunk(try ContentChunk(from: decoder))
        case "agent_message_chunk": self = .agentMessageChunk(try ContentChunk(from: decoder))
        case "agent_thought_chunk": self = .agentThoughtChunk(try ContentChunk(from: decoder))
        case "tool_call": self = .toolCall(try ToolCall(from: decoder))
        case "tool_call_update": self = .toolCallUpdate(try ToolCallUpdate(from: decoder))
        case "plan": self = .plan(try Plan(from: decoder))
        case "available_commands_update": self = .availableCommandsUpdate(try AvailableCommandsUpdate(from: decoder))
        case "current_mode_update": self = .currentModeUpdate(try CurrentModeUpdate(from: decoder))
        case "config_option_update": self = .configOptionUpdate(try ConfigOptionUpdate(from: decoder))
        case "session_info_update": self = .sessionInfoUpdate(try SessionInfoUpdate(from: decoder))
        case "usage_update": self = .usageUpdate(try UsageUpdate(from: decoder))
        case let tag: self = .unknown(sessionUpdate: tag, raw: try JSONValue(from: decoder))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .userMessageChunk(value): try encodeTagged(value, "user_message_chunk", to: encoder)
        case let .agentMessageChunk(value): try encodeTagged(value, "agent_message_chunk", to: encoder)
        case let .agentThoughtChunk(value): try encodeTagged(value, "agent_thought_chunk", to: encoder)
        case let .toolCall(value): try encodeTagged(value, "tool_call", to: encoder)
        case let .toolCallUpdate(value): try encodeTagged(value, "tool_call_update", to: encoder)
        case let .plan(value): try encodeTagged(value, "plan", to: encoder)
        case let .availableCommandsUpdate(value): try encodeTagged(value, "available_commands_update", to: encoder)
        case let .currentModeUpdate(value): try encodeTagged(value, "current_mode_update", to: encoder)
        case let .configOptionUpdate(value): try encodeTagged(value, "config_option_update", to: encoder)
        case let .sessionInfoUpdate(value): try encodeTagged(value, "session_info_update", to: encoder)
        case let .usageUpdate(value): try encodeTagged(value, "usage_update", to: encoder)
        case let .unknown(_, raw): try raw.encode(to: encoder)
        }
    }

    private func encodeTagged(_ payload: some Encodable, _ tag: String, to encoder: any Encoder) throws {
        try payload.encode(to: encoder)
        var container = encoder.container(keyedBy: DiscriminatorKey.self)
        try container.encode(tag, forKey: .sessionUpdate)
    }
}

/// The envelope one update travels in: the session it concerns, and the update itself.
public struct SessionNotification: ACPSchemaType {
    public var sessionId: SessionId
    public var update: SessionUpdate
    public var meta: Meta?

    public init(sessionId: SessionId, update: SessionUpdate, meta: Meta? = nil) {
        self.sessionId = sessionId
        self.update = update
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId, update
        case meta = "_meta"
    }
}
