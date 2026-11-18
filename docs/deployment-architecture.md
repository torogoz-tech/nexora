# Deployment architecture

This document describes the infrastructure required to operate Nexora beyond offline analysis. Nexora has already been exercised successfully in a real self-hosted deployment. The document separates that operational validation from deployment recommendations and scale-out work that still require environment-specific verification.

The current operational validation uses a continuous working group of 10 developers. Kubernetes scale testing is intentionally scheduled after the fixes discovered through task and workflow management have been completed.

## Components and state

| Component | Role | State | Required protection |
| --- | --- | --- | --- |
| `nexora-web` | Human-facing React application | Build artifacts and browser session | HTTPS, secure headers, API origin policy |
| `nexora-api` | Authenticated domain API and durable job creation | Configuration and runtime state | Authentication, authorization, rate and process limits |
| `nexora-mcp` | Remote MCP protocol and API client | MCP client keys and service configuration | API authorization remains authoritative |
| PostgreSQL + pgvector | Durable authority for platform and runtime data | Persistent | Backups, encryption, restricted network, migrations |
| RabbitMQ | Durable worker wake-up transport | Rebuildable from pending PostgreSQL jobs | Private network, durable queues, confirms, bounded consumers |
| Dragonfly-compatible cache | Reusable analysis fragments and query cache | Disposable/recoverable | Private network, memory limit, authenticated access |
| Neo4j | Relationship and graph traversal projection | Persistent projection | Backups/rebuild plan, restricted network, authenticated access |
| `nexora-analysis-worker` | Repository checkout and complete language-analysis pipeline | Analysis job state | Git credential isolation, idempotency, bounded CPU and memory |
| `nexora-release-worker` | Workflow transitions, release composition, and Git publication | Release job state | Git credential isolation, idempotency, bounded concurrency |
| `nexora-knowledge-worker` | Knowledge synthesis, embeddings, daily analysis, and ratings | Knowledge job state | Provider isolation, idempotency, bounded concurrency |
| `nexora-notification-worker` | External email and notification delivery | Delivery job state | Provider isolation, deduplication, bounded retries |

PostgreSQL is the authoritative store for jobs and domain state. RabbitMQ wakes workers; startup and broker-reconnect recovery must find eligible PostgreSQL work even when a wake-up was missed. Neo4j and vector structures are projections or retrieval indexes. Dragonfly is an optimization. Losing the cache should cause re-analysis, not loss of the canonical snapshot.

## VPS topology

```text
Internet
  |
  +--> Caddy/Nginx/Traefik (HTTPS, security headers, /api routing)
          |
          +--> Nexora Web static assets
          +--> Nexora API
          +--> Nexora MCP
                    |
                    +--> PostgreSQL/pgvector on private loopback/network
                    +--> Dragonfly on private loopback/network
                    +--> Neo4j on private loopback/network
          +--> Analysis, release, knowledge, and notification workers
                    +--> PostgreSQL and RabbitMQ on private loopback/network
```

The firewall should expose only ports 80/443 as required by the reverse proxy. SSH should be restricted to administrative access. Database ports, Neo4j HTTP/Bolt, and Dragonfly must not be public services.

### VPS minimum starting point

For development or a small team, start planning around 4 vCPUs, 8 GiB RAM, and 80 GiB of SSD. For a production-like single-host installation, 4–8 vCPUs, 16 GiB RAM, and at least 160 GiB of SSD is a more realistic starting point when all services share the host. These figures are operational recommendations, not capacity benchmarks or guarantees.

The final size depends on repository size, simultaneous indexing jobs, graph size and query depth, document volume, embedding workload, snapshot and backup retention, worker concurrency, and number of users and MCP clients.

## Kubernetes topology

```text
Ingress / Gateway API
        |
        +--> web Deployment or static object hosting
        +--> api Deployment (2+ replicas when HA is required)
        +--> mcp Deployment
        +--> analysis-worker Deployment (CPU/memory intensive)
        +--> release-worker Deployment
        +--> knowledge-worker Deployment (provider concurrency limits)
        +--> notification-worker Deployment
                    +--> PostgreSQL operator or managed PostgreSQL
                    +--> RabbitMQ cluster/operator
                    +--> Dragonfly StatefulSet or managed cache
                    +--> Neo4j operator/StatefulSet or managed graph service
                    +--> external secret manager
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
2. verify the exact API, web, and profile versions;
3. run migrations as an explicit controlled step;
4. deploy the API and workers;
5. verify health, authentication, and configuration;
6. deploy the web assets and verify `/api` routing;
7. index or recover a synthetic repository;
8. verify snapshot publication and graph projection;
9. verify an authorized web and MCP query;
10. record the actual revision, checks, and deployment evidence.

A container rollout, a green build, or a successful migration alone does not prove that Nexora has been delivered successfully.

## Kubernetes deployment artifacts

The reviewed base manifests are maintained in [`deployment/kubernetes/base`](../deployment/kubernetes/base) in this documentation repository. They describe the API and web Deployments and ClusterIP Services, health/readiness probes, non-root security contexts, resource starting points, and external configuration boundaries. They intentionally do not contain production secrets, persistent-volume choices, ingress hosts, registry credentials, or CD automation.

The coordinated component set is version `0.4.0`; its seven service images use that SemVer tag. `latest` and commit-derived tags are not part of the release policy. The Kubernetes base includes API, web, MCP gateway, and the four independent worker workloads. It supplies generic image names and example configuration; operators provide private credentials, network controls, persistent storage, ingress, and environment sizing through private overlays.

## Current Kubernetes workstream

The team is currently working on the Kubernetes installation so Nexora can scale beyond a single VPS. The next implementation work is to apply the reviewed base artifacts through an operator-owned overlay, deploy them to the target cluster, exercise migrations and persistent volumes, and verify snapshot publication, graph projection, web/API routing, backups, and recovery under the real cluster configuration.

## Current publication boundary

The 0.4.0 component boundary is prepared in local repositories. The MCP gateway separates transport while API authorization and tool execution remain in the API. The public source does not provide a universal production sizing profile, managed database service, or high-availability guarantee; those remain environment-specific operational concerns and require their own tested overlays and evidence.

## Official-image VPS deployment

The existing single-server installation can switch from native executables to containers without replacing the data services or Cloudflare Tunnel. The Compose guide describes container operation; use the 0.4.0 component topology when planning the cutover: API, MCP gateway, four workers, and web.
