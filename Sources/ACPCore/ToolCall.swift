/// The category of tool being invoked, used by clients to pick icons and UI.
///
/// Open: an unrecognised kind decodes as itself; `.other` is the default.
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

/// The execution status of a tool call. `.pending` is the default.
public struct ToolCallStatus: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }

    public static let pending = ToolCallStatus("pending")
    public static let inProgress = ToolCallStatus("in_progress")
    public static let completed = ToolCallStatus("completed")
    public static let failed = ToolCallStatus("failed")
}

/// Identifier for a terminal created with `terminal/create`.
///
/// Inlined as a string in the wire schema (not a standalone `$defs` entry).
public struct TerminalId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// A diff representing file modifications, for display in the client UI.
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

/// A reference to an existing terminal embedded in tool call content.
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

/// A file location accessed or modified by a tool, for "follow-along" features.
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

/// Content produced by a tool call: a content block, a diff, or a terminal.
///
/// Internally tagged on `type`; an unrecognised `type` is preserved as
/// `.unknown`.
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

/// A tool call the language model has requested the agent to perform.
///
/// `kind`, `status`, and the `content`/`locations` collections are omitted on
/// the wire when they hold their default (empty) value, matching the reference
/// implementation.
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

/// An update to an existing tool call. All fields except the id are optional —
/// only the changed fields are included. (`ToolCallUpdateFields` is flattened
/// onto this object in the wire schema.)
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
