# Storage rationale

Nexora uses different stores for different responsibilities. They are not interchangeable copies of the same truth.

## PostgreSQL: durable authority

PostgreSQL stores durable platform and runtime state: repositories, snapshots, publication state, metadata, documents, knowledge, permissions, tasks, workflows, and audit information. A snapshot is published through an explicit lifecycle so a partially projected result is not presented as current.

## Dragonfly: disposable reuse cache

Dragonfly speaks the Redis protocol and stores reusable per-file analysis fragments. Cache keys include tenant, repository, profile/configuration identity, engine version, path, and content identity. A cache miss or cache loss causes re-analysis; it does not remove the canonical snapshot.

## Neo4j: relationship projection

Neo4j supports graph traversal across nodes and edges. It is a projection optimized for relationship queries. The runtime checks publication and identity against the durable snapshot before treating a projection as queryable.

## Vector retrieval: knowledge discovery

Vector search helps retrieve reviewed knowledge and code-context chunks. Similarity improves discovery; it does not replace evidence or turn an unreviewed document into a source-of-truth fact.

## Why this separation matters

The separation gives Nexora three useful properties:

1. durable facts can be recovered without a warm cache;
2. relationship queries can be optimized independently from canonical storage;
3. semantic retrieval can remain a discovery layer instead of being confused with static-analysis truth.

The current local runtime is not a general distributed transaction across all stores. Publication, checksums, retries, and current-snapshot rules make partial failure visible and recoverable within the documented boundary.
