import Foundation
import Testing
@testable import ACPCore

/// Round-trip vectors mirroring the reference crate's `src/v1/content.rs` and
/// the `ContentBlock` wire form asserted in `src/rpc.rs`.
@Suite("Content")
struct ContentTests {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private func object(_ value: some Encodable) throws -> [String: Any] {
        let data = try encoder.encode(value)
        return try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    private func roundTrips<T: ACPSchemaType>(_ value: T) throws {
        let data = try encoder.encode(value)
        #expect(try decoder.decode(T.self, from: data) == value)
    }

    @Test func textContentOmitsAbsentOptionals() throws {
        let json = try object(TextContent(text: "hello"))
        #expect(json["text"] as? String == "hello")
        #expect(json["annotations"] == nil)
        #expect(json["_meta"] == nil)
        try roundTrips(TextContent(text: "hello world"))
    }

    @Test func imageContentCarriesUriAndMimeType() throws {
        let image = ImageContent(data: "data", mimeType: "image/png", uri: "https://example.com/i.png")
        let json = try object(image)
        #expect(json["mimeType"] as? String == "image/png")
        #expect(json["uri"] as? String == "https://example.com/i.png")
        try roundTrips(image)
    }

    @Test func contentBlockIsInternallyTaggedOnType() throws {
        let block = ContentBlock.text(TextContent(text: "Hello"))
        let json = try object(block)
        #expect(json["type"] as? String == "text")
        #expect(json["text"] as? String == "Hello")
        try roundTrips(block)
    }

    @Test func unknownContentBlockIsPreserved() throws {
        let wire = #"{"type":"video","src":"x"}"#
        let block = try decoder.decode(ContentBlock.self, from: Data(wire.utf8))
        guard case let .unknown(type, _) = block else {
            Issue.record("expected unknown content block")
            return
        }
        #expect(type == "video")
        let reencoded = try object(block)
        #expect(reencoded["type"] as? String == "video")
        #expect(reencoded["src"] as? String == "x")
    }

    @Test func embeddedResourceResourcePicksTextOrBlob() throws {
        try roundTrips(EmbeddedResourceResource.text(TextResourceContents(text: "t", uri: "file:///a")))
        try roundTrips(EmbeddedResourceResource.blob(BlobResourceContents(blob: "b", uri: "file:///a")))
    }

    @Test func contentChunkRoundTrips() throws {
        try roundTrips(ContentChunk(
            content: .text(TextContent(text: "hi")),
            messageId: MessageId("m-1")
        ))
    }
}
