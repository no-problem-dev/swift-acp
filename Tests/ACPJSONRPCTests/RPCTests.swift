import Foundation
import Testing
@testable import ACPJSONRPC

/// Round-trip vectors taken verbatim from the reference crate's `src/rpc.rs`
/// and `src/v1/error.rs` `#[test]` blocks.
@Suite("JSON-RPC primitives")
struct RPCTests {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try decoder.decode(T.self, from: Data(json.utf8))
    }

    private func encoded<T: Encodable>(_ value: T) throws -> String {
        String(decoding: try encoder.encode(value), as: UTF8.self)
    }

    @Test func requestIdRoundTrips() throws {
        #expect(try decode(RequestId.self, "null") == .null)
        #expect(try decode(RequestId.self, "1") == .number(1))
        #expect(try decode(RequestId.self, "-1") == .number(-1))
        #expect(try decode(RequestId.self, "\"id\"") == .string("id"))

        #expect(try encoded(RequestId.null) == "null")
        #expect(try encoded(RequestId.number(1)) == "1")
        #expect(try encoded(RequestId.number(-1)) == "-1")
        #expect(try encoded(RequestId.string("id")) == "\"id\"")
    }

    @Test func errorCodeIsTheBareInteger() throws {
        #expect(try decode(ErrorCode.self, "-32700") == .parseError)
        #expect(try encoded(ErrorCode.parseError) == "-32700")
        #expect(try decode(ErrorCode.self, "1") == .other(1))
        #expect(try encoded(ErrorCode.other(1)) == "1")
    }

    @Test func errorOmitsAbsentData() throws {
        let error = RPCError(code: .methodNotFound, message: "Method not found")
        let json = try encoded(error)
        #expect(!json.contains("data"))
        #expect(try decode(RPCError.self, json) == error)
    }
}
