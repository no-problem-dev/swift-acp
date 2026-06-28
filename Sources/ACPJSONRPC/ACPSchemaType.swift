import Foundation

/// ACP ワイヤースキーマ（`schema/v1/schema.json` の `$defs`）の名前付き定義に対応する値型。
///
/// コンフォーマンステストスイートが確認するコントラクト：ピン留めされたスキーマの各 `$defs` エントリは
/// ちょうど 1 つの Swift 型に対応し、すべてのモデル型が JSON をロスレスにラウンドトリップする必要がある。
/// `schemaName` はデフォルトで Swift の型名を返すため、Swift の命名がスキーマと意図的に異なる場合
/// （例: `Swift.Error` の隠蔽を避けるため）にのみオーバーライドする。
public protocol ACPSchemaType: Codable, Equatable, Sendable {
    static var schemaName: String { get }

    /// `data` を `Self` としてデコードして再エンコードする。型消去された `any ACPSchemaType.Type` 上で呼び出し可能。
    /// コンフォーマンステストスイートがこれを使ってモデル型ごとにワイヤーサンプルのロスレスラウンドトリップを検証する。
    static func roundTripJSON(_ data: Data, using encoder: JSONEncoder) throws -> Data
}

public extension ACPSchemaType {
    static var schemaName: String { String(describing: Self.self) }

    static func roundTripJSON(_ data: Data, using encoder: JSONEncoder) throws -> Data {
        try encoder.encode(try JSONDecoder().decode(Self.self, from: data))
    }
}
