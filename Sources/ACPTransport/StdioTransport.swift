import Foundation

/// Carries frames over a pair of file handles, stdin and stdout by default — the wire format ACP
/// standardizes on for locally spawned agents.
///
/// Frames are newline-delimited JSON, so an encoded frame must not contain a literal newline; the
/// encoders used here never emit one. Writes are serialized under a lock, making it safe for an
/// agent to answer requests while pushing updates.
///
/// Input is read in chunks and split on newlines; a blank line is skipped rather than treated as an
/// empty frame. A trailing fragment with no closing newline is still delivered when the input ends.
///
/// The read loop runs on a thread of its own because reading a file handle blocks. Handing that
/// blocking call to a `Task` would park a thread of the cooperative pool for as long as the peer
/// stays quiet.
public final class StdioTransport: ACPMessageTransport, @unchecked Sendable {
    private static let readChunkSize = 4096

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
            let input = self.input
            let chunkSize = Self.readChunkSize
            let stop = StopSignal()

            let reader = Thread {
                var buffer = Data()
                do {
                    while !stop.isRaised {
                        guard let chunk = try input.read(upToCount: chunkSize), !chunk.isEmpty else { break }
                        for byte in chunk {
                            if byte == 0x0A {
                                if !buffer.isEmpty {
                                    continuation.yield(buffer)
                                    buffer.removeAll(keepingCapacity: true)
                                }
                            } else {
                                buffer.append(byte)
                            }
                        }
                    }
                    if !buffer.isEmpty { continuation.yield(buffer) }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            reader.name = "ACPTransport.StdioTransport"

            continuation.onTermination = { _ in stop.raise() }
            reader.start()
        }
    }
}

/// A one-way flag the consumer raises to end the read loop. The loop checks it between reads, so a
/// read already blocked on an idle handle returns first.
private final class StopSignal: @unchecked Sendable {
    private let lock = NSLock()
    private var raised = false

    var isRaised: Bool { lock.withLock { raised } }

    func raise() { lock.withLock { raised = true } }
}
