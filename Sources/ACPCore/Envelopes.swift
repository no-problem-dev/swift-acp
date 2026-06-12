// The routing envelopes: untagged unions over every method's params/result, in
// each direction. They mirror the schema's `AgentRequest`/`ClientResponse`/…
// `$defs`. A transport normally dispatches by JSON-RPC method name; these exist
// for completeness and for callers that want a single typed value per channel.
// Untagged decoding tries each variant in declaration order (the extension
// variant, which accepts any JSON, is always last).

/// A request sent from an agent to a client (agent → client).
public enum AgentRequest: ACPSchemaType {
    case writeTextFile(WriteTextFileRequest)
    case readTextFile(ReadTextFileRequest)
    case requestPermission(RequestPermissionRequest)
    case createTerminal(CreateTerminalRequest)
    case terminalOutput(TerminalOutputRequest)
    case releaseTerminal(ReleaseTerminalRequest)
    case waitForTerminalExit(WaitForTerminalExitRequest)
    case killTerminal(KillTerminalRequest)
    case ext(ExtRequest)

    public var method: String {
        switch self {
        case .writeTextFile: ACPMethod.Client.fsWriteTextFile
        case .readTextFile: ACPMethod.Client.fsReadTextFile
        case .requestPermission: ACPMethod.Client.sessionRequestPermission
        case .createTerminal: ACPMethod.Client.terminalCreate
        case .terminalOutput: ACPMethod.Client.terminalOutput
        case .releaseTerminal: ACPMethod.Client.terminalRelease
        case .waitForTerminalExit: ACPMethod.Client.terminalWaitForExit
        case .killTerminal: ACPMethod.Client.terminalKill
        case let .ext(request): request.method
        }
    }

    public init(from decoder: any Decoder) throws {
        if let v = try? RequestPermissionRequest(from: decoder) { self = .requestPermission(v); return }
        if let v = try? WriteTextFileRequest(from: decoder) { self = .writeTextFile(v); return }
        if let v = try? CreateTerminalRequest(from: decoder) { self = .createTerminal(v); return }
        if let v = try? ReadTextFileRequest(from: decoder) { self = .readTextFile(v); return }
        if let v = try? WaitForTerminalExitRequest(from: decoder) { self = .waitForTerminalExit(v); return }
        if let v = try? TerminalOutputRequest(from: decoder) { self = .terminalOutput(v); return }
        if let v = try? ReleaseTerminalRequest(from: decoder) { self = .releaseTerminal(v); return }
        if let v = try? KillTerminalRequest(from: decoder) { self = .killTerminal(v); return }
        self = .ext(try ExtRequest(from: decoder))
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .writeTextFile(v): try v.encode(to: encoder)
        case let .readTextFile(v): try v.encode(to: encoder)
        case let .requestPermission(v): try v.encode(to: encoder)
        case let .createTerminal(v): try v.encode(to: encoder)
        case let .terminalOutput(v): try v.encode(to: encoder)
        case let .releaseTerminal(v): try v.encode(to: encoder)
        case let .waitForTerminalExit(v): try v.encode(to: encoder)
        case let .killTerminal(v): try v.encode(to: encoder)
        case let .ext(v): try v.encode(to: encoder)
        }
    }
}

/// A response sent from a client to an agent (reply to an `AgentRequest`).
public enum ClientResponse: ACPSchemaType {
    case writeTextFile(WriteTextFileResponse)
    case readTextFile(ReadTextFileResponse)
    case requestPermission(RequestPermissionResponse)
    case createTerminal(CreateTerminalResponse)
    case terminalOutput(TerminalOutputResponse)
    case releaseTerminal(ReleaseTerminalResponse)
    case waitForTerminalExit(WaitForTerminalExitResponse)
    case killTerminal(KillTerminalResponse)
    case ext(ExtResponse)

