/// クライアントがサポートするファイルシステムケーパビリティ。
///
/// ブールフラグはワイヤー上で常に存在する（デフォルト `false`）。
public struct FileSystemCapabilities: ACPSchemaType {
    public var readTextFile: Bool
    public var writeTextFile: Bool
    public var meta: Meta?

    public init(readTextFile: Bool = false, writeTextFile: Bool = false, meta: Meta? = nil) {
        self.readTextFile = readTextFile
        self.writeTextFile = writeTextFile
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case readTextFile, writeTextFile
        case meta = "_meta"
    }
}

/// 初期化時にクライアントが通知するケーパビリティ。
public struct ClientCapabilities: ACPSchemaType {
    public var fs: FileSystemCapabilities
    public var terminal: Bool
    public var meta: Meta?

    public init(fs: FileSystemCapabilities = .init(), terminal: Bool = false, meta: Meta? = nil) {
        self.fs = fs
        self.terminal = terminal
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case fs, terminal
        case meta = "_meta"
    }
}
