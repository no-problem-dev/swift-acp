/// The text typed after a command name, provided as the command's input.
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

/// The input specification for a command (untagged).
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

/// A command the agent can execute.
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

/// Notification that the set of available commands is ready or has changed.
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
