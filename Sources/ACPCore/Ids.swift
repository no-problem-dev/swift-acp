/// クライアントとエージェント間の会話セッションの一意識別子。
public struct SessionId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// セッション内のツール呼び出しの一意識別子。
public struct ToolCallId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// セッション内のメッセージの一意識別子。
///
/// 同一メッセージのチャンクはすべて同じ `MessageId` を共有し、
/// 変化は新しいメッセージの開始を示す。
public struct MessageId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// ユーザーに提示するパーミッションオプションの識別子。
public struct PermissionOptionId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// セッションモード（例: "ask"、"code"）の識別子。
public struct SessionModeId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// セッション設定オプションの識別子。
public struct SessionConfigId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// セッション設定オプショングループの識別子。
public struct SessionConfigGroupId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}

/// セッション設定オプション内の値の識別子。
public struct SessionConfigValueId: ACPStringNewType {
    public let rawValue: String
    public init(_ value: String) { rawValue = value }
}
