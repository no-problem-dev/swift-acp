/// プランエントリの相対的な優先度。
public struct PlanEntryPriority: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }

    public static let high = PlanEntryPriority("high")
    public static let medium = PlanEntryPriority("medium")
    public static let low = PlanEntryPriority("low")
}

/// プランエントリの実行ステータス。
public struct PlanEntryStatus: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }

    public static let pending = PlanEntryStatus("pending")
    public static let inProgress = PlanEntryStatus("in_progress")
    public static let completed = PlanEntryStatus("completed")
}

/// 実行プランの1エントリ。エージェントが実行しようとするタスク。
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

/// 複雑なタスクを達成するための実行プラン。
///
/// 更新ごとにエントリの完全なリストを運ぶ。クライアントは更新のたびにプラン全体を置き換える。
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
