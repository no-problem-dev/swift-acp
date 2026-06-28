/// 呼び出すツールのカテゴリ。クライアントがアイコンや UI を選ぶために使用する。
///
/// オープン列挙：未知の種別はそのままデコードされる。デフォルトは `.other`。
public struct ToolKind: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }

    public static let read = ToolKind("read")
    public static let edit = ToolKind("edit")
    public static let delete = ToolKind("delete")
    public static let move = ToolKind("move")
    public static let search = ToolKind("search")
    public static let execute = ToolKind("execute")
    public static let think = ToolKind("think")
    public static let fetch = ToolKind("fetch")
    public static let switchMode = ToolKind("switch_mode")
    public static let other = ToolKind("other")
}

/// ツール呼び出しの実行ステータス。デフォルトは `.pending`。
public struct ToolCallStatus: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }

    public static let pending = ToolCallStatus("pending")
    public static let inProgress = ToolCallStatus("in_progress")
    public static let completed = ToolCallStatus("completed")
    public static let failed = ToolCallStatus("failed")
}

/// `terminal/create` で作成したターミナルの識別子。
///
/// ワイヤースキーマでは文字列としてインライン定義（独立した `$defs` エントリではない）。
public struct TerminalId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// クライアント UI 表示用のファイル変更差分。
public struct Diff: ACPSchemaType {
    public var path: String
    public var oldText: String?
    public var newText: String
    public var meta: Meta?

    public init(path: String, newText: String, oldText: String? = nil, meta: Meta? = nil) {
        self.path = path
        self.oldText = oldText
        self.newText = newText
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case path, oldText, newText
        case meta = "_meta"
    }
}

/// ツール呼び出しコンテンツに埋め込まれた既存ターミナルへの参照。
public struct Terminal: ACPSchemaType {
    public var terminalId: TerminalId
    public var meta: Meta?

    public init(terminalId: TerminalId, meta: Meta? = nil) {
        self.terminalId = terminalId
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case terminalId
        case meta = "_meta"
    }
}

/// ツールがアクセス・変更したファイル位置。"follow-along" 機能向け。
public struct ToolCallLocation: ACPSchemaType {
    public var path: String
    public var line: UInt32?
    public var meta: Meta?

    public init(path: String, line: UInt32? = nil, meta: Meta? = nil) {
        self.path = path
        self.line = line
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case path, line
        case meta = "_meta"
    }
}

/// ツール呼び出しが生成するコンテンツ：コンテンツブロック・差分・ターミナルのいずれか。
///
/// `type` フィールドで内部タグ付けされる。未知の `type` は `.unknown` として保持する。
public enum ToolCallContent: ACPSchemaType {
    case content(Content)
    case diff(Diff)
    case terminal(Terminal)
    case unknown(type: String, raw: JSONValue)

    private enum DiscriminatorKey: String, CodingKey { case type }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: DiscriminatorKey.self)
        switch try container.decode(String.self, forKey: .type) {
        case "content": self = .content(try Content(from: decoder))
        case "diff": self = .diff(try Diff(from: decoder))
        case "terminal": self = .terminal(try Terminal(from: decoder))
        case let other: self = .unknown(type: other, raw: try JSONValue(from: decoder))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .content(value): try encodeTagged(value, "content", to: encoder)
        case let .diff(value): try encodeTagged(value, "diff", to: encoder)
        case let .terminal(value): try encodeTagged(value, "terminal", to: encoder)
        case let .unknown(_, raw): try raw.encode(to: encoder)
        }
    }

    private func encodeTagged(_ payload: some Encodable, _ type: String, to encoder: any Encoder) throws {
        try payload.encode(to: encoder)
        var container = encoder.container(keyedBy: DiscriminatorKey.self)
        try container.encode(type, forKey: .type)
    }
}

