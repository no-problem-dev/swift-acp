/// A request identifier: a string, an integer, or null, as JSON-RPC 2.0 allows.
///
/// Encoded as a bare scalar with no wrapper, and echoed verbatim in the response so a caller can
/// match the two.
///
/// - Note: `null` is modelled here because the specification permits it, but the frame classifier
///   in `ACPTransport` cannot distinguish a null id from an absent one — a request with a null id
///   is read as a notification, and a response with one is rejected as malformed.
public enum RequestId: ACPSchemaType, Hashable {
    case null
    case number(Int64)
    case string(String)

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Int64.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "RequestId must be a string, integer, or null"
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case let .number(value): try container.encode(value)
        case let .string(value): try container.encode(value)
        }
    }
}
