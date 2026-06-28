/// コマンド名の後に入力されたテキスト。コマンドの入力として渡される。
public struct UnstructuredCommandInput: ACPSchemaType {
    public var hint: String
    public var meta: Meta?

    public init(hint: String, meta: Meta? = nil) {
        self.hint = hint
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case hint
        case meta = "_meta"
    }
}

/// コマンドの入力仕様（タグなし）。
public enum AvailableCommandInput: ACPSchemaType {
    case unstructured(UnstructuredCommandInput)
    case unknown(JSONValue)

    public init(from decoder: any Decoder) throws {
        if let value = try? UnstructuredCommandInput(from: decoder) {
            self = .unstructured(value)
        } else {
            self = .unknown(try JSONValue(from: decoder))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .unstructured(value): try value.encode(to: encoder)
        case let .unknown(raw): try raw.encode(to: encoder)
        }
    }
}

/// エージェントが実行できるコマンド。
public struct AvailableCommand: ACPSchemaType {
    public var name: String
    public var description: String
    public var input: AvailableCommandInput?
    public var meta: Meta?

    public init(
        name: String,
        description: String,
        input: AvailableCommandInput? = nil,
        meta: Meta? = nil
    ) {
        self.name = name
        self.description = description
        self.input = input
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case name, description, input
        case meta = "_meta"
    }
}

/// 利用可能なコマンドセットが準備完了または変更されたことを通知する更新。
public struct AvailableCommandsUpdate: ACPSchemaType {
    public var availableCommands: [AvailableCommand]
    public var meta: Meta?

    public init(availableCommands: [AvailableCommand], meta: Meta? = nil) {
        self.availableCommands = availableCommands
        self.meta = meta
    }

    private enum CodingKeys: String, CodingKey {
        case availableCommands
        case meta = "_meta"
    }
}