/// 言語モデルがエージェントに実行を要求したツール呼び出し。
///
/// `kind`・`status`・`content`/`locations` コレクションはデフォルト（空）値のとき
/// ワイヤーから省略される（リファレンス実装に準拠）。
public struct ToolCall: ACPSchemaType {
    public var toolCallId: ToolCallId
    public var title: String
    public var kind: ToolKind
    public var status: ToolCallStatus
    public var content: [ToolCallContent]
    public var locations: [ToolCallLocation]
    public var rawInput: JSONValue?
    public var rawOutput: JSONValue?
    public var meta: Meta?

    public init(
        toolCallId: ToolCallId,
        title: String,
        kind: ToolKind = .other,
        status: ToolCallStatus = .pending,
        content: [ToolCallContent] = [],
        locations: [ToolCallLocation] = [],
        rawInput: JSONValue? = nil,
        rawOutput: JSONValue? = nil,
        meta: Meta? = nil
    ) {
        self.toolCallId = toolCallId
        self.title = title
        self.kind = kind
        self.status = status
        self.content = content
        self.locations = locations
        self.rawInput = rawInput
        self.rawOutput = rawOutput
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case toolCallId, title, kind, status, content, locations, rawInput, rawOutput
        case meta = "_meta"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        toolCallId = try container.decode(ToolCallId.self, forKey: .toolCallId)
        title = try container.decode(String.self, forKey: .title)
        kind = try container.decodeIfPresent(ToolKind.self, forKey: .kind) ?? .other
        status = try container.decodeIfPresent(ToolCallStatus.self, forKey: .status) ?? .pending
        content = try container.decodeIfPresent([ToolCallContent].self, forKey: .content) ?? []
        locations = try container.decodeIfPresent([ToolCallLocation].self, forKey: .locations) ?? []
        rawInput = try container.decodeIfPresent(JSONValue.self, forKey: .rawInput)
        rawOutput = try container.decodeIfPresent(JSONValue.self, forKey: .rawOutput)
        meta = try container.decodeIfPresent(Meta.self, forKey: .meta)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(toolCallId, forKey: .toolCallId)
        try container.encode(title, forKey: .title)
        if kind != .other { try container.encode(kind, forKey: .kind) }
        if status != .pending { try container.encode(status, forKey: .status) }
        if !content.isEmpty { try container.encode(content, forKey: .content) }
        if !locations.isEmpty { try container.encode(locations, forKey: .locations) }
        try container.encodeIfPresent(rawInput, forKey: .rawInput)
        try container.encodeIfPresent(rawOutput, forKey: .rawOutput)
        try container.encodeIfPresent(meta, forKey: .meta)
    }
}

/// 既存ツール呼び出しへの更新。`toolCallId` 以外のフィールドはすべて省略可能で、変化したフィールドのみを含む。
/// （`ToolCallUpdateFields` がこのオブジェクトにワイヤーレベルでフラット化されている。）
public struct ToolCallUpdate: ACPSchemaType {
    public var toolCallId: ToolCallId
    public var kind: ToolKind?
    public var status: ToolCallStatus?
    public var title: String?
    public var content: [ToolCallContent]?
    public var locations: [ToolCallLocation]?
    public var rawInput: JSONValue?
    public var rawOutput: JSONValue?
    public var meta: Meta?

    public init(
        toolCallId: ToolCallId,
        kind: ToolKind? = nil,
        status: ToolCallStatus? = nil,
        title: String? = nil,
        content: [ToolCallContent]? = nil,
        locations: [ToolCallLocation]? = nil,
        rawInput: JSONValue? = nil,
        rawOutput: JSONValue? = nil,
        meta: Meta? = nil
    ) {
        self.toolCallId = toolCallId
        self.kind = kind
        self.status = status
        self.title = title
        self.content = content
        self.locations = locations
        self.rawInput = rawInput
        self.rawOutput = rawOutput
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case toolCallId, kind, status, title, content, locations, rawInput, rawOutput
        case meta = "_meta"
    }
}
