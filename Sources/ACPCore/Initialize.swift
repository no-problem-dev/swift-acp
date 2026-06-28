/// プロトコルバージョン識別子。
///
/// 裸の整数として直列化される。破壊的変更時のみインクリメントし、非破壊的変更はケーパビリティで導入する。
public struct ProtocolVersion: ACPSchemaType {
    public var value: UInt16

    public init(value: UInt16) { self.value = value }

    public static let v1 = ProtocolVersion(value: 1)
    public static let latest = ProtocolVersion.v1

    public init(from decoder: any Decoder) throws {
        value = try decoder.singleValueContainer().decode(UInt16.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

/// クライアントまたはエージェントの実装に関するメタデータ。
public struct Implementation: ACPSchemaType {
    public var name: String
    public var title: String?
    public var version: String
    public var meta: Meta?

    public init(name: String, version: String, title: String? = nil, meta: Meta? = nil) {
        self.name = name
        self.title = title
        self.version = version
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case name, title, version
        case meta = "_meta"
    }
}

/// エージェントが `session/prompt` リクエストでサポートするプロンプトケーパビリティ。
///
/// ブールフラグはワイヤー上で常に存在する（デフォルト `false`）。
public struct PromptCapabilities: ACPSchemaType {
    public var image: Bool
    public var audio: Bool
    public var embeddedContext: Bool
    public var meta: Meta?

    public init(
        image: Bool = false,
        audio: Bool = false,
        embeddedContext: Bool = false,
        meta: Meta? = nil
    ) {
        self.image = image
        self.audio = audio
        self.embeddedContext = embeddedContext
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case image, audio, embeddedContext
        case meta = "_meta"
    }
}

/// エージェントがサポートする MCP ケーパビリティ。
public struct McpCapabilities: ACPSchemaType {
    public var http: Bool
    public var sse: Bool
    public var meta: Meta?

    public init(http: Bool = false, sse: Bool = false, meta: Meta? = nil) {
        self.http = http
        self.sse = sse
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case http, sse
        case meta = "_meta"
    }
}

/// `session/list` メソッドのケーパビリティ。存在（`{}`）がサポートを示す。
public struct SessionListCapabilities: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// `session/delete` メソッドのケーパビリティ。存在（`{}`）がサポートを示す。
public struct SessionDeleteCapabilities: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// 追加セッションディレクトリのサポートケーパビリティ。存在（`{}`）がサポートを示す。
public struct SessionAdditionalDirectoriesCapabilities: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// `session/resume` メソッドのケーパビリティ。存在（`{}`）がサポートを示す。
public struct SessionResumeCapabilities: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// `session/close` メソッドのケーパビリティ。存在（`{}`）がサポートを示す。
public struct SessionCloseCapabilities: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// エージェントがサポートするセッションケーパビリティ。オプションのサブケーパビリティは存在（`{}`）でサポートを示し、省略または `null` は未サポートを意味する。
public struct SessionCapabilities: ACPSchemaType {
    public var list: SessionListCapabilities?
    public var delete: SessionDeleteCapabilities?
    public var additionalDirectories: SessionAdditionalDirectoriesCapabilities?
    public var resume: SessionResumeCapabilities?
    public var close: SessionCloseCapabilities?
    public var meta: Meta?

    public init(
        list: SessionListCapabilities? = nil,
        delete: SessionDeleteCapabilities? = nil,
        additionalDirectories: SessionAdditionalDirectoriesCapabilities? = nil,
        resume: SessionResumeCapabilities? = nil,
        close: SessionCloseCapabilities? = nil,
        meta: Meta? = nil
    ) {
        self.list = list
        self.delete = delete
        self.additionalDirectories = additionalDirectories
        self.resume = resume
        self.close = close
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case list, delete, additionalDirectories, resume, close
        case meta = "_meta"
    }
}

/// エージェントがサポートするログアウトケーパビリティ。存在（`{}`）がサポートを示す。
public struct LogoutCapabilities: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// エージェントがサポートする認証関連のケーパビリティ。
public struct AgentAuthCapabilities: ACPSchemaType {
    public var logout: LogoutCapabilities?
    public var meta: Meta?

    public init(logout: LogoutCapabilities? = nil, meta: Meta? = nil) {
        self.logout = logout
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case logout
        case meta = "_meta"
    }
}

/// 初期化時にエージェントが通知するケーパビリティ。
public struct AgentCapabilities: ACPSchemaType {
    public var loadSession: Bool
    public var promptCapabilities: PromptCapabilities
    public var mcpCapabilities: McpCapabilities
    public var sessionCapabilities: SessionCapabilities
    public var auth: AgentAuthCapabilities
    public var meta: Meta?

    public init(
        loadSession: Bool = false,
        promptCapabilities: PromptCapabilities = .init(),
        mcpCapabilities: McpCapabilities = .init(),
        sessionCapabilities: SessionCapabilities = .init(),
        auth: AgentAuthCapabilities = .init(),
        meta: Meta? = nil
    ) {
        self.loadSession = loadSession
        self.promptCapabilities = promptCapabilities
        self.mcpCapabilities = mcpCapabilities
        self.sessionCapabilities = sessionCapabilities
        self.auth = auth
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case loadSession, promptCapabilities, mcpCapabilities, sessionCapabilities, auth
        case meta = "_meta"
    }
}

/// `initialize` メソッドのリクエストパラメータ。
public struct InitializeRequest: ACPSchemaType {
    public var protocolVersion: ProtocolVersion
    public var clientCapabilities: ClientCapabilities
    public var clientInfo: Implementation?
    public var meta: Meta?

    public init(
        protocolVersion: ProtocolVersion,
        clientCapabilities: ClientCapabilities = .init(),
        clientInfo: Implementation? = nil,
        meta: Meta? = nil
    ) {
        self.protocolVersion = protocolVersion
        self.clientCapabilities = clientCapabilities
        self.clientInfo = clientInfo
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case protocolVersion, clientCapabilities, clientInfo
        case meta = "_meta"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        protocolVersion = try container.decode(ProtocolVersion.self, forKey: .protocolVersion)
        clientCapabilities = try container.decodeIfPresent(ClientCapabilities.self, forKey: .clientCapabilities) ?? .init()
        clientInfo = try container.decodeIfPresent(Implementation.self, forKey: .clientInfo)
        meta = try container.decodeIfPresent(Meta.self, forKey: .meta)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(protocolVersion, forKey: .protocolVersion)
        try container.encode(clientCapabilities, forKey: .clientCapabilities)
        try container.encodeIfPresent(clientInfo, forKey: .clientInfo)
        try container.encodeIfPresent(meta, forKey: .meta)
    }
}

/// `initialize` メソッドへのレスポンス。
public struct InitializeResponse: ACPSchemaType {
    public var protocolVersion: ProtocolVersion
    public var agentCapabilities: AgentCapabilities
    public var authMethods: [AuthMethod]
    public var agentInfo: Implementation?
    public var meta: Meta?

    public init(
        protocolVersion: ProtocolVersion,
        agentCapabilities: AgentCapabilities = .init(),
        authMethods: [AuthMethod] = [],
        agentInfo: Implementation? = nil,
        meta: Meta? = nil
    ) {
        self.protocolVersion = protocolVersion
        self.agentCapabilities = agentCapabilities
        self.authMethods = authMethods
        self.agentInfo = agentInfo
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case protocolVersion, agentCapabilities, authMethods, agentInfo
        case meta = "_meta"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        protocolVersion = try container.decode(ProtocolVersion.self, forKey: .protocolVersion)
        agentCapabilities = try container.decodeIfPresent(AgentCapabilities.self, forKey: .agentCapabilities) ?? .init()
        authMethods = try container.decodeIfPresent([AuthMethod].self, forKey: .authMethods) ?? []
        agentInfo = try container.decodeIfPresent(Implementation.self, forKey: .agentInfo)
        meta = try container.decodeIfPresent(Meta.self, forKey: .meta)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(protocolVersion, forKey: .protocolVersion)
        try container.encode(agentCapabilities, forKey: .agentCapabilities)
        try container.encode(authMethods, forKey: .authMethods)
        try container.encodeIfPresent(agentInfo, forKey: .agentInfo)
        try container.encodeIfPresent(meta, forKey: .meta)
    }
}
