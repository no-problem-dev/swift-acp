import Foundation
import Testing
@testable import ACPCore

/// Asserts the Swift method-name tables match the pinned `meta.json` registry
/// exactly — no missing, extra, or misspelled methods.
@Suite("Method parity")
struct MethodParityTests {
    private struct Meta: Decodable {
        let agentMethods: [String: String]
        let clientMethods: [String: String]
    }

    private func meta() throws -> Meta {
        let url = try #require(
            Bundle.module.url(forResource: "meta", withExtension: "json", subdirectory: "Spec/v1")
        )
        return try JSONDecoder().decode(Meta.self, from: Data(contentsOf: url))
    }

    @Test func agentMethodsMatchRegistry() throws {
        #expect(ACPMethod.agentMethods == (try meta().agentMethods))
    }

    @Test func clientMethodsMatchRegistry() throws {
        #expect(ACPMethod.clientMethods == (try meta().clientMethods))
    }
}
