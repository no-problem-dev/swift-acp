/// JSON-RPC / ACP の定義済みエラーコード。
///
/// JSON-RPC 標準コードに加え、ACP 固有コードを予約済み範囲に定義する。
/// 既知セット外のコードは `other` に収容する。
/// ワイヤー形式は裸の整数（`-32700` 等）なので、符号化・復号は `code` プロパティを経由する。
public enum ErrorCode: ACPSchemaType, Hashable {
    /// JSON のパースに失敗。（`-32700`）
    case parseError
    /// 有効な Request オブジェクトでない JSON を受信した。（`-32600`）
    case invalidRequest
    /// メソッドが存在しないか利用不可。（`-32601`）
    case methodNotFound
    /// 不正なメソッドパラメータ。（`-32602`）
    case invalidParams
    /// JSON-RPC 内部エラー。（`-32603`）
    case internalError
    /// 操作前に認証が必要。（`-32000`）
    case authRequired
    /// ファイルなど指定リソースが見つからない。（`-32002`）
    case resourceNotFound
    /// 定義済みセット外の任意のエラーコード。
    case other(Int32)

    public init(code: Int32) {
        switch code {
        case -32700: self = .parseError
        case -32600: self = .invalidRequest
        case -32601: self = .methodNotFound
        case -32602: self = .invalidParams
        case -32603: self = .internalError
        case -32000: self = .authRequired
        case -32002: self = .resourceNotFound
        default: self = .other(code)
        }
    }

    public var code: Int32 {
        switch self {
        case .parseError: -32700
        case .invalidRequest: -32600
        case .methodNotFound: -32601
        case .invalidParams: -32602
        case .internalError: -32603
        case .authRequired: -32000
        case .resourceNotFound: -32002
        case let .other(value): value
        }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(code: try container.decode(Int32.self))
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(code)
    }
}
