/// The JSON-RPC method names ACP v1 defines.
///
/// The values are pinned to the vendored `Spec/v1/meta.json`, and the conformance suite requires
/// the tables below to equal that registry exactly — no missing, extra or misspelled method.
public enum ACPMethod {
    /// Methods an agent answers, called by the client.
    public enum Agent {
        public static let initialize = "initialize"
        public static let authenticate = "authenticate"
        public static let sessionNew = "session/new"
        public static let sessionLoad = "session/load"
        public static let sessionSetMode = "session/set_mode"
        public static let sessionSetConfigOption = "session/set_config_option"
        public static let sessionPrompt = "session/prompt"
        public static let sessionCancel = "session/cancel"
        public static let sessionList = "session/list"
        public static let sessionDelete = "session/delete"
        public static let sessionResume = "session/resume"
        public static let sessionClose = "session/close"
        public static let logout = "logout"
    }

    /// Methods a client answers, called by the agent.
    public enum Client {
        public static let sessionRequestPermission = "session/request_permission"
        public static let sessionUpdate = "session/update"
        public static let fsWriteTextFile = "fs/write_text_file"
        public static let fsReadTextFile = "fs/read_text_file"
        public static let terminalCreate = "terminal/create"
        public static let terminalOutput = "terminal/output"
        public static let terminalRelease = "terminal/release"
        public static let terminalWaitForExit = "terminal/wait_for_exit"
        public static let terminalKill = "terminal/kill"
    }

    /// The agent methods keyed as the registry keys them, for the parity check. Prefer the named
    /// constants above when dispatching.
    public static let agentMethods: [String: String] = [
        "initialize": Agent.initialize,
        "authenticate": Agent.authenticate,
        "session_new": Agent.sessionNew,
        "session_load": Agent.sessionLoad,
        "session_set_mode": Agent.sessionSetMode,
        "session_set_config_option": Agent.sessionSetConfigOption,
        "session_prompt": Agent.sessionPrompt,
        "session_cancel": Agent.sessionCancel,
        "session_list": Agent.sessionList,
        "session_delete": Agent.sessionDelete,
        "session_resume": Agent.sessionResume,
        "session_close": Agent.sessionClose,
        "logout": Agent.logout,
    ]

    /// The client methods keyed as the registry keys them, for the parity check. Prefer the named
    /// constants above when dispatching.
    public static let clientMethods: [String: String] = [
        "session_request_permission": Client.sessionRequestPermission,
        "session_update": Client.sessionUpdate,
        "fs_write_text_file": Client.fsWriteTextFile,
        "fs_read_text_file": Client.fsReadTextFile,
        "terminal_create": Client.terminalCreate,
        "terminal_output": Client.terminalOutput,
        "terminal_release": Client.terminalRelease,
        "terminal_wait_for_exit": Client.terminalWaitForExit,
        "terminal_kill": Client.terminalKill,
    ]
}
