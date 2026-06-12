/// The schema definitions owned by the JSON-RPC layer.
///
/// The conformance suite unions this with `ACPCoreSchema.types` to prove every
/// `$defs` entry in the pinned wire schema is modelled exactly once.
public enum ACPJSONRPCSchema {
    public static let types: [any ACPSchemaType.Type] = [
        RequestId.self,
        ErrorCode.self,
        RPCError.self,
    ]
}
