/// The error codes JSON-RPC and ACP define, plus a catch-all for everything else.
///
/// On the wire this is a bare integer, so an unrecognized code decodes to `other` rather than
/// failing — which is what lets a peer introduce a code without breaking this one. Round-trips are
/// lossless in both directions.
public enum ErrorCode: ACPSchemaType, Hashable {
    /// The JSON could not be parsed (`-32700`).
    case parseError
    /// The JSON parsed but is not a valid request object (`-32600`).
    case invalidRequest
    /// The method does not exist, or is not available to this caller (`-32601`).
    case methodNotFound
    /// The parameters do not fit the method (`-32602`).
    case invalidParams
    /// The peer failed for a reason of its own (`-32603`).
    case internalError
    /// The caller must authenticate before this operation is allowed (`-32000`). ACP-specific.
    case authRequired
    /// The named resource — a file, typically — does not exist (`-32002`). ACP-specific.
    case resourceNotFound
    /// Any other code, kept verbatim.
    case other(Int32)

    public init(code: Int32) {
        switch code {
        case -32700: self = .parseError
        case -32600: self = .invalidRequest
        case -32601: self = .methodNotFound
        case -32602: self = .invalidParams
        case -32603: self = .internalError
        case -32000: self = .authRequired
        case -32002: self = .resourceNotFound
        default: self = .other(code)
        }
    }

    public var code: Int32 {
        switch self {
        case .parseError: -32700
        case .invalidRequest: -32600
        case .methodNotFound: -32601
        case .invalidParams: -32602
        case .internalError: -32603
        case .authRequired: -32000
        case .resourceNotFound: -32002
        case let .other(value): value
        }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(code: try container.decode(Int32.self))
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(code)
    }
}
