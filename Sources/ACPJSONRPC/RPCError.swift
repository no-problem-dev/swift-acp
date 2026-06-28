/// JSON-RPC エラーオブジェクト（スキーマの `Error` 定義に対応）。
///
/// `Swift.Error` を隠さないよう `RPCError` と命名し、`schemaName` でワイヤー名に紐付ける。
/// `data` は存在しない場合、ワイヤーから完全に省略される。
public struct RPCError: ACPSchemaType, Error {
    public static var schemaName: String { "Error" }

    /// エラーの種別コード。
    public var code: ErrorCode
    /// エラーの短い一文説明。
    public var message: String
    /// 追加情報（省略可）。
    public var data: JSONValue?

    public init(code: ErrorCode, message: String, data: JSONValue? = nil) {
        self.code = code
        self.message = message
        self.data = data
    }
}
