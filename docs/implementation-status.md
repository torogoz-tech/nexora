# Implementation status

This table prevents the public documentation from promising more than the source currently provides.

| Area | Status | Meaning |
| --- | --- | --- |
| Declarative profile loading and validation | Implemented | YAML profiles are parsed, validated, and tested by the Rust engine. |
| Lexing, syntax projection, symbols, and graph evidence | Implemented for documented subsets | The supported subset is profile- and fixture-specific. |
| Offline CLI analysis | Implemented | `analyze`, language validation, corpus, policy, graph, and snapshot commands are available in the engine boundary. |
| Incremental file reuse | Implemented and benchmarked | Reuse is content/configuration aware and workload dependent. |
| Durable snapshots | Implemented in the runtime path | PostgreSQL is authoritative and projections are verified before publication. |
| Dragonfly reuse cache | Implemented in the runtime path | Cache loss is recoverable through re-analysis. |
| Neo4j graph traversal | Implemented in the runtime path | Graph data is a projection of published snapshot facts. |
| Deterministic governance | Implemented for documented contracts | `PASS`, `FAIL`, `UNKNOWN`, findings, evidence, and bounded evaluation are available. |
| Local MCP code context | Implemented | The local stdio server exposes bounded read tools and optional indexing/knowledge operations. |
| Knowledge retrieval and review | Implemented in platform paths | Documents, contributions, revisions, evidence, and review state are separate from code facts. |
| Web platform | Implemented across documented feature areas | The web application covers platform workflows; deployment and integration readiness remain environment-specific. |
| English and Spanish interface | Implemented in the web product boundary | Presentation is localized while technical identifiers and authorization rules remain stable. |
| Real self-hosted operation | Validated | The platform behavior has been exercised successfully in a real self-hosted deployment; private deployment identity and infrastructure details are intentionally excluded. |
| GitHub repository integration | Checked in current verification work | Connection, repository scope, and provider workflow evidence are available for the verified environment. |
| GitLab repository integration | Implemented path; live verification pending | Review and provider verification are planned for this week; do not treat fixtures as production proof. |
| Azure DevOps connector | Roadmap | Azure DevOps is one of the team's principal repository systems and is planned as a first-class connector; current source inspection does not show an implemented Azure DevOps adapter. |
| Complete language semantics | Not claimed | Bodies, types, nested scopes, calls, and language-specific semantics remain incomplete or profile-specific. |
| Distributed authorization for every local engine contract | Not claimed | Local/offline and remote/platform boundaries must not be conflated. |
| Universal benchmark superiority | Not claimed | Existing results are bounded baselines. |

## Active infrastructure work

### Coordinated service extraction 0.4.0

The target boundary contains seven services: web, API, MCP, and four workers for analysis, release, knowledge, and external notifications. The API has a versioned RabbitMQ wake-up contract and publisher plus database recovery discovery. Local standalone repositories now exist for analysis, release, and notification workers; each has a focused executable, queue recovery, version 0.4.0 metadata, and container packaging. Their dependencies are pinned to the local API 0.4.0 revision, so that API commit must be published before these repositories can build remotely. The API still contains duplicate worker commands and code, and these repositories do not yet have remote projects or Kubernetes workloads. Knowledge/rating processing still starts inside the API process, and the MCP HTTP endpoint also remains there. The MCP and knowledge worker repositories, API cutovers, and complete service-level Kubernetes manifests are pending. Do not interpret this progress as completion of the 0.4.0 extraction.

The current infrastructure workstream is the Kubernetes installation for Nexora scale-out. The objective is to move from the verified local Compose topology and single-host deployment guidance toward a repeatable Kubernetes deployment with:

- API and worker deployments;
- web delivery behind an ingress;
- persistent PostgreSQL/pgvector and Neo4j storage;
- Dragonfly cache operation and recovery behavior;
- externalized secrets;
- TLS and network policies;
- migrations as controlled release steps;
- monitoring, backups, restore tests, and failure recovery;
- measured resource requests and limits.

This work is active and must be verified in the target cluster before the scale-out installation is described as production-ready. The existing platform behavior is already validated in real operation; the public repository contains the architecture and requirements, not a universal Kubernetes manifest set or a capacity guarantee.

The current validation cohort is a continuous group of 10 developers. Fixes discovered through their task and workflow use will be completed before Kubernetes scale testing begins.
