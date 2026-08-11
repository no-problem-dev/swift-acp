/// Identifies one conversation between a client and an agent. Assigned by the agent.
public struct SessionId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// Identifies a tool call within its session, and is what ties an update to the call it revises.
public struct ToolCallId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// Identifies a message within its session.
///
/// Every chunk of one message carries the same value, so a change of identifier is what marks the
/// start of a new message in a stream.
public struct MessageId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// Identifies one of the choices offered in a permission request, and is what the response sends
/// back.
public struct PermissionOptionId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// Identifies a session mode, such as `ask` or `code`.
public struct SessionModeId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// Identifies a session configuration option.
public struct SessionConfigId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// Identifies a group of configuration values, for options whose choices are grouped.
public struct SessionConfigGroupId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// Identifies one selectable value within a configuration option.
public struct SessionConfigValueId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}
