/// A unique identifier for a conversation session between a client and agent.
public struct SessionId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// Unique identifier for a tool call within a session.
public struct ToolCallId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// Unique identifier for a message within a session.
///
/// All chunks belonging to the same message share the same `MessageId`; a
/// change indicates a new message has started.
public struct MessageId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// Identifier for a permission option presented to the user.
public struct PermissionOptionId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// Identifier for a session mode (e.g. "ask", "code").
public struct SessionModeId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// Identifier for a session configuration option.
public struct SessionConfigId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// Identifier for a group of session configuration options.
public struct SessionConfigGroupId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// Identifier for a value within a session configuration option.
public struct SessionConfigValueId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}