    public init(from decoder: any Decoder) throws {
        if let v = try? RequestPermissionResponse(from: decoder) { self = .requestPermission(v); return }
        if let v = try? ReadTextFileResponse(from: decoder) { self = .readTextFile(v); return }
        if let v = try? CreateTerminalResponse(from: decoder) { self = .createTerminal(v); return }
        if let v = try? TerminalOutputResponse(from: decoder) { self = .terminalOutput(v); return }
        if let v = try? WaitForTerminalExitResponse(from: decoder) { self = .waitForTerminalExit(v); return }
        if let v = try? WriteTextFileResponse(from: decoder) { self = .writeTextFile(v); return }
        if let v = try? ReleaseTerminalResponse(from: decoder) { self = .releaseTerminal(v); return }
        if let v = try? KillTerminalResponse(from: decoder) { self = .killTerminal(v); return }
        self = .ext(try ExtResponse(from: decoder))
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .writeTextFile(v): try v.encode(to: encoder)
        case let .readTextFile(v): try v.encode(to: encoder)
        case let .requestPermission(v): try v.encode(to: encoder)
        case let .createTerminal(v): try v.encode(to: encoder)
        case let .terminalOutput(v): try v.encode(to: encoder)
        case let .releaseTerminal(v): try v.encode(to: encoder)
        case let .waitForTerminalExit(v): try v.encode(to: encoder)
        case let .killTerminal(v): try v.encode(to: encoder)
        case let .ext(v): try v.encode(to: encoder)
        }
    }
}

/// A notification sent from an agent to a client (agent → client).
public enum AgentNotification: ACPSchemaType {
    case sessionUpdate(SessionNotification)
    case ext(ExtNotification)

    public var method: String {
        switch self {
        case .sessionUpdate: ACPMethod.Client.sessionUpdate
        case let .ext(notification): notification.method
        }
    }

    public init(from decoder: any Decoder) throws {
        if let v = try? SessionNotification(from: decoder) { self = .sessionUpdate(v); return }
        self = .ext(try ExtNotification(from: decoder))
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .sessionUpdate(v): try v.encode(to: encoder)
        case let .ext(v): try v.encode(to: encoder)
        }
    }
}

/// A request sent from a client to an agent (client → agent).
public enum ClientRequest: ACPSchemaType {
    case initialize(InitializeRequest)
    case authenticate(AuthenticateRequest)
    case logout(LogoutRequest)
    case newSession(NewSessionRequest)
    case loadSession(LoadSessionRequest)
    case listSessions(ListSessionsRequest)
    case deleteSession(DeleteSessionRequest)
    case resumeSession(ResumeSessionRequest)
    case closeSession(CloseSessionRequest)
    case setSessionMode(SetSessionModeRequest)
    case setSessionConfigOption(SetSessionConfigOptionRequest)
    case prompt(PromptRequest)
    case ext(ExtRequest)

    public var method: String {
        switch self {
        case .initialize: ACPMethod.Agent.initialize
        case .authenticate: ACPMethod.Agent.authenticate
        case .logout: ACPMethod.Agent.logout
        case .newSession: ACPMethod.Agent.sessionNew
        case .loadSession: ACPMethod.Agent.sessionLoad
        case .listSessions: ACPMethod.Agent.sessionList
        case .deleteSession: ACPMethod.Agent.sessionDelete
        case .resumeSession: ACPMethod.Agent.sessionResume
        case .closeSession: ACPMethod.Agent.sessionClose
        case .setSessionMode: ACPMethod.Agent.sessionSetMode
        case .setSessionConfigOption: ACPMethod.Agent.sessionSetConfigOption
        case .prompt: ACPMethod.Agent.sessionPrompt
        case let .ext(request): request.method
        }
    }

    public init(from decoder: any Decoder) throws {
        if let v = try? InitializeRequest(from: decoder) { self = .initialize(v); return }
        if let v = try? AuthenticateRequest(from: decoder) { self = .authenticate(v); return }
        if let v = try? PromptRequest(from: decoder) { self = .prompt(v); return }
        if let v = try? SetSessionConfigOptionRequest(from: decoder) { self = .setSessionConfigOption(v); return }
        if let v = try? SetSessionModeRequest(from: decoder) { self = .setSessionMode(v); return }
        if let v = try? NewSessionRequest(from: decoder) { self = .newSession(v); return }
        if let v = try? LoadSessionRequest(from: decoder) { self = .loadSession(v); return }
        if let v = try? ResumeSessionRequest(from: decoder) { self = .resumeSession(v); return }
        if let v = try? DeleteSessionRequest(from: decoder) { self = .deleteSession(v); return }
        if let v = try? CloseSessionRequest(from: decoder) { self = .closeSession(v); return }
        if let v = try? ListSessionsRequest(from: decoder) { self = .listSessions(v); return }
        if let v = try? LogoutRequest(from: decoder) { self = .logout(v); return }
        self = .ext(try ExtRequest(from: decoder))
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .initialize(v): try v.encode(to: encoder)
        case let .authenticate(v): try v.encode(to: encoder)
        case let .logout(v): try v.encode(to: encoder)
        case let .newSession(v): try v.encode(to: encoder)
        case let .loadSession(v): try v.encode(to: encoder)
        case let .listSessions(v): try v.encode(to: encoder)
        case let .deleteSession(v): try v.encode(to: encoder)
        case let .resumeSession(v): try v.encode(to: encoder)
        case let .closeSession(v): try v.encode(to: encoder)
        case let .setSessionMode(v): try v.encode(to: encoder)
        case let .setSessionConfigOption(v): try v.encode(to: encoder)
        case let .prompt(v): try v.encode(to: encoder)
        case let .ext(v): try v.encode(to: encoder)
        }
    }
}

