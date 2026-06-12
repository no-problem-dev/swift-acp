/// The schema definitions owned by the ACP domain layer.
///
/// Populated incrementally as `$defs` are modelled; the conformance suite
/// drives this set to cover every domain definition in the pinned schema.
public enum ACPCoreSchema {
    public static let types: [any ACPSchemaType.Type] = [
        // Ids
        SessionId.self, ToolCallId.self, MessageId.self, PermissionOptionId.self,
        SessionModeId.self, SessionConfigId.self, SessionConfigGroupId.self, SessionConfigValueId.self,

        // Content
        Role.self, Annotations.self, TextContent.self, ImageContent.self, AudioContent.self,
        TextResourceContents.self, BlobResourceContents.self, EmbeddedResourceResource.self,
        EmbeddedResource.self, ResourceLink.self, ContentBlock.self, Content.self, ContentChunk.self,

        // Plan
        PlanEntryPriority.self, PlanEntryStatus.self, PlanEntry.self, Plan.self,

        // Tool calls
        ToolKind.self, ToolCallStatus.self, Diff.self, Terminal.self, ToolCallLocation.self,
        ToolCallContent.self, ToolCall.self, ToolCallUpdate.self,

        // Session updates
        Cost.self, UsageUpdate.self, CurrentModeUpdate.self, ConfigOptionUpdate.self,
        SessionInfoUpdate.self, SessionUpdate.self, SessionNotification.self,

        // Commands
        UnstructuredCommandInput.self, AvailableCommandInput.self, AvailableCommand.self,
        AvailableCommandsUpdate.self,

        // Permission
        PermissionOptionKind.self, PermissionOption.self, RequestPermissionRequest.self,
        SelectedPermissionOutcome.self, RequestPermissionOutcome.self, RequestPermissionResponse.self,

        // File system
        WriteTextFileRequest.self, WriteTextFileResponse.self, ReadTextFileRequest.self,
        ReadTextFileResponse.self,

        // Terminals
        EnvVariable.self, TerminalExitStatus.self, CreateTerminalRequest.self, CreateTerminalResponse.self,
        TerminalOutputRequest.self, TerminalOutputResponse.self, ReleaseTerminalRequest.self,
        ReleaseTerminalResponse.self, KillTerminalRequest.self, KillTerminalResponse.self,
        WaitForTerminalExitRequest.self, WaitForTerminalExitResponse.self,

        // Client capabilities
        FileSystemCapabilities.self, ClientCapabilities.self,

        // Initialization & capabilities
        ProtocolVersion.self, Implementation.self, PromptCapabilities.self, McpCapabilities.self,
        SessionListCapabilities.self, SessionDeleteCapabilities.self,
        SessionAdditionalDirectoriesCapabilities.self, SessionResumeCapabilities.self,
        SessionCloseCapabilities.self, SessionCapabilities.self, LogoutCapabilities.self,
        AgentAuthCapabilities.self, AgentCapabilities.self, InitializeRequest.self, InitializeResponse.self,

        // Session lifecycle
        NewSessionRequest.self, NewSessionResponse.self, LoadSessionRequest.self, LoadSessionResponse.self,
        ListSessionsRequest.self, ListSessionsResponse.self, ResumeSessionRequest.self, ResumeSessionResponse.self,
        DeleteSessionRequest.self, DeleteSessionResponse.self, CloseSessionRequest.self, CloseSessionResponse.self,
        SessionInfo.self, SessionMode.self, SessionModeState.self, SetSessionModeRequest.self,
        SetSessionModeResponse.self,

        // Session config
        SessionConfigOptionCategory.self, SessionConfigSelectOption.self, SessionConfigSelectGroup.self,
        SessionConfigSelectOptions.self, SessionConfigSelect.self, SessionConfigOption.self,
        SetSessionConfigOptionRequest.self, SetSessionConfigOptionResponse.self,

        // Prompt
        StopReason.self, PromptRequest.self, PromptResponse.self,

        // Auth
        AuthMethodAgent.self, AuthMethod.self, AuthenticateRequest.self, AuthenticateResponse.self,
        LogoutRequest.self, LogoutResponse.self,

        // MCP
        HttpHeader.self, McpServerHttp.self, McpServerSse.self, McpServerStdio.self, McpServer.self,

        // Extension & cancellation
        ExtRequest.self, ExtResponse.self, ExtNotification.self, CancelNotification.self,

        // Routing envelopes
        AgentRequest.self, ClientResponse.self, AgentNotification.self,
        ClientRequest.self, AgentResponse.self, ClientNotification.self,
    ]
}
