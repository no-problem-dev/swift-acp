# Architecture

How the package is layered, and exactly what "conformant" is checked to mean.

## Overview

ACP connects a host to an agent over JSON-RPC. Its core — prompt, watch updates stream back,
cancel — is domain-agnostic: a host observing and steering one agent's working session. The
file-system and terminal methods are optional capabilities the host lends, so nothing about the
protocol assumes the agent writes code.

The package is split so a consumer takes only the layer it needs, and so each layer can be checked
against the specification independently.

## The five libraries

| Library | Role | Depends on |
|---|---|---|
| `ACPJSONRPC` | The JSON-RPC 2.0 envelope — `RequestId`, `RPCError`, `ErrorCode`, `JSONValue` — with no knowledge of ACP | — |
| ``ACPCore`` | The 135 v1 `$defs` as Codable value types: sum-typed unions, open string enumerations, `unknown` cases for forward compatibility | `ACPJSONRPC` |
| `ACPAgent` | The agent role contract | ``ACPCore`` |
| `ACPClient` | The client role contract | ``ACPCore`` |
| `ACPTransport` | `InProcessConnection` (typed, nothing serialized), `StdioTransport` and `AgentConnection` (JSON-RPC), `StreamingSessionClient` | all of the above |

``ACPCore`` re-exports `ACPJSONRPC`, so `import ACPCore` brings the envelope types along and one
import is normally enough.

The transport is deliberately the swappable part. An agent and a host are written against the role
contracts alone; in-process the messages cross as Swift values with nothing encoded, and over stdio
the same calls become JSON-RPC frames.

## What conformance is checked to mean

The specification is vendored, version-pinned, under `Tests/ACPConformanceTests/Spec/v1` — the
schema crate at 0.13.6, protocol v1. Three independent checks run against it, and each states its
own limit.

**Schema coverage.** Every one of the 135 `$defs` entries maps to exactly one modelled type, and no
modelled type claims a name the schema does not define. This proves the surface is complete. It
proves nothing about field-level fidelity: a type could satisfy it while encoding its fields wrongly.

**Golden round-trip.** Thirty wire samples, harvested verbatim from the reference crate's own test
assertions, are decoded into their modelled type and re-encoded, and the JSON is compared. This is
what proves field-level fidelity.

Three of the thirty are skipped: the two `JsonRpcMessage` samples and the one `JsonRpcBatch`
sample name envelope wrappers that are not `$defs` types and have no modelled counterpart, so they
are not exercised by any test. Twenty-seven samples are actually round-tripped.

**Method parity.** The method-name tables in ``ACPMethod`` are compared against `meta.json` and must
be equal — no missing, extra or misspelled method.

## What the checks do not cover

The suite proves that types match the schema. It does not prove that a connection behaves correctly,
and two behavioural details are worth knowing.

`AgentConnection` reads frames in order but dispatches each on its own task, so handling may
complete out of order. `InProcessConnection` has no such gap, which means an ordering bug is
reproducible only over a transport.

The in-process path never encodes anything, so it cannot catch a serialization failure. A test suite
that only exercises it says nothing about interoperability.
