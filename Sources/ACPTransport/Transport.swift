import Foundation
import ACPCore

/// A bidirectional transport for JSON-RPC message frames.
///
/// This is the *serialized* boundary used by the stdio adapter (and any network
/// adapter). The in-process path deliberately does **not** go through it — there
/// the ACP types cross as Swift values with no encoding (see `InProcessConnection`).
public protocol ACPMessageTransport: Sendable {
    /// Send one encoded JSON-RPC message frame.
    func send(_ frame: Data) async throws

    /// The stream of incoming JSON-RPC message frames, one element per frame.
    func messages() -> AsyncThrowingStream<Data, any Error>
}

/// Errors raised by the transport layer.
public enum ACPTransportError: Error, Equatable, Sendable {
    /// The peer sent a method this side does not implement.
    case methodNotSupported(String)
    /// A response arrived for a request id that was not pending.
    case unexpectedResponse(RequestId)
    /// The transport was closed before a pending request completed.
    case closed
}
