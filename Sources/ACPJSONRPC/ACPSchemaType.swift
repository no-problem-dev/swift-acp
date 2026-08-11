import Foundation

/// A value type that models one named definition from the pinned ACP wire schema — an entry under
/// `$defs` in `Tests/ACPConformanceTests/Spec/v1/schema.json`.
///
/// Conformance rests on this protocol: the test suite reads the pinned schema, collects every
/// modelled type, and requires the two sets to match exactly — no unmodelled definition, and no
/// modelled type claiming a name the schema does not define. It then decodes and re-encodes the
/// vendored wire samples through these types and compares the JSON.
///
/// Adopting the protocol is what enrols a type in that check. A type left out of
/// `ACPCoreSchema.types` or `ACPJSONRPCSchema.types` is invisible to it, so the registries are the
/// thing to update when a definition is added.
public protocol ACPSchemaType: Codable, Equatable, Sendable {
    /// The schema definition this type models. Defaults to the Swift type name; override only when
    /// the Swift name deliberately differs, as `RPCError` does to avoid shadowing `Swift.Error`.
    static var schemaName: String { get }

    /// Decodes `data` as `Self` and re-encodes it, so a round trip can be driven through an
    /// existential `any ACPSchemaType.Type` without knowing the concrete type.
    ///
    /// - Parameters:
    ///   - data: The wire sample to read.
    ///   - encoder: The encoder to write it back with.
    /// - Returns: The re-encoded bytes. Key order will differ from the input; the conformance suite
    ///   compares parsed JSON rather than bytes.
    static func roundTripJSON(_ data: Data, using encoder: JSONEncoder) throws -> Data
}

public extension ACPSchemaType {
    static var schemaName: String { String(describing: Self.self) }

    static func roundTripJSON(_ data: Data, using encoder: JSONEncoder) throws -> Data {
        try encoder.encode(try JSONDecoder().decode(Self.self, from: data))
    }
}
