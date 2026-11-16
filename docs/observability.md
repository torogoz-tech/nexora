# Observability

Nexora needs observability across the browser, API, workers, databases, provider integrations, and analysis pipeline. A process being alive is not proof that a snapshot was published or a release was delivered.

## Minimum signals

### API and web

- request count, latency, and error rate;
- authentication and authorization denials;
- callback failures;
- rate limiting;
- API-to-web routing failures;
- session and token errors.

### Analysis and jobs

- queued, running, completed, failed, cancelled, and expired jobs;
- lease age and heartbeat freshness;
- files analyzed, reused, skipped, and rejected;
- snapshot publication latency;
- diagnostics and coverage by profile;
- cache hit/miss and eviction behavior;
- worker concurrency and memory pressure.

### Data services

- PostgreSQL connections, locks, query latency, migration state, disk, and backup age;
- Neo4j availability, projection checksum/count mismatches, transaction failures, and disk;
- Dragonfly memory, evictions, persistence checkpoint age, and authentication errors;
- vector index health and embedding job backlog.

### Git providers

- OAuth/App callback failures;
- webhook verification failures and duplicate deliveries;
- provider rate limits;
- branch and pull-request operation outcomes;
- stale provider intents requiring reconciliation;
- repository authorization and revocation events.

## Correlation

Logs and traces should carry installation, project, repository, snapshot, job, task, transition, request, provider, and correlation identifiers when available. Do not log tokens, private keys, source content beyond the configured evidence policy, or sensitive document bodies.

## Alerts

Useful first alerts include database unavailable, backup too old, disk near capacity, worker heartbeat missing, pending snapshot older than its operational threshold, repeated provider reconciliation, projection mismatch, cache memory exhaustion, and migration failure.

The public `0.1.0` repository documents these signals but does not claim a universal production dashboard or SLO set. Operators must define thresholds from their workload and recovery objectives.
