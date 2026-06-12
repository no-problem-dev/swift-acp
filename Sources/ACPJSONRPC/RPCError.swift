/// A JSON-RPC error object (the schema's `Error` definition).
///
/// Named `RPCError` in Swift to avoid shadowing `Swift.Error`; `schemaName`
/// pins it back to the wire name. `data` is omitted entirely when absent.
public struct RPCError: ACPSchemaType, Error {
    public static var schemaName: String { "Error" }

    /// A number indicating the error type that occurred.
    public var code: ErrorCode
    /// A short, single-sentence description of the error.
    public var message: String
    /// Optional additional information about the error.
    public var data: JSONValue?

    public init(code: ErrorCode, message: String, data: JSONValue? = nil) {
        self.code = code
        self.message = message
        self.data = data
    }
}
