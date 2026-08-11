/// The error object a failed response carries — the schema's `Error` definition.
///
/// Named `RPCError` rather than `Error` so it does not shadow `Swift.Error`; `schemaName` restores
/// the wire name for the conformance check. Conforms to `Swift.Error`, so it can be thrown from a
/// handler and travels to the peer with its code intact.
public struct RPCError: ACPSchemaType, Error {
    public static var schemaName: String { "Error" }

    /// What kind of failure this is. Clients should branch on this rather than on `message`.
    public var code: ErrorCode
    /// A short sentence for people to read.
    public var message: String
    /// Anything more the peer wants to convey. Omitted from the wire entirely when absent.
    public var data: JSONValue?

    public init(code: ErrorCode, message: String, data: JSONValue? = nil) {
        self.code = code
        self.message = message
        self.data = data
    }
}
