/// Which file-system methods the client offers.
///
/// The flags are always present on the wire, defaulting to `false`. Nothing checks that a client
/// advertising a capability actually implements it — an agent that trusts this and calls an
/// unimplemented method gets an error at call time.
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

/// What the client lends the agent, sent once during initialization and fixed for the connection.
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
