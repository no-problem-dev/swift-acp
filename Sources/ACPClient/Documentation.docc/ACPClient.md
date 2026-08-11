# ``ACPClient``

The one protocol a host implements: where an agent reports, and what it may borrow.

## Overview

``ACPClient`` is the client half of the protocol — everything an agent may call back into. The host
is usually an editor, a mobile app, or a CLI driving a user-facing UI.

Only `sessionUpdate(_:)` matters in every deployment: the agent calls it for each piece of progress
during a turn, and the host renders the result. Everything else is a capability the host lends and
may decline. The file-system methods expose the host's files; the terminal methods give the agent a
supervised shell; `requestPermission` lets the user gate a tool call before it runs.

A host advertises what it offers in the `ClientCapabilities` it sends during initialization.
Nothing checks that the advertisement matches the implementation, so the methods you do not
implement should throw and the capability should say so.

For a host that only watches, `ACPTransport` already ships `StreamingSessionClient`: it turns
updates into an `AsyncStream` and refuses every borrowed capability.

```swift
import ACPCore
import ACPClient

actor CollectingClient: ACPClient {
    private(set) var received: [SessionUpdate] = []

    func sessionUpdate(_ notification: SessionNotification) async throws {
        received.append(notification.update)
    }

    func requestPermission(_ r: RequestPermissionRequest) async throws -> RequestPermissionResponse {
        throw RPCError(code: .methodNotFound, message: "permissions are not supported")
    }

    // The file-system and terminal methods refuse the same way.
}
```

### What a conforming type must guarantee

**Safe to call concurrently.** An agent may ask for a permission decision while updates are still
streaming, and may run several terminal calls at once.

**`sessionUpdate` cannot fail usefully.** It is a notification: it has no reply, so throwing from it
reaches nobody and does not stop the stream. Handle rendering failures yourself.

**A permission request holds the turn open.** The agent blocks until the user answers. A host that
shows a dialog and never resolves it stalls the turn; cancelling is the way out.

## Topics

### Role Contract

- ``ACPClient``
