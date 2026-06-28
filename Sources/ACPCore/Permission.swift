/// ユーザーに提示するパーミッションオプションの種別。
public struct PermissionOptionKind: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }

    public static let allowOnce = PermissionOptionKind("allow_once")
    public static let allowAlways = PermissionOptionKind("allow_always")
    public static let rejectOnce = PermissionOptionKind("reject_once")
    public static let rejectAlways = PermissionOptionKind("reject_always")
}

/// パーミッションリクエスト時にユーザーに提示するオプション。
public struct PermissionOption: ACPSchemaType {
    public var optionId: PermissionOptionId
    public var name: String
    public var kind: PermissionOptionKind
    public var meta: Meta?

    public init(optionId: PermissionOptionId, name: String, kind: PermissionOptionKind, meta: Meta? = nil) {
        self.optionId = optionId
        self.name = name
        self.kind = kind
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case optionId, name, kind
        case meta = "_meta"
    }
}

/// ツール呼び出し実行のためのユーザーパーミッションリクエスト。
public struct RequestPermissionRequest: ACPSchemaType {
    public var sessionId: SessionId
    public var toolCall: ToolCallUpdate
    public var options: [PermissionOption]
    public var meta: Meta?

    public init(
        sessionId: SessionId,
        toolCall: ToolCallUpdate,
        options: [PermissionOption],
        meta: Meta? = nil
    ) {
        self.sessionId = sessionId
        self.toolCall = toolCall
        self.options = options
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId, toolCall, options
        case meta = "_meta"
    }
}

/// ユーザーが提示されたパーミッションオプションを選択した結果。
public struct SelectedPermissionOutcome: ACPSchemaType {
    public var optionId: PermissionOptionId
    public var meta: Meta?

    public init(optionId: PermissionOptionId, meta: Meta? = nil) {
        self.optionId = optionId
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case optionId
        case meta = "_meta"
    }
}

/// パーミッションリクエストの結果。`outcome` フィールドで内部タグ付けされる。
public enum RequestPermissionOutcome: ACPSchemaType {
    case cancelled
    case selected(SelectedPermissionOutcome)
    case unknown(outcome: String, raw: JSONValue)

    private enum DiscriminatorKey: String, CodingKey { case outcome }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: DiscriminatorKey.self)
        switch try container.decode(String.self, forKey: .outcome) {
        case "cancelled": self = .cancelled
        case "selected": self = .selected(try SelectedPermissionOutcome(from: decoder))
        case let outcome: self = .unknown(outcome: outcome, raw: try JSONValue(from: decoder))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case .cancelled:
            var container = encoder.container(keyedBy: DiscriminatorKey.self)
            try container.encode("cancelled", forKey: .outcome)
        case let .selected(value):
            try value.encode(to: encoder)
            var container = encoder.container(keyedBy: DiscriminatorKey.self)
            try container.encode("selected", forKey: .outcome)
        case let .unknown(_, raw):
            try raw.encode(to: encoder)
        }
    }
}

/// パーミッションリクエストへのレスポンス。
public struct RequestPermissionResponse: ACPSchemaType {
    public var outcome: RequestPermissionOutcome
    public var meta: Meta?

    public init(outcome: RequestPermissionOutcome, meta: Meta? = nil) {
        self.outcome = outcome
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case outcome
        case meta = "_meta"
    }
}
