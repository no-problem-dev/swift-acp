/// How important a plan entry is relative to the others. Open: unknown values decode unchanged.
public struct PlanEntryPriority: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }

    public static let high = PlanEntryPriority("high")
    public static let medium = PlanEntryPriority("medium")
    public static let low = PlanEntryPriority("low")
}

/// Where a plan entry stands. Open: unknown values decode unchanged.
public struct PlanEntryStatus: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }

    public static let pending = PlanEntryStatus("pending")
    public static let inProgress = PlanEntryStatus("in_progress")
    public static let completed = PlanEntryStatus("completed")
}

/// One task in the agent's plan.
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

/// The agent's plan for the work it is doing.
///
/// Every update carries the complete list, so a client replaces its copy wholesale rather than
/// merging. Entries are not identified, so there is no way to track one across updates.
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
