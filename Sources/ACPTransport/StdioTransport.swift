import Foundation

/// Carries frames over a pair of file handles, stdin and stdout by default — the wire format ACP
/// standardizes on for locally spawned agents.
///
/// Frames are newline-delimited JSON, so an encoded frame must not contain a literal newline; the
/// encoders used here never emit one. Writes are serialized under a lock, making it safe for an
/// agent to answer requests while pushing updates.
///
/// Reading is byte-at-a-time and a blank line is skipped rather than treated as an empty frame.
/// A trailing fragment with no closing newline is still delivered when the input ends.
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
