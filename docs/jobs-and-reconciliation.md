# Jobs and reconciliation

Nexora performs repository synchronization, analysis, knowledge synthesis, provider operations, and release work through bounded jobs or workflow transition runs.

## Job lifecycle

```text
request
  -> queued
  -> leased by a worker
  -> heartbeat and progress
  -> completed, failed, cancelled, or expired
  -> reconciled and reported
```

Jobs carry scope, source identity, revision, attempt, and idempotency information. A worker lease is not ownership of the final result. The result must still pass the domain's publication and authorization checks.

## Retry rules

Safe retries reuse the same request identity and compatible parameters. A retry must not create a second branch, pull request, approval, publication, or notification merely because the first response was lost.

Provider operations distinguish:

- confirmed success;
- confirmed rejection;
- transient unavailability;
- authorization failure;
- an unknown outcome that requires provider reconciliation.

An unknown outcome is not treated as failure that can be blindly repeated and is not treated as success. Nexora reads the provider state and continues from the observed result.

## Snapshot publication

Repository analysis can stage a snapshot, project graph data, verify checksums and counts, and then activate the published snapshot. A prepared or pending artifact is not automatically current. PostgreSQL remains authoritative for publication state.

## Operational checks

Operators should monitor queue depth, lease age, heartbeat freshness, retry count, failed transitions, pending snapshots, projection mismatches, provider intents, and jobs that require human reconciliation.
