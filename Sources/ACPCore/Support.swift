/// 大部分の ACP メッセージが持つオープンエンドな `_meta` オブジェクト。
///
/// ACP がクライアントとエージェントの追加メタデータ添付のために予約する領域。
/// 実装はそのキーについて何も仮定してはならない。
public typealias Meta = [String: JSONValue]

/// 文字列バックの識別子またはオープン列挙型。
///
/// ACP の識別子（`SessionId`・`ToolCallId` 等）や文字列列挙（`Role`・`ToolKind` 等）は
/// ワイヤーレベルで `non_exhaustive`。許容的な文字列 newtype として表現し、
/// 既知値には名前付き定数を設ける。未知値は拒否せず保持するため前方互換を維持する。
public protocol ACPStringNewType:
    ACPSchemaType, RawRepresentable, Hashable, Comparable, ExpressibleByStringLiteral
where RawValue == String {
    init(_ value: String)
}

public extension ACPStringNewType {
    init?(rawValue: String) { self.init(rawValue) }
    init(stringLiteral value: String) { self.init(value) }

    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

    init(from decoder: any Decoder) throws {
        self.init(try decoder.singleValueContainer().decode(String.self))
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

/// 3 状態を区別するフィールド：キー省略（`.undefined`）・明示的 `null`・値あり（`.value`）。
///
/// ACP で `null` と "省略" が異なる意味を持つ箇所（例: `SessionInfoUpdate.title`：
/// `null` はタイトルをクリア、省略は変更なし）で使用する。
/// エンコード時は親型が `.undefined` のときキー自体を省略する責務を持つ。
/// デコード時はキー不在 → `.undefined`、明示的 `null` → `.null`、それ以外 → `.value` に対応する。
public enum MaybeUndefined<Wrapped: Codable & Equatable & Sendable>: Codable, Equatable, Sendable {
    case undefined
    case null
    case value(Wrapped)

    public var isUndefined: Bool {
        if case .undefined = self { true } else { false }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else {
            self = .value(try container.decode(Wrapped.self))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .undefined, .null: try container.encodeNil()
        case let .value(value): try container.encode(value)
        }
    }
}
