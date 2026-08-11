import Foundation
import ACPCore

/// Moves encoded frames between two peers — the serialization boundary, and the only place bytes
/// exist.
///
/// The in-process path deliberately does not go through this: there, ACP types are passed as Swift
/// values with nothing encoded at all. Implement this to carry ACP over something other than
/// stdio; framing is the implementation's business, and the value handed to `send` must arrive at
/// the peer's `messages()` as exactly one element.
public protocol ACPMessageTransport: Sendable {
    /// Sends one encoded frame.
    func send(_ frame: Data) async throws

    /// The frames arriving from the peer, one element per frame, in the order they arrive.
    ///
    /// The stream finishes when the peer closes, and throws if the underlying channel fails. Only
    /// one consumer is expected.
    func messages() -> AsyncThrowingStream<Data, any Error>
}

/// What the transport layer reports when a call cannot be completed.
public enum ACPTransportError: Error, Equatable, Sendable {
    /// The peer asked for a method this side does not implement.
    case methodNotSupported(String)
    /// A response arrived for an id nothing was waiting on.
    ///
    /// - Note: Not thrown by anything shipped here. `AgentConnection` drops such a response
    ///   silently instead.
    case unexpectedResponse(RequestId)
    /// The transport closed while requests were still outstanding. Every pending call fails with
    /// this.
    case closed
}
