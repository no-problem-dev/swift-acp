/// The relative importance of a plan entry.
public struct PlanEntryPriority: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }

    public static let high = PlanEntryPriority("high")
    public static let medium = PlanEntryPriority("medium")
    public static let low = PlanEntryPriority("low")
}

/// The execution status of a plan entry.
public struct PlanEntryStatus: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }

    public static let pending = PlanEntryStatus("pending")
    public static let inProgress = PlanEntryStatus("in_progress")
    public static let completed = PlanEntryStatus("completed")
}

/// A single entry in an execution plan: a task the agent intends to accomplish.
public struct PlanEntry: ACPSchemaType {
    public var content: String
    public var priority: PlanEntryPriority
    public var status: PlanEntryStatus
    public var meta: Meta?

    public init(
        content: String,
        priority: PlanEntryPriority,
        status: PlanEntryStatus,
        meta: Meta? = nil
    ) {
        self.content = content
        self.priority = priority
        self.status = status
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case content, priority, status
        case meta = "_meta"
    }
}

/// An execution plan for accomplishing a complex task.
///
/// Each update carries the complete list of entries; the client replaces the
/// whole plan with every update.
public struct Plan: ACPSchemaType {
    public var entries: [PlanEntry]
    public var meta: Meta?

    public init(entries: [PlanEntry], meta: Meta? = nil) {
        self.entries = entries
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case entries
        case meta = "_meta"
    }
}
