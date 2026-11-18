# Deployment architecture

This document describes the approved target architecture for the coordinated `0.4.0` release and the checks needed before deployment. The topology and recovery behavior below are architectural requirements, not a claim that the release has been deployed or that every path has passed operational verification.

## Components and state

The coordinated 0.4.0 topology has seven application services: web, API, MCP, analysis, release, knowledge, and notifications. The broker and data services are supporting infrastructure.

| Component | Role | State | Required protection |
| --- | --- | --- | --- |
| `nexora-web` | Human-facing React application | Build artifacts and browser session | HTTPS, secure headers, API origin policy |
| `nexora-api` | Authenticated domain API and durable job creation | Configuration and runtime state | Authentication, authorization, rate and process limits |
| `nexora-mcp` | Remote MCP protocol and API client | MCP client keys and service configuration | API authorization remains authoritative |
| PostgreSQL + pgvector | Durable authority for platform and runtime data | Persistent | Backups, encryption, restricted network, migrations |
| RabbitMQ | Worker wake-up transport | Broker queues | Private network, durable queues, confirms, bounded consumers |
| Dragonfly-compatible cache | Reusable analysis fragments and query cache | Disposable/recoverable | Private network, memory limit, authenticated access |
| Neo4j | Relationship and graph traversal projection | Persistent projection | Backups/rebuild plan, restricted network, authenticated access |
| `nexora-analysis-worker` | Repository checkout and complete language-analysis pipeline | Analysis job state | Git credential isolation, idempotency, bounded CPU and memory |
| `nexora-release-worker` | Release composition and Git publication; resumes a task transition after its asynchronous knowledge work completes | Transition and release job state in PostgreSQL | Git credential isolation, idempotency, bounded concurrency |
| `nexora-knowledge-worker` | Knowledge synthesis, embeddings, daily analysis, AI task reviews, and contributor ratings | Knowledge job state | Provider isolation, idempotency, bounded concurrency |
| `nexora-notification-worker` | External email and notification delivery | Delivery job state | Provider isolation, deduplication, bounded retries |

PostgreSQL is the source of truth for domain state and durable jobs. The API records work there and publishes a wake-up through RabbitMQ. RabbitMQ is a dispatch signal, not the canonical job store. Workers recover eligible durable jobs at startup, including work left pending while a worker or broker was unavailable. Each job type needs its own claim, retry, idempotency, and completion rules; those details must be verified against the implementation before deployment. For AI task reviews and contributor ratings, the knowledge worker processes the durable job and the release worker resumes the waiting task transition after completion. Shared libraries are maintained in separate repositories and are not additional runtime services. No implementation or production cutover is certified by this architecture document. Neo4j and vector structures are projections or retrieval indexes. Dragonfly is an optimization. Losing the cache should cause re-analysis, not loss of the canonical snapshot.

## RabbitMQ requirements

The [Docker Compose overlay](../deployment/compose/README.md) includes RabbitMQ. Configure the broker user, password, and virtual host consistently with the URI used by the API and workers. For [Kubernetes](../deployment/kubernetes/README.md), provision a private RabbitMQ service and supply its URL through the runtime Secret. The API and all four workers need network access to that broker.

## VPS topology

```text
Internet
  |
  +--> Caddy/Nginx/Traefik (HTTPS, security headers, /api routing)
          |
          +--> Nexora Web static assets
          +--> Nexora API (/api)
          +--> Nexora MCP (/mcp) --> Nexora API

Private application network
  Nexora API --> PostgreSQL/pgvector, RabbitMQ, Dragonfly, Neo4j
  Analysis, release, knowledge, and notification workers --> PostgreSQL and RabbitMQ
```

The firewall should expose only ports 80/443 as required by the reverse proxy. SSH should be restricted to administrative access. Keep RabbitMQ, PostgreSQL, Neo4j HTTP/Bolt, and Dragonfly on private interfaces.

### VPS minimum starting point

For development or a small team, start planning around 4 vCPUs, 8 GiB RAM, and 80 GiB of SSD. For a production-like single-host installation, 4–8 vCPUs, 16 GiB RAM, and at least 160 GiB of SSD is a more realistic starting point when all services share the host. These figures are operational recommendations, not capacity benchmarks or guarantees.

The final size depends on repository size, simultaneous indexing jobs, graph size and query depth, document volume, embedding workload, snapshot and backup retention, worker concurrency, and number of users and MCP clients.

## Kubernetes topology

```text
Ingress / Gateway API
        |
        +--> web Deployment or static object hosting
        +--> api Deployment (2+ replicas when HA is required)
        +--> mcp Deployment --> api Service

Private workloads
  analysis-worker, release-worker, knowledge-worker, notification-worker
  api and the four workers --> PostgreSQL and operator-supplied RabbitMQ
  Dragonfly, Neo4j, and secret management provided by the operator
```

