/// セッション設定オプションのセマンティックカテゴリ（UX 用途のみ）。
///
/// オープン列挙：未知のカテゴリはそのままデコードされる。`_` で始まる名前はカスタム用途に自由に使え、それ以外は ACP 仕様に予約される。
public struct SessionConfigOptionCategory: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }

    public static let mode = SessionConfigOptionCategory("mode")
    public static let model = SessionConfigOptionCategory("model")
    public static let thoughtLevel = SessionConfigOptionCategory("thought_level")
}

/// セッション設定オプションの候補値。
public struct SessionConfigSelectOption: ACPSchemaType {
    public var value: SessionConfigValueId
    public var name: String
    public var description: String?
    public var meta: Meta?

    public init(
        value: SessionConfigValueId,
        name: String,
        description: String? = nil,
        meta: Meta? = nil
    ) {
        self.value = value
        self.name = name
        self.description = description
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case value, name, description
        case meta = "_meta"
    }
}

/// セッション設定オプションの候補値グループ。
public struct SessionConfigSelectGroup: ACPSchemaType {
    public var group: SessionConfigGroupId
    public var name: String
    public var options: [SessionConfigSelectOption]
    public var meta: Meta?

    public init(
        group: SessionConfigGroupId,
        name: String,
        options: [SessionConfigSelectOption],
        meta: Meta? = nil
    ) {
        self.group = group
        self.name = name
        self.options = options
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case group, name, options
        case meta = "_meta"
    }
}

/// セッション設定オプションの候補値（タグなし：フラットなオプションリストまたはグループリスト）。
public enum SessionConfigSelectOptions: ACPSchemaType {
    case ungrouped([SessionConfigSelectOption])
    case grouped([SessionConfigSelectGroup])

    public init(from decoder: any Decoder) throws {
        if let value = try? [SessionConfigSelectOption](from: decoder) {
            self = .ungrouped(value)
        } else {
            self = .grouped(try [SessionConfigSelectGroup](from: decoder))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .ungrouped(value): try value.encode(to: encoder)
        case let .grouped(value): try value.encode(to: encoder)
        }
    }
}

/// 単一値セレクタ（ドロップダウン）のセッション設定オプションペイロード。
public struct SessionConfigSelect: ACPSchemaType {
    public var currentValue: SessionConfigValueId
    public var options: SessionConfigSelectOptions

    public init(currentValue: SessionConfigValueId, options: SessionConfigSelectOptions) {
        self.currentValue = currentValue
        self.options = options
    }
}

/// セッション設定オプションのセレクタと現在の状態。
///
/// 型固有のペイロードがこのオブジェクトにフラット化され `type` で判別される。
/// 安定した種別は `select` のみ。未知の `type` は `.unknown` として保持する。
public struct SessionConfigOption: ACPSchemaType {
    /// 設定オプションの型固有フィールド。
    public enum Kind: Equatable, Sendable {
        case select(SessionConfigSelect)
        case unknown(type: String, raw: JSONValue)
    }

    public var id: SessionConfigId
    public var name: String
    public var description: String?
    public var category: SessionConfigOptionCategory?
    public var kind: Kind
    public var meta: Meta?

    public init(
        id: SessionConfigId,
        name: String,
        kind: Kind,
        description: String? = nil,
        category: SessionConfigOptionCategory? = nil,
        meta: Meta? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.kind = kind
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, description, category, type
        case meta = "_meta"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(SessionConfigId.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        category = try container.decodeIfPresent(SessionConfigOptionCategory.self, forKey: .category)
        meta = try container.decodeIfPresent(Meta.self, forKey: .meta)
        switch try container.decode(String.self, forKey: .type) {
        case "select": kind = .select(try SessionConfigSelect(from: decoder))
        case let type: kind = .unknown(type: type, raw: try JSONValue(from: decoder))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch kind {
        case let .select(value): try value.encode(to: encoder)
        case let .unknown(_, raw): try raw.encode(to: encoder)
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(category, forKey: .category)
        switch kind {
        case .select: try container.encode("select", forKey: .type)
        case let .unknown(type, _): try container.encode(type, forKey: .type)
        }
        try container.encodeIfPresent(meta, forKey: .meta)
    }
}

/// セッション設定オプションを設定するリクエストパラメータ。
public struct SetSessionConfigOptionRequest: ACPSchemaType {
    public var sessionId: SessionId
    public var configId: SessionConfigId
    public var value: SessionConfigValueId
    public var meta: Meta?

    public init(
        sessionId: SessionId,
        configId: SessionConfigId,
        value: SessionConfigValueId,
        meta: Meta? = nil
    ) {
        self.sessionId = sessionId
        self.configId = configId
        self.value = value
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId, configId, value
        case meta = "_meta"
    }
}

/// `session/set_config_option` メソッドへのレスポンス。
public struct SetSessionConfigOptionResponse: ACPSchemaType {
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
