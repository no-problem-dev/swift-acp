/// What kind of thing a tool does, so a client can pick an icon and a presentation.
///
/// Open: an unrecognized kind decodes unchanged. `.other` is the value to use when none fits.
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

/// Where a tool call stands. A call starts pending and is expected to reach completed or failed.
/// Open: unknown values decode unchanged.
public struct ToolCallStatus: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }

    public static let pending = ToolCallStatus("pending")
    public static let inProgress = ToolCallStatus("in_progress")
    public static let completed = ToolCallStatus("completed")
    public static let failed = ToolCallStatus("failed")
}

/// Identifies a terminal created by `terminal/create`.
///
/// Defined inline as a string in the wire schema rather than as its own `$defs` entry, which is why
/// it is absent from the schema-coverage registry.
public struct TerminalId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// A file change, as before-and-after text for the client to render. `oldText` is absent for a new
/// file.
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

/// Points a tool call's output at a terminal the client already created, rather than repeating its
/// output.
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

/// A place in a file the tool touched, so a client can follow along in an editor.
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

/// What a tool call produced: content, a diff, or a terminal to watch.
///
/// Tagged by a `type` member. An unrecognized type decodes to `.unknown` holding the original JSON,
/// so it survives a round trip.
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

/// A tool call the model asked the agent to make, reported so the client can show it.
///
/// `kind`, `status`, `content` and `locations` are omitted from the wire at their default or empty
/// values, matching the reference implementation.
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

/// A revision to a tool call already reported, carrying only what changed.
///
/// Everything but `toolCallId` is optional, and absent means unchanged rather than cleared. The
/// updatable fields are flattened into this object on the wire rather than nested.
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
