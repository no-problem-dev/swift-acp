import Foundation

/// A value type that mirrors a named definition in the ACP wire schema
/// (`schema/v1/schema.json` → `$defs`).
///
/// Conformance is the contract the conformance suite checks: every `$defs`
/// entry in the pinned schema must have exactly one modelled Swift type, and
/// every modelled type round-trips losslessly through JSON. `schemaName`
/// defaults to the Swift type name, so a type only overrides it when the Swift
/// spelling deliberately diverges from the schema (e.g. to avoid shadowing
/// `Swift.Error`).
public protocol ACPSchemaType: Codable, Equatable, Sendable {
    static var schemaName: String { get }

    /// Decodes `data` as `Self` and re-encodes it, callable on a type-erased
    /// `any ACPSchemaType.Type`. The conformance suite uses this to prove every
    /// modelled type round-trips a vendored wire sample losslessly.
    static func roundTripJSON(_ data: Data, using encoder: JSONEncoder) throws -> Data
}

public extension ACPSchemaType {
    static var schemaName: String { String(describing: Self.self) }

    static func roundTripJSON(_ data: Data, using encoder: JSONEncoder) throws -> Data {
        try encoder.encode(try JSONDecoder().decode(Self.self, from: data))
    }
}
