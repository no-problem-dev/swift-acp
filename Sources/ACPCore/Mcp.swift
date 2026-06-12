/// An HTTP header to set when making requests to the MCP server.
public struct HttpHeader: ACPSchemaType {
    public var name: String
    public var value: String
    public var meta: Meta?

    public init(name: String, value: String, meta: Meta? = nil) {
        self.name = name
        self.value = value
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case name, value
        case meta = "_meta"
    }
}

/// HTTP transport configuration for MCP.
public struct McpServerHttp: ACPSchemaType {
    public var name: String
    public var url: String
    public var headers: [HttpHeader]
    public var meta: Meta?

    public init(name: String, url: String, headers: [HttpHeader], meta: Meta? = nil) {
        self.name = name
        self.url = url
        self.headers = headers
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case name, url, headers
        case meta = "_meta"
    }
}

/// SSE transport configuration for MCP.
public struct McpServerSse: ACPSchemaType {
    public var name: String
    public var url: String
    public var headers: [HttpHeader]
    public var meta: Meta?

    public init(name: String, url: String, headers: [HttpHeader], meta: Meta? = nil) {
        self.name = name
        self.url = url
        self.headers = headers
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case name, url, headers
        case meta = "_meta"
    }
}

/// Stdio transport configuration for MCP. All agents MUST support this transport.
public struct McpServerStdio: ACPSchemaType {
    public var name: String
    public var command: String
    public var args: [String]
    public var env: [EnvVariable]
    public var meta: Meta?

    public init(name: String, command: String, args: [String], env: [EnvVariable], meta: Meta? = nil) {
        self.name = name
        self.command = command
        self.args = args
        self.env = env
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case name, command, args, env
        case meta = "_meta"
    }
}

/// Configuration for connecting to an MCP (Model Context Protocol) server.
///
/// Discriminated on `type`: `http` and `sse` carry that tag, while the baseline
/// `stdio` transport has no `type` tag (it is the untagged default). An
/// unrecognised `type` is preserved as `.unknown`.
public enum McpServer: ACPSchemaType {
    case http(McpServerHttp)
    case sse(McpServerSse)
    case stdio(McpServerStdio)
    case unknown(type: String, raw: JSONValue)

    private enum DiscriminatorKey: String, CodingKey { case type }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: DiscriminatorKey.self)
        switch try container.decodeIfPresent(String.self, forKey: .type) {
        case "http": self = .http(try McpServerHttp(from: decoder))
        case "sse": self = .sse(try McpServerSse(from: decoder))
        case nil: self = .stdio(try McpServerStdio(from: decoder))
        case let type?:
            if let value = try? McpServerStdio(from: decoder) {
                self = .stdio(value)
            } else {
                self = .unknown(type: type, raw: try JSONValue(from: decoder))
            }
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .http(value): try encodeTagged(value, "http", to: encoder)
        case let .sse(value): try encodeTagged(value, "sse", to: encoder)
        case let .stdio(value): try value.encode(to: encoder)
        case let .unknown(_, raw): try raw.encode(to: encoder)
        }
    }

    private func encodeTagged(_ payload: some Encodable, _ type: String, to encoder: any Encoder) throws {
        try payload.encode(to: encoder)
        var container = encoder.container(keyedBy: DiscriminatorKey.self)
        try container.encode(type, forKey: .type)
    }
}