### Kubernetes resource starting point

The local Compose stack documents development memory values of approximately 256 MiB for PostgreSQL, 384 MiB for Dragonfly, and 768 MiB for Neo4j, plus CPU allocations. Those values are not enough to size a production cluster.

For an initial non-production cluster, operators can begin with explicit requests and limits rather than leaving stateful workloads unbounded. A reasonable first experiment is to reserve at least 2–4 vCPUs and 6–8 GiB of allocatable memory for the Nexora namespace, plus Kubernetes/system overhead, then measure real indexing and query workloads. Production HA requires additional capacity for replicas, failover, rolling upgrades, and database maintenance.

Do not copy these values into a production manifest without measuring. The source repository does not currently certify a Kubernetes capacity profile.

## Storage and backup requirements

At minimum:

- PostgreSQL must have durable storage and scheduled backups.
- Neo4j must have durable storage and a documented rebuild or backup procedure.
- Dragonfly may be recreated, but its loss must not invalidate snapshots.
- Uploaded knowledge files and generated exports need an explicit storage policy.
- Backups must be encrypted, access-controlled, retained according to the installation policy, and periodically restored in a test environment.
- Snapshot retention must be defined separately from cache TTL.

A successful backup job is not enough. Recovery must verify database connectivity, migrations, current snapshot selection, graph projection integrity, API authorization, and web/API routing.

## Secrets and identity

Secrets belong in Vault, a cloud secret manager, Kubernetes Secrets protected by an external manager, or an equivalent controlled mechanism. They must not be stored in Git, frontend bundles, Docker images, profile repositories, or MCP instructions.

Production installations need API signing and session secrets, database and cache credentials, Neo4j credentials, provider OAuth credentials and webhook secrets, encryption/master-key material where configured, and TLS certificates or certificate automation.

Rotate credentials through the service-specific procedure. Replacing a secret file does not automatically rotate a password already stored in a persistent database.

## Network and TLS

Terminate TLS at the reverse proxy or ingress. Enforce HTTPS, secure cookies, origin validation, and appropriate security headers. Keep service-to-service traffic on private networks and use TLS for internal links when the deployment threat model requires it.

The local Compose configuration binds development ports to loopback. A VPS or Kubernetes installation must preserve the same principle at the network level: public access goes through the authenticated web/API boundary, not directly to the data services.

## Release and migration sequence

An operational release should follow this order:

1. back up the durable stores;
2. verify compatible versions for the seven application services and their separately maintained language-analysis profiles;
3. run migrations as an explicit controlled step;
4. confirm RabbitMQ connectivity, then deploy the API, MCP gateway, and workers;
5. verify health, authentication, and configuration, then complete and verify one job lifecycle for each of the four workers. Verify that startup recovers pending work after worker and broker restarts. Verify that a knowledge-worker review or rating completion wakes release-worker and resumes the corresponding transition before retiring any compatibility service;
6. deploy the web assets and verify `/api` routing;
7. index or recover a synthetic repository;
8. verify snapshot publication and graph projection;
9. verify an authorized web and MCP query;
10. record the actual revision, checks, and deployment evidence.

A container rollout, a green build, or a successful migration alone does not prove that Nexora has been delivered successfully.

## Kubernetes deployment artifacts

The reviewed base manifests are maintained in [`deployment/kubernetes/base`](../deployment/kubernetes/base) in this documentation repository. They describe seven application Deployments, ClusterIP Services for web, API, and MCP, health probes, non-root security contexts, and resource starting points. They intentionally do not contain production secrets, persistent-volume choices, ingress hosts, registry credentials, or CD automation.

The coordinated component set targets version `0.4.0`. The Kubernetes base describes API, web, MCP gateway, and four independent worker workloads. The artifacts do not establish image availability or readiness. Operators must verify compatible versioned images and provide credentials, network controls, persistent storage, ingress, and environment sizing through private overlays before deployment.

## Deployment verification status

The `0.4.0` architecture and deployment inputs are in preparation. This repository does not certify a target-cluster deployment, image availability, migration execution, worker recovery, or successful end-to-end job processing. Treat deployment examples as preparation material until each service and recovery path has been verified in an isolated environment and then against the intended deployment configuration.

## Publication boundary

The deployment artifacts describe the target topology only. Verify each job claim and retry rule, startup recovery after worker and broker restarts, message acknowledgements, transition resumption, and each worker's end-to-end lifecycle before a cutover. The public source does not certify a universal production sizing profile, managed database service, or high-availability guarantee; those remain environment-specific operational concerns and require tested overlays and evidence.

## Official-image VPS deployment

Use the [Compose guide](../deployment/compose/README.md) as preparation material for a single-host deployment. Do not treat it as a verified cutover procedure until the listed image, migration, health, and recovery checks have been completed for the target environment.
