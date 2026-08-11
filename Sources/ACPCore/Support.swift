/// The open `_meta` object almost every ACP message carries.
///
/// ACP places no meaning on the contents, so two peers must agree out of band on what they put
/// here. Assume nothing about keys you did not write.
public typealias Meta = [String: JSONValue]

/// A string-backed identifier or open enumeration.
///
/// ACP marks these non-exhaustive on the wire, so a value this package does not know must not be
/// rejected. Modelling them as permissive newtypes with named constants for the known values keeps
/// an unrecognized value intact through a round trip — at the cost of `switch` never being
/// exhaustive, so always handle the unknown case.
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

/// A field with three states rather than two: absent, explicitly null, or present with a value.
///
/// For the places where ACP gives `null` and "absent" different meanings — on
/// `SessionInfoUpdate.title`, null clears the title while absence leaves it alone.
///
/// - Important: This type cannot omit its own key. Encoding `.undefined` writes `null`, which is
///   the wrong thing; the containing type must check `isUndefined` and skip the key. Getting that
///   wrong turns "leave unchanged" into "clear" with nothing failing.
///
/// Decoding is unambiguous: an absent key yields `.undefined`, an explicit null yields `.null`,
/// anything else yields `.value`.
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
