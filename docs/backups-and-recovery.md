# Backups and recovery

Nexora separates durable facts from disposable acceleration data.

## What must be backed up

- PostgreSQL databases and migration state;
- knowledge files and generated exports;
- installation configuration and encrypted secret references;
- any durable object storage used for attachments;
- Neo4j data when fast graph recovery is required.

Dragonfly cache data is recoverable and may be recreated. Losing it can increase analysis cost, but it must not remove the canonical snapshot or reviewed knowledge.

## Recovery order

1. Restore secret-management access and configuration.
2. Restore PostgreSQL and verify migrations.
3. Restore durable files and attachments.
4. Start the API and workers with writes controlled.
5. Restore or rebuild Neo4j projections from published snapshots.
6. Recreate Dragonfly and allow cache warming.
7. Verify current snapshot selection, checksums, authorization, and MCP/API queries.
8. Re-enable provider jobs and reconcile any intents that were in flight.

## RPO and RTO

Every installation must define:

- RPO: how much recent durable state may be lost;
- RTO: how long recovery may take;
- snapshot retention;
- document and attachment retention;
- provider webhook replay strategy;
- maximum acceptable cache warm-up time.

The local Compose verification proves persistence across container recreation for synthetic data. It does not prove production backup recovery, zero data loss, or high availability.

## Restore testing

A backup is not verified until it has been restored into an isolated environment. The restore test should perform a repository query, graph traversal, knowledge retrieval, task/document read, authenticated web/API request, and a synthetic publication check. Record the actual revision, data age, duration, failures, and follow-up actions.
