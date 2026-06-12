/// A JSON-RPC request identifier.
///
/// Per the JSON-RPC 2.0 specification an id is a string, an integer, or null;
/// it is encoded untagged (as the bare scalar) and echoed back on the matching
/// response so a caller can correlate the two.
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
