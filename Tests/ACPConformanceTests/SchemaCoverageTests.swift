import Foundation
import Testing
@testable import ACPCore
@testable import ACPJSONRPC

/// Loads the vendored, version-pinned wire schema (`Spec/v1/schema.json`).
enum Spec {
    static func url(_ resource: String, _ ext: String) throws -> URL {
        try #require(
            Bundle.module.url(forResource: resource, withExtension: ext, subdirectory: "Spec/v1"),
            "missing vendored spec resource \(resource).\(ext)"
        )
    }

    static func schemaDefs() throws -> [String: Any] {
        let data = try Data(contentsOf: try url("schema", "json"))
        let root = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        return try #require(root["$defs"] as? [String: Any])
    }

    static var modelledSchemaNames: Set<String> {
        Set((ACPJSONRPCSchema.types + ACPCoreSchema.types).map { $0.schemaName })
    }
}

@Suite("Schema coverage")
struct SchemaCoverageTests {
    /// Every `$defs` entry in the pinned schema must map to exactly one Swift
    /// type, and no modelled type may claim a name the schema doesn't define.
    @Test func everyDefinitionIsModelled() throws {
        let schemaNames = Set(try Spec.schemaDefs().keys)
        let modelled = Spec.modelledSchemaNames

        let extra = modelled.subtracting(schemaNames).sorted()
        #expect(extra.isEmpty, "Modelled types absent from schema: \(extra)")

        let missing = schemaNames.subtracting(modelled).sorted()
        #expect(
            missing.isEmpty,
            "Schema $defs not yet modelled (\(missing.count) of \(schemaNames.count)): \(missing)"
        )
    }
}
