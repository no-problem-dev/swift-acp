/// A predefined JSON-RPC / ACP error code.
///
/// Standard JSON-RPC codes plus the ACP-specific ones in the reserved range,
/// with `other` carrying any code outside the known set. The wire form is the
/// bare integer (`-32700`, …), so encoding and decoding go through `code`.
public enum ErrorCode: ACPSchemaType, Hashable {
    /// Invalid JSON was received by the server. (`-32700`)
    case parseError
    /// The JSON sent is not a valid Request object. (`-32600`)
    case invalidRequest
    /// The method does not exist or is not available. (`-32601`)
    case methodNotFound
    /// Invalid method parameter(s). (`-32602`)
    case invalidParams
    /// Internal JSON-RPC error. (`-32603`)
    case internalError
    /// Authentication is required before this operation can be performed. (`-32000`)
    case authRequired
    /// A given resource, such as a file, was not found. (`-32002`)
    case resourceNotFound
    /// Any error code outside the predefined set.
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
