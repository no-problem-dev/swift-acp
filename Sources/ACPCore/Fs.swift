/// クライアントのファイルシステム上のテキストファイルに内容を書き込むリクエスト。
public struct WriteTextFileRequest: ACPSchemaType {
    public var sessionId: SessionId
    public var path: String
    public var content: String
    public var meta: Meta?

    public init(sessionId: SessionId, path: String, content: String, meta: Meta? = nil) {
        self.sessionId = sessionId
        self.path = path
        self.content = content
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId, path, content
        case meta = "_meta"
    }
}

/// `fs/write_text_file` へのレスポンス。
public struct WriteTextFileResponse: ACPSchemaType {
    public var meta: Meta?

    public init(meta: Meta? = nil) {
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case meta = "_meta"
    }
}

/// クライアントのファイルシステム上のテキストファイルから内容を読み取るリクエスト。
public struct ReadTextFileRequest: ACPSchemaType {
    public var sessionId: SessionId
    public var path: String
    public var line: UInt32?
    public var limit: UInt32?
    public var meta: Meta?

    public init(
        sessionId: SessionId,
        path: String,
        line: UInt32? = nil,
        limit: UInt32? = nil,
        meta: Meta? = nil
    ) {
        self.sessionId = sessionId
        self.path = path
        self.line = line
        self.limit = limit
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId, path, line, limit
        case meta = "_meta"
    }
}

/// `fs/read_text_file` へのレスポンス。
public struct ReadTextFileResponse: ACPSchemaType {
    public var content: String
    public var meta: Meta?

    public init(content: String, meta: Meta? = nil) {
        self.content = content
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case content
        case meta = "_meta"
    }
}
