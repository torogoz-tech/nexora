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

The coordinated 0.4.0 boundary contains seven services: web, API, MCP gateway, and four workers for analysis, release, knowledge, and external notifications. The API creates durable work records and publishes RabbitMQ wake-ups; workers recover eligible jobs from PostgreSQL at startup and broker reconnect, then claim work using database leases. The four worker executables and their tests live in independent repositories. API worker commands and embedded worker runtimes have been removed. A standalone MCP transport gateway forwards authenticated requests to the private API; MCP authorization, tool catalog, and execution remain API responsibilities. Docker Compose and Kubernetes inputs cover the seven services. The deployment overlay, credentials, network policy, and sizing remain operator-managed. Release-worker source integration is under review; the production test host does not yet run that service.

The Compose and Kubernetes definitions for the seven-service topology are now present. The remaining cluster work is to validate the Kubernetes base with the operator's private overlay and target cluster, including:

- API and worker deployments;
- web delivery behind an ingress;
- persistent PostgreSQL/pgvector and Neo4j storage;
- Dragonfly cache operation and recovery behavior;
- externalized secrets;
- TLS and network policies;
- migrations as controlled release steps;
- monitoring, backups, restore tests, and failure recovery;
- measured resource requests and limits.

The manifests are deployment inputs, not evidence of a cluster rollout. The target-cluster apply, storage and network policy validation, recovery drills, and measured capacity work remain outstanding before describing the Kubernetes installation as production-ready.

The continuous developer validation cohort and its feedback loop remain active alongside infrastructure validation.
