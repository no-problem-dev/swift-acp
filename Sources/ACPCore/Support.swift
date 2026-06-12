/// The open-ended `_meta` object carried by most ACP messages.
///
/// Reserved by ACP for clients and agents to attach additional metadata;
/// implementations MUST NOT assume anything about its keys.
public typealias Meta = [String: JSONValue]

/// A string-backed identifier or open enumeration.
///
/// ACP's ids (`SessionId`, `ToolCallId`, …) and several string enumerations
/// (`Role`, `ToolKind`, …) are `non_exhaustive` on the wire. Modelling them as
/// permissive string newtypes — with named constants for the known values —
/// keeps decoding forward-compatible: an unrecognised value is preserved
/// rather than rejected.
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

/// A field that distinguishes three states: absent (key omitted), explicit
/// `null`, and a present value.
///
/// ACP uses this where `null` and "omitted" mean different things — e.g.
/// `SessionInfoUpdate.title`, where `null` clears the title and omission leaves
/// it unchanged. The enclosing type must drive omission (encode the key only
/// when the value isn't `.undefined`); decoding maps a missing key to
/// `.undefined`, an explicit `null` to `.null`, and anything else to `.value`.
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
