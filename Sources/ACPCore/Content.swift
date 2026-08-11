/// Who a message or piece of content is from. Open: values beyond `user` and `assistant` decode
/// unchanged.
public struct Role: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }

    public static let assistant = Role("assistant")
    public static let user = Role("user")
}

/// Hints about who content is for and how important it is. Advisory — nothing acts on them.
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

/// Text, plain or Markdown. Nothing here distinguishes the two; the recipient decides.
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

/// An image, carried inline as Base64 in `data` with its media type alongside.
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

/// Audio, carried inline as Base64 in `data` with its media type alongside.
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

/// A resource's contents as text.
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

/// A resource's contents as Base64-encoded bytes.
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

/// A resource's contents, text or binary.
///
/// Untagged: decoding tries the text form first and falls back to the blob form, so an object
/// carrying both `text` and `blob` is read as text.
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

/// A resource carried inline, contents and all, rather than referenced by URI.
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

/// A pointer to a resource the agent may read, as opposed to one carried inline. Nothing fetches
/// it.
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

/// A piece of displayable content: text, image, audio, or a resource.
///
/// Tagged by a `type` member. An unrecognized type decodes to `.unknown` holding the original
/// JSON, so a peer on a newer revision does not break decoding — and re-encoding an unknown block
/// reproduces it byte for byte.
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

/// A content block with its own `_meta`, for the places the schema wraps one.
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

/// One piece of streamed content, tagged with the message it belongs to so a consumer can tell a
/// continuation from a new message.
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