/// A response sent from an agent to a client (reply to a `ClientRequest`).
public enum AgentResponse: ACPSchemaType {
    case initialize(InitializeResponse)
    case authenticate(AuthenticateResponse)
    case logout(LogoutResponse)
    case newSession(NewSessionResponse)
    case loadSession(LoadSessionResponse)
    case listSessions(ListSessionsResponse)
    case deleteSession(DeleteSessionResponse)
    case resumeSession(ResumeSessionResponse)
    case closeSession(CloseSessionResponse)
    case setSessionMode(SetSessionModeResponse)
    case setSessionConfigOption(SetSessionConfigOptionResponse)
    case prompt(PromptResponse)
    case ext(ExtResponse)

    public init(from decoder: any Decoder) throws {
        if let v = try? InitializeResponse(from: decoder) { self = .initialize(v); return }
        if let v = try? NewSessionResponse(from: decoder) { self = .newSession(v); return }
        if let v = try? ListSessionsResponse(from: decoder) { self = .listSessions(v); return }
        if let v = try? PromptResponse(from: decoder) { self = .prompt(v); return }
        if let v = try? LoadSessionResponse(from: decoder) { self = .loadSession(v); return }
        if let v = try? ResumeSessionResponse(from: decoder) { self = .resumeSession(v); return }
        if let v = try? SetSessionModeResponse(from: decoder) { self = .setSessionMode(v); return }
        if let v = try? SetSessionConfigOptionResponse(from: decoder) { self = .setSessionConfigOption(v); return }
        if let v = try? AuthenticateResponse(from: decoder) { self = .authenticate(v); return }
        if let v = try? LogoutResponse(from: decoder) { self = .logout(v); return }
        if let v = try? DeleteSessionResponse(from: decoder) { self = .deleteSession(v); return }
        if let v = try? CloseSessionResponse(from: decoder) { self = .closeSession(v); return }
        self = .ext(try ExtResponse(from: decoder))
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .initialize(v): try v.encode(to: encoder)
        case let .authenticate(v): try v.encode(to: encoder)
        case let .logout(v): try v.encode(to: encoder)
        case let .newSession(v): try v.encode(to: encoder)
        case let .loadSession(v): try v.encode(to: encoder)
        case let .listSessions(v): try v.encode(to: encoder)
        case let .deleteSession(v): try v.encode(to: encoder)
        case let .resumeSession(v): try v.encode(to: encoder)
        case let .closeSession(v): try v.encode(to: encoder)
        case let .setSessionMode(v): try v.encode(to: encoder)
        case let .setSessionConfigOption(v): try v.encode(to: encoder)
        case let .prompt(v): try v.encode(to: encoder)
        case let .ext(v): try v.encode(to: encoder)
        }
    }
}

/// A notification sent from a client to an agent (client → agent).
public enum ClientNotification: ACPSchemaType {
    case cancel(CancelNotification)
    case ext(ExtNotification)

    public var method: String {
        switch self {
        case .cancel: ACPMethod.Agent.sessionCancel
        case let .ext(notification): notification.method
        }
    }

    public init(from decoder: any Decoder) throws {
        if let v = try? CancelNotification(from: decoder) { self = .cancel(v); return }
        self = .ext(try ExtNotification(from: decoder))
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .cancel(v): try v.encode(to: encoder)
        case let .ext(v): try v.encode(to: encoder)
        }
    }
}
