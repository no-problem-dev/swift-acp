import Foundation
import Testing
@testable import ACPCore
@testable import ACPJSONRPC

/// Decodes every vendored golden wire sample into its modelled Swift type and
/// re-encodes it, asserting the JSON is preserved. The samples are harvested
/// verbatim from the reference crate's `#[test]` serialization assertions, so
/// this proves field-level conformance, not just that a type with the right
/// name exists.
@Suite("Golden corpus")
struct GoldenCorpusTests {
    private struct Entry: Decodable {
        let file: String
        let type: String
        let source: String?
    }

    /// schemaName → type, across both modules.
    private static let registry: [String: any ACPSchemaType.Type] = Dictionary(
        (ACPJSONRPCSchema.types + ACPCoreSchema.types).map { ($0.schemaName, $0) },
        uniquingKeysWith: { first, _ in first }
    )

    /// JSON-RPC envelope wrappers are intentionally not `$defs` types, so golden
    /// samples named for them are validated by the transport tests instead.
    private static let allowedSkips: Set<String> = ["JsonRpcMessage", "JsonRpcBatch"]

    private func parse(_ data: Data) throws -> NSObject {
        try #require(try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? NSObject)
    }

    @Test func everyGoldenSampleRoundTrips() throws {
        let manifestURL = try #require(
            Bundle.module.url(forResource: "manifest", withExtension: "json", subdirectory: "Spec/golden")
        )
        let dir = manifestURL.deletingLastPathComponent()
        let entries = try JSONDecoder().decode([Entry].self, from: Data(contentsOf: manifestURL))
        let encoder = JSONEncoder()

        var skipped: Set<String> = []
        for entry in entries {
            guard let type = Self.registry[entry.type] else {
                skipped.insert(entry.type)
                continue
            }
            let input = try Data(contentsOf: dir.appendingPathComponent(entry.file))
            let output = try type.roundTripJSON(input, using: encoder)
            #expect(
                try parse(input).isEqual(parse(output)),
                """
                \(entry.file) (\(entry.type)) did not round-trip.
                in:  \(String(decoding: input, as: UTF8.self))
                out: \(String(decoding: output, as: UTF8.self))
                """
            )
        }

        let unexpected = skipped.subtracting(Self.allowedSkips).sorted()
        #expect(unexpected.isEmpty, "golden samples reference unmodelled types: \(unexpected)")
    }
}
