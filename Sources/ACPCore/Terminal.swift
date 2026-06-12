/// An environment variable to set when launching a command in a terminal.
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

/// The exit status of a terminal command.
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

/// A request to create a new terminal and execute a command.
///
/// `args` and `env` are omitted on the wire when empty.
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

/// The response to `terminal/create`, carrying the new terminal's id.
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

/// A request for the current output and status of a terminal.
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

/// The response to `terminal/output`.
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

/// A request to release a terminal and free its resources.
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

/// The response to `terminal/release`.
public struct ReleaseTerminalResponse: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// A request to kill a terminal's command without releasing the terminal.
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

/// The response to `terminal/kill`.
public struct KillTerminalResponse: ACPSchemaType {
    public var meta: Meta?
    public init(meta: Meta? = nil) { self.meta = meta }
    private enum CodingKeys: String, CodingKey { case meta = "_meta" }
}

/// A request to wait for a terminal's command to exit.
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

/// The response to `terminal/wait_for_exit` — the exit status fields are
/// flattened onto this object in the wire schema.
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
