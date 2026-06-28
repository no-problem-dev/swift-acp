/// JSON-RPC レイヤーが所有するスキーマ定義の一覧。
///
/// コンフォーマンステストスイートがこれを `ACPCoreSchema.types` と合算し、
/// ピン留めされたワイヤースキーマの全 `$defs` エントリが過不足なくモデル化されていることを検証する。
public enum ACPJSONRPCSchema {
    public static let types: [any ACPSchemaType.Type] = [
        RequestId.self,
        ErrorCode.self,
        RPCError.self,
    ]
}
