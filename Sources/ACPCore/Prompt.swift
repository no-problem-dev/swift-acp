/// The reason an agent stopped processing a prompt turn.
public struct StopReason: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }

    public static let endTurn = StopReason("end_turn")
    public static let maxTokens = StopReason("max_tokens")
    public static let maxTurnRequests = StopReason("max_turn_requests")
    public static let refusal = StopReason("refusal")
    public static let cancelled = StopReason("cancelled")
}

/// Request parameters for sending a user prompt to the agent.
public struct PromptRequest: ACPSchemaType {
    public var sessionId: SessionId
    public var prompt: [ContentBlock]
    public var meta: Meta?

    public init(sessionId: SessionId, prompt: [ContentBlock], meta: Meta? = nil) {
        self.sessionId = sessionId
        self.prompt = prompt
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId, prompt
        case meta = "_meta"
    }
}

/// Response from processing a user prompt.
public struct PromptResponse: ACPSchemaType {
    public var stopReason: StopReason
    public var meta: Meta?

    public init(stopReason: StopReason, meta: Meta? = nil) {
        self.stopReason = stopReason
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case stopReason
        case meta = "_meta"
    }
}
