/// The sender or recipient of messages and data in a conversation.
public struct Role: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }

    public static let assistant = Role("assistant")
    public static let user = Role("user")
}

/// Optional annotations the client can use to inform how objects are used or
/// displayed.
public struct Annotations: ACPSchemaType {
    public var audience: [Role]?
    public var lastModified: String?
    public var priority: Double?
    public var meta: Meta?

    public init(
        audience: [Role]? = nil,
        lastModified: String? = nil,
        priority: Double? = nil,
        meta: Meta? = nil
    ) {
        self.audience = audience
        self.lastModified = lastModified
        self.priority = priority
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case audience, lastModified, priority
        case meta = "_meta"
    }
}

/// Text provided to or from an LLM. May be plain text or Markdown.
public struct TextContent: ACPSchemaType {
    public var annotations: Annotations?
    public var text: String
    public var meta: Meta?

    public init(text: String, annotations: Annotations? = nil, meta: Meta? = nil) {
        self.annotations = annotations
        self.text = text
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case annotations, text
        case meta = "_meta"
    }
}

/// An image provided to or from an LLM.
public struct ImageContent: ACPSchemaType {
    public var annotations: Annotations?
    public var data: String
    public var mimeType: String
    public var uri: String?
    public var meta: Meta?

    public init(
        data: String,
        mimeType: String,
        annotations: Annotations? = nil,
        uri: String? = nil,
        meta: Meta? = nil
    ) {
        self.annotations = annotations
        self.data = data
        self.mimeType = mimeType
        self.uri = uri
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case annotations, data, mimeType, uri
        case meta = "_meta"
    }
}

/// Audio provided to or from an LLM.
public struct AudioContent: ACPSchemaType {
    public var annotations: Annotations?
    public var data: String
    public var mimeType: String
    public var meta: Meta?

    public init(data: String, mimeType: String, annotations: Annotations? = nil, meta: Meta? = nil) {
        self.annotations = annotations
        self.data = data
        self.mimeType = mimeType
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case annotations, data, mimeType
        case meta = "_meta"
    }
}

/// Text-based resource contents.
public struct TextResourceContents: ACPSchemaType {
    public var mimeType: String?
    public var text: String
    public var uri: String
    public var meta: Meta?

    public init(text: String, uri: String, mimeType: String? = nil, meta: Meta? = nil) {
        self.mimeType = mimeType
        self.text = text
        self.uri = uri
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case mimeType, text, uri
        case meta = "_meta"
    }
}

/// Binary resource contents.
public struct BlobResourceContents: ACPSchemaType {
    public var blob: String
    public var mimeType: String?
    public var uri: String
    public var meta: Meta?

    public init(blob: String, uri: String, mimeType: String? = nil, meta: Meta? = nil) {
        self.blob = blob
        self.mimeType = mimeType
        self.uri = uri
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case blob, mimeType, uri
        case meta = "_meta"
    }
}

/// Resource content that can be embedded in a message (untagged: text or blob).
public enum EmbeddedResourceResource: ACPSchemaType {
    case text(TextResourceContents)
    case blob(BlobResourceContents)

    public init(from decoder: any Decoder) throws {
        if let value = try? TextResourceContents(from: decoder) {
            self = .text(value)
        } else {
            self = .blob(try BlobResourceContents(from: decoder))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .text(value): try value.encode(to: encoder)
        case let .blob(value): try value.encode(to: encoder)
        }
    }
}

/// The contents of a resource, embedded into a prompt or tool call result.
public struct EmbeddedResource: ACPSchemaType {
    public var annotations: Annotations?
    public var resource: EmbeddedResourceResource
    public var meta: Meta?

    public init(resource: EmbeddedResourceResource, annotations: Annotations? = nil, meta: Meta? = nil) {
        self.annotations = annotations
        self.resource = resource
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case annotations, resource
        case meta = "_meta"
    }
}

/// A resource the agent can read, referenced in a prompt or tool call result.
public struct ResourceLink: ACPSchemaType {
    public var annotations: Annotations?
    public var description: String?
    public var mimeType: String?
    public var name: String
    public var size: Int64?
    public var title: String?
    public var uri: String
    public var meta: Meta?

    public init(
        name: String,
        uri: String,
        annotations: Annotations? = nil,
        description: String? = nil,
        mimeType: String? = nil,
        size: Int64? = nil,
        title: String? = nil,
        meta: Meta? = nil
    ) {
        self.annotations = annotations
        self.description = description
        self.mimeType = mimeType
        self.name = name
        self.size = size
        self.title = title
        self.uri = uri
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case annotations, description, mimeType, name, size, title, uri
        case meta = "_meta"
    }
}

/// Displayable information in the protocol: text, images, audio, or resources.
///
/// Internally tagged on `type`. An unrecognised `type` is preserved verbatim
/// as `.unknown` so a newer peer's content block never fails to decode.
public enum ContentBlock: ACPSchemaType {
    case text(TextContent)
    case image(ImageContent)
    case audio(AudioContent)
    case resourceLink(ResourceLink)
    case resource(EmbeddedResource)
    case unknown(type: String, raw: JSONValue)

    private enum DiscriminatorKey: String, CodingKey { case type }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: DiscriminatorKey.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "text": self = .text(try TextContent(from: decoder))
        case "image": self = .image(try ImageContent(from: decoder))
        case "audio": self = .audio(try AudioContent(from: decoder))
        case "resource_link": self = .resourceLink(try ResourceLink(from: decoder))
        case "resource": self = .resource(try EmbeddedResource(from: decoder))
        default: self = .unknown(type: type, raw: try JSONValue(from: decoder))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .text(value): try encodeTagged(value, "text", to: encoder)
        case let .image(value): try encodeTagged(value, "image", to: encoder)
        case let .audio(value): try encodeTagged(value, "audio", to: encoder)
        case let .resourceLink(value): try encodeTagged(value, "resource_link", to: encoder)
        case let .resource(value): try encodeTagged(value, "resource", to: encoder)
        case let .unknown(_, raw): try raw.encode(to: encoder)
        }
    }

    private func encodeTagged(_ payload: some Encodable, _ type: String, to encoder: any Encoder) throws {
        try payload.encode(to: encoder)
        var container = encoder.container(keyedBy: DiscriminatorKey.self)
        try container.encode(type, forKey: .type)
    }
}

/// A standard content block wrapper.
public struct Content: ACPSchemaType {
    public var content: ContentBlock
    public var meta: Meta?

    public init(content: ContentBlock, meta: Meta? = nil) {
        self.content = content
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case content
        case meta = "_meta"
    }
}

/// A streamed item of content, carrying the message it belongs to.
public struct ContentChunk: ACPSchemaType {
    public var content: ContentBlock
    public var messageId: MessageId?
    public var meta: Meta?

    public init(content: ContentBlock, messageId: MessageId? = nil, meta: Meta? = nil) {
        self.content = content
        self.messageId = messageId
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case content, messageId
        case meta = "_meta"
    }
}
