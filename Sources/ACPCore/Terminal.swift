/// ターミナルでコマンドを起動するときに設定する環境変数。
public struct EnvVariable: ACPSchemaType {
    public var name: String
    public var value: String
    public var meta: Meta?

    public init(name: String, value: String, meta: Meta? = nil) {
        self.name = name
        self.value = value
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case name, value
        case meta = "_meta"
    }
}

/// ターミナルコマンドの終了ステータス。
public struct TerminalExitStatus: ACPSchemaType {
    public var exitCode: UInt32?
    public var signal: String?
    public var meta: Meta?

    public init(exitCode: UInt32? = nil, signal: String? = nil, meta: Meta? = nil) {
        self.exitCode = exitCode
        self.signal = signal
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case exitCode, signal
        case meta = "_meta"
    }
}

/// 新しいターミナルを作成してコマンドを実行するリクエスト。
///
/// `args` と `env` は空のときワイヤーから省略される。
public struct CreateTerminalRequest: ACPSchemaType {
    public var sessionId: SessionId
    public var command: String
    public var args: [String]
    public var env: [EnvVariable]
    public var cwd: String?
    public var outputByteLimit: UInt64?
    public var meta: Meta?

    public init(
        sessionId: SessionId,
        command: String,
        args: [String] = [],
        env: [EnvVariable] = [],
        cwd: String? = nil,
        outputByteLimit: UInt64? = nil,
        meta: Meta? = nil
    ) {
        self.sessionId = sessionId
        self.command = command
        self.args = args
        self.env = env
        self.cwd = cwd
        self.outputByteLimit = outputByteLimit
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId, command, args, env, cwd, outputByteLimit
        case meta = "_meta"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sessionId = try container.decode(SessionId.self, forKey: .sessionId)
        command = try container.decode(String.self, forKey: .command)
        args = try container.decodeIfPresent([String].self, forKey: .args) ?? []
        env = try container.decodeIfPresent([EnvVariable].self, forKey: .env) ?? []
        cwd = try container.decodeIfPresent(String.self, forKey: .cwd)
        outputByteLimit = try container.decodeIfPresent(UInt64.self, forKey: .outputByteLimit)
        meta = try container.decodeIfPresent(Meta.self, forKey: .meta)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sessionId, forKey: .sessionId)
        try container.encode(command, forKey: .command)
        if !args.isEmpty { try container.encode(args, forKey: .args) }
        if !env.isEmpty { try container.encode(env, forKey: .env) }
        try container.encodeIfPresent(cwd, forKey: .cwd)
        try container.encodeIfPresent(outputByteLimit, forKey: .outputByteLimit)
        try container.encodeIfPresent(meta, forKey: .meta)
    }
}

/// `terminal/create` へのレスポンス。新しいターミナルの `terminalId` を持つ。
public struct CreateTerminalResponse: ACPSchemaType {
    public var terminalId: TerminalId
    public var meta: Meta?

    public init(terminalId: TerminalId, meta: Meta? = nil) {
        self.terminalId = terminalId
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case terminalId
        case meta = "_meta"
    }
}

/// ターミナルの現在の出力とステータスを取得するリクエスト。
public struct TerminalOutputRequest: ACPSchemaType {
    public var sessionId: SessionId
    public var terminalId: TerminalId
    public var meta: Meta?

    public init(sessionId: SessionId, terminalId: TerminalId, meta: Meta? = nil) {
        self.sessionId = sessionId
        self.terminalId = terminalId
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId, terminalId
        case meta = "_meta"
    }
}

/// `terminal/output` へのレスポンス。
public struct TerminalOutputResponse: ACPSchemaType {
    public var output: String
    public var truncated: Bool
    public var exitStatus: TerminalExitStatus?
    public var meta: Meta?

    public init(output: String, truncated: Bool, exitStatus: TerminalExitStatus? = nil, meta: Meta? = nil) {
        self.output = output
        self.truncated = truncated
        self.exitStatus = exitStatus
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case output, truncated, exitStatus
        case meta = "_meta"
    }
}

/// ターミナルを解放してリソースを解放するリクエスト。
public struct ReleaseTerminalRequest: ACPSchemaType {
    public var sessionId: SessionId
    public var terminalId: TerminalId
    public var meta: Meta?

    public init(sessionId: SessionId, terminalId: TerminalId, meta: Meta? = nil) {
        self.sessionId = sessionId
        self.terminalId = terminalId
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId, terminalId
        case meta = "_meta"
    }
}

/// `terminal/release` へのレスポンス。
public struct ReleaseTerminalResponse: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// ターミナルを解放せずにコマンドをキルするリクエスト。
public struct KillTerminalRequest: ACPSchemaType {
    public var sessionId: SessionId
    public var terminalId: TerminalId
    public var meta: Meta?

    public init(sessionId: SessionId, terminalId: TerminalId, meta: Meta? = nil) {
        self.sessionId = sessionId
        self.terminalId = terminalId
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId, terminalId
        case meta = "_meta"
    }
}

/// `terminal/kill` へのレスポンス。
public struct KillTerminalResponse: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// ターミナルのコマンドが終了するまで待機するリクエスト。
public struct WaitForTerminalExitRequest: ACPSchemaType {
    public var sessionId: SessionId
    public var terminalId: TerminalId
    public var meta: Meta?

    public init(sessionId: SessionId, terminalId: TerminalId, meta: Meta? = nil) {
        self.sessionId = sessionId
        self.terminalId = terminalId
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId, terminalId
        case meta = "_meta"
    }
}

/// `terminal/wait_for_exit` へのレスポンス。終了ステータスフィールドがワイヤースキーマでこのオブジェクトにフラット化される。
public struct WaitForTerminalExitResponse: ACPSchemaType {
    public var exitCode: UInt32?
    public var signal: String?
    public var meta: Meta?

    public init(exitCode: UInt32? = nil, signal: String? = nil, meta: Meta? = nil) {
        self.exitCode = exitCode
        self.signal = signal
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case exitCode, signal
        case meta = "_meta"
    }
}
