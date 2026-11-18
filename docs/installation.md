# Installation and deployment map

Nexora can be used at several levels. The required infrastructure depends on whether the goal is local analysis, a single self-hosted installation, or a multi-service Kubernetes deployment.

## Local analysis only

Use `nexora-api` with the stable Rust toolchain and one or more profile repositories. The CLI can analyze files and run profile or corpus validation without PostgreSQL, Dragonfly, Neo4j, Kubernetes, or an external AI service.

## Local persistent development

The API repository provides `infra/local/compose.yaml` for a development stack containing PostgreSQL with pgvector, Dragonfly, and Neo4j Community. It uses private generated secrets, named volumes, health checks, and an explicit verification script. Its resource values are intended for a Docker VM with approximately 4 GiB of memory; they are not production sizing.

## VPS self-hosting

For a small self-hosted installation, use the [0.4.0 Compose overlay](../deployment/compose/README.md). It includes RabbitMQ alongside the seven application services and uses a separate data-service project. Run them on one VPS only when the workload and recovery objectives support that arrangement. A starting point is:

| Resource | Development/small team starting point | Production planning note |
| --- | ---: | --- |
| CPU | 4 logical vCPUs | Increase for concurrent indexing and workers. |
| RAM | 8 GiB | 16 GiB is a safer starting point when all stateful services share the host. |
| SSD | 80 GiB free | Size from snapshot history, knowledge files, graph data, logs, and backup retention. |
| OS | Current supported Linux distribution | Apply security updates and time synchronization. |
| Network | Reverse proxy with HTTPS | Expose web and the API/MCP routes through the proxy. Keep the broker and data services private. |

These are deployment starting points, not measured capacity guarantees. The authoritative sizing work still requires representative repositories, concurrent users, indexing frequency, knowledge volume, and retention policy.

## Kubernetes

The [Kubernetes base](../deployment/kubernetes/README.md) defines all seven 0.4.0 application workloads: web, API, the MCP gateway, and the analysis, release, knowledge, and notification workers. Operators supply RabbitMQ, PostgreSQL/pgvector, Dragonfly, Neo4j, and environment-specific configuration. The API stores durable jobs in PostgreSQL and sends wake-up messages through RabbitMQ. Workers claim eligible jobs from PostgreSQL.

Minimum architectural requirements for Kubernetes are:

- persistent volumes for PostgreSQL and Neo4j;
- a deliberate retention and backup policy;
- separate Kubernetes Secrets or an external secret manager;
- NetworkPolicies that keep RabbitMQ and data services private;
- TLS at the ingress or service mesh boundary;
- readiness and liveness checks that do not confuse process health with snapshot publication;
- migration execution controlled as a release step;
- resource requests and limits for API, workers, PostgreSQL, Dragonfly, and Neo4j;
- monitoring for disk, memory, cache evictions, failed publications, queue depth, and database health;
- a recovery test for PostgreSQL, graph projection, and application configuration.

Do not run PostgreSQL or Neo4j on ephemeral storage. Do not expose Neo4j Browser, Bolt, PostgreSQL, Dragonfly, or RabbitMQ directly to the public internet. Do not treat a Kubernetes rollout as a successful Nexora release until the API health, migrations, current snapshot publication, graph projection, and web/API path have been verified.

See [deployment architecture](deployment-architecture.md) for the complete topology and operational checklist.

## Agent integration

Install `nexora-skill` in the supported agent environment and configure access to an authorized Nexora API or MCP endpoint. Skills do not contain credentials.
