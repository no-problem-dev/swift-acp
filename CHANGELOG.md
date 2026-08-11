# Changelog

## [Unreleased]

### Changed

- Builds and tests on Linux. `StdioTransport` used `FileHandle.bytes`, which is Apple-only; it now
  reads in chunks on a dedicated thread. The thread is deliberate — reading a file handle blocks,
  so a `Task` would park a cooperative-pool thread for as long as the peer stays quiet.


## [0.2.0] - 2026-07-19

See [GitHub Releases](../../releases) for changes up to and including this version.
