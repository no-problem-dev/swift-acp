/// The schema definitions this layer owns, as opposed to the ACP domain definitions in
/// `ACPCoreSchema`.
///
/// The conformance suite unions the two and requires the result to equal the pinned schema's
/// `$defs` exactly. A type not listed here is not checked, whatever its conformances.
public enum ACPJSONRPCSchema {
    public static let types: [any ACPSchemaType.Type] = [
        RequestId.self,
        ErrorCode.self,
        RPCError.self,
    ]
}
