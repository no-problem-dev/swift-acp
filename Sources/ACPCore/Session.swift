/// Request parameters for creating a new session.
///
/// `additionalDirectories` is omitted on the wire when empty.
public struct NewSessionRequest: ACPSchemaType {
    public var cwd: String
    public var additionalDirectories: [String]
    public var mcpServers: [McpServer]
    public var meta: Meta?

    public init(
        cwd: String,
        mcpServers: [McpServer] = [],
        additionalDirectories: [String] = [],
        meta: Meta? = nil
    ) {
        self.cwd = cwd
        self.additionalDirectories = additionalDirectories
        self.mcpServers = mcpServers
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case cwd, additionalDirectories, mcpServers
        case meta = "_meta"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cwd = try container.decode(String.self, forKey: .cwd)
        additionalDirectories = try container.decodeIfPresent([String].self, forKey: .additionalDirectories) ?? []
        mcpServers = try container.decode([McpServer].self, forKey: .mcpServers)
        meta = try container.decodeIfPresent(Meta.self, forKey: .meta)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cwd, forKey: .cwd)
        if !additionalDirectories.isEmpty {
            try container.encode(additionalDirectories, forKey: .additionalDirectories)
        }
        try container.encode(mcpServers, forKey: .mcpServers)
        try container.encodeIfPresent(meta, forKey: .meta)
    }
}

/// Response from creating a new session.
public struct NewSessionResponse: ACPSchemaType {
    public var sessionId: SessionId
    public var modes: SessionModeState?
    public var configOptions: [SessionConfigOption]?
    public var meta: Meta?

    public init(
        sessionId: SessionId,
        modes: SessionModeState? = nil,
        configOptions: [SessionConfigOption]? = nil,
        meta: Meta? = nil
    ) {
        self.sessionId = sessionId
        self.modes = modes
        self.configOptions = configOptions
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId, modes, configOptions
        case meta = "_meta"
    }
}

/// Request parameters for loading an existing session.
///
/// `additionalDirectories` is omitted on the wire when empty.
public struct LoadSessionRequest: ACPSchemaType {
    public var mcpServers: [McpServer]
    public var cwd: String
    public var additionalDirectories: [String]
    public var sessionId: SessionId
    public var meta: Meta?

    public init(
        sessionId: SessionId,
        cwd: String,
        mcpServers: [McpServer] = [],
        additionalDirectories: [String] = [],
        meta: Meta? = nil
    ) {
        self.mcpServers = mcpServers
        self.cwd = cwd
        self.additionalDirectories = additionalDirectories
        self.sessionId = sessionId
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case mcpServers, cwd, additionalDirectories, sessionId
        case meta = "_meta"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mcpServers = try container.decode([McpServer].self, forKey: .mcpServers)
        cwd = try container.decode(String.self, forKey: .cwd)
        additionalDirectories = try container.decodeIfPresent([String].self, forKey: .additionalDirectories) ?? []
        sessionId = try container.decode(SessionId.self, forKey: .sessionId)
        meta = try container.decodeIfPresent(Meta.self, forKey: .meta)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mcpServers, forKey: .mcpServers)
        try container.encode(cwd, forKey: .cwd)
        if !additionalDirectories.isEmpty {
            try container.encode(additionalDirectories, forKey: .additionalDirectories)
        }
        try container.encode(sessionId, forKey: .sessionId)
        try container.encodeIfPresent(meta, forKey: .meta)
    }
}

/// Response from loading an existing session.
public struct LoadSessionResponse: ACPSchemaType {
    public var modes: SessionModeState?
    public var configOptions: [SessionConfigOption]?
    public var meta: Meta?

    public init(
        modes: SessionModeState? = nil,
        configOptions: [SessionConfigOption]? = nil,
        meta: Meta? = nil
    ) {
        self.modes = modes
        self.configOptions = configOptions
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case modes, configOptions
        case meta = "_meta"
    }
}

/// Request parameters for listing existing sessions. `cwd`/`cursor` are
/// nullable filters; omitted and `null` are equivalent.
public struct ListSessionsRequest: ACPSchemaType {
    public var cwd: String?
    public var cursor: String?
    public var meta: Meta?

    public init(cwd: String? = nil, cursor: String? = nil, meta: Meta? = nil) {
        self.cwd = cwd
        self.cursor = cursor
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case cwd, cursor
        case meta = "_meta"
    }
}

/// Response from listing sessions.
public struct ListSessionsResponse: ACPSchemaType {
    public var sessions: [SessionInfo]
    public var nextCursor: String?
    public var meta: Meta?

    public init(sessions: [SessionInfo], nextCursor: String? = nil, meta: Meta? = nil) {
        self.sessions = sessions
        self.nextCursor = nextCursor
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case sessions, nextCursor
        case meta = "_meta"
    }
}

