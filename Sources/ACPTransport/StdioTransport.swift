import Foundation

/// A JSON-RPC frame transport over a pair of file handles (stdin/stdout by
/// default), framing messages as newline-delimited JSON — the canonical ACP
/// stdio wire format. Output writes are serialized.
public final class StdioTransport: ACPMessageTransport, @unchecked Sendable {
    private let input: FileHandle
    private let output: FileHandle
    private let writeLock = NSLock()

    public init(input: FileHandle = .standardInput, output: FileHandle = .standardOutput) {
        self.input = input
        self.output = output
    }

    public func send(_ frame: Data) async throws {
        var line = frame
        line.append(0x0A) // '\n'
        try writeLock.withLock {
            try output.write(contentsOf: line)
        }
    }

    public func messages() -> AsyncThrowingStream<Data, any Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                var buffer = Data()
                do {
                    for try await byte in input.bytes {
                        if byte == 0x0A {
                            if !buffer.isEmpty {
                                continuation.yield(buffer)
                                buffer.removeAll(keepingCapacity: true)
                            }
                        } else {
                            buffer.append(byte)
                        }
                    }
                    if !buffer.isEmpty { continuation.yield(buffer) }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