/// Request parameters for resuming an existing session.
///
/// `additionalDirectories` and `mcpServers` are omitted on the wire when empty.
public struct ResumeSessionRequest: ACPSchemaType {
    public var sessionId: SessionId
    public var cwd: String
    public var additionalDirectories: [String]
    public var mcpServers: [McpServer]
    public var meta: Meta?

    public init(
        sessionId: SessionId,
        cwd: String,
        additionalDirectories: [String] = [],
        mcpServers: [McpServer] = [],
        meta: Meta? = nil
    ) {
        self.sessionId = sessionId
        self.cwd = cwd
        self.additionalDirectories = additionalDirectories
        self.mcpServers = mcpServers
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId, cwd, additionalDirectories, mcpServers
        case meta = "_meta"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sessionId = try container.decode(SessionId.self, forKey: .sessionId)
        cwd = try container.decode(String.self, forKey: .cwd)
        additionalDirectories = try container.decodeIfPresent([String].self, forKey: .additionalDirectories) ?? []
        mcpServers = try container.decodeIfPresent([McpServer].self, forKey: .mcpServers) ?? []
        meta = try container.decodeIfPresent(Meta.self, forKey: .meta)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sessionId, forKey: .sessionId)
        try container.encode(cwd, forKey: .cwd)
        if !additionalDirectories.isEmpty {
            try container.encode(additionalDirectories, forKey: .additionalDirectories)
        }
        if !mcpServers.isEmpty { try container.encode(mcpServers, forKey: .mcpServers) }
        try container.encodeIfPresent(meta, forKey: .meta)
    }
}

/// Response from resuming an existing session.
public struct ResumeSessionResponse: ACPSchemaType {
    public var modes: SessionModeState?
    public var configOptions: [SessionConfigOption]?
    public var meta: Meta?

    public init(
        modes: SessionModeState? = nil,
        configOptions: [SessionConfigOption]? = nil,
        meta: Meta? = nil
    ) {
        self.modes = modes
        self.configOptions = configOptions
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case modes, configOptions
        case meta = "_meta"
    }
}

/// Request parameters for deleting an existing session from `session/list`.
public struct DeleteSessionRequest: ACPSchemaType {
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

/// Response from deleting a session.
public struct DeleteSessionResponse: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// Request parameters for closing an active session.
public struct CloseSessionRequest: ACPSchemaType {
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

/// Response from closing a session.
public struct CloseSessionResponse: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// Information about a session returned by `session/list`.
///
/// `additionalDirectories` is omitted on the wire when empty.
public struct SessionInfo: ACPSchemaType {
    public var sessionId: SessionId
    public var cwd: String
    public var additionalDirectories: [String]
    public var title: String?
    public var updatedAt: String?
    public var meta: Meta?

    public init(
        sessionId: SessionId,
        cwd: String,
        additionalDirectories: [String] = [],
        title: String? = nil,
        updatedAt: String? = nil,
        meta: Meta? = nil
    ) {
        self.sessionId = sessionId
        self.cwd = cwd
        self.additionalDirectories = additionalDirectories
        self.title = title
        self.updatedAt = updatedAt
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId, cwd, additionalDirectories, title, updatedAt
        case meta = "_meta"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sessionId = try container.decode(SessionId.self, forKey: .sessionId)
        cwd = try container.decode(String.self, forKey: .cwd)
        additionalDirectories = try container.decodeIfPresent([String].self, forKey: .additionalDirectories) ?? []
        title = try container.decodeIfPresent(String.self, forKey: .title)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        meta = try container.decodeIfPresent(Meta.self, forKey: .meta)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sessionId, forKey: .sessionId)
        try container.encode(cwd, forKey: .cwd)
        if !additionalDirectories.isEmpty {
            try container.encode(additionalDirectories, forKey: .additionalDirectories)
        }
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(meta, forKey: .meta)
    }
}

/// A mode the agent can operate in.
public struct SessionMode: ACPSchemaType {
    public var id: SessionModeId
    public var name: String
    public var description: String?
    public var meta: Meta?

    public init(id: SessionModeId, name: String, description: String? = nil, meta: Meta? = nil) {
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

/// The set of modes the agent can operate in and the one currently active.
public struct SessionModeState: ACPSchemaType {
    public var currentModeId: SessionModeId
    public var availableModes: [SessionMode]
    public var meta: Meta?

    public init(currentModeId: SessionModeId, availableModes: [SessionMode], meta: Meta? = nil) {
        self.currentModeId = currentModeId
        self.availableModes = availableModes
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case currentModeId, availableModes
        case meta = "_meta"
    }
}

/// Request parameters for setting a session mode.
public struct SetSessionModeRequest: ACPSchemaType {
    public var sessionId: SessionId
    public var modeId: SessionModeId
    public var meta: Meta?

    public init(sessionId: SessionId, modeId: SessionModeId, meta: Meta? = nil) {
        self.sessionId = sessionId
        self.modeId = modeId
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId, modeId
        case meta = "_meta"
    }
}

/// Response to the `session/set_mode` method.
public struct SetSessionModeResponse: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}
