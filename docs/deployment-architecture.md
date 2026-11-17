# Deployment architecture

This document describes the infrastructure required to operate Nexora beyond offline analysis. Nexora has already been exercised successfully in a real self-hosted deployment. The document separates that operational validation from deployment recommendations and scale-out work that still require environment-specific verification.

The current operational validation uses a continuous working group of 10 developers. Kubernetes scale testing is intentionally scheduled after the fixes discovered through task and workflow management have been completed.

## Components and state

| Component | Role | State | Required protection |
| --- | --- | --- | --- |
| `nexora-web` | Human-facing React application | Build artifacts and browser session | HTTPS, secure headers, API origin policy |
| `nexora-api` | API, engine boundary, MCP/platform services | Configuration and runtime state | Authentication, authorization, rate and process limits |
| PostgreSQL + pgvector | Durable authority for platform and runtime data | Persistent | Backups, encryption, restricted network, migrations |
| Dragonfly-compatible cache | Reusable analysis fragments and query cache | Disposable/recoverable | Private network, memory limit, authenticated access |
| Neo4j | Relationship and graph traversal projection | Persistent projection | Backups/rebuild plan, restricted network, authenticated access |
| Workers | Repository indexing, synthesis, provider and delivery jobs | Queue/job state | Idempotency, retries, observability, bounded concurrency |

PostgreSQL is the authoritative store. Neo4j and vector structures are projections or retrieval indexes. Dragonfly is an optimization. Losing the cache should cause re-analysis, not loss of the canonical snapshot.

## VPS topology

```text
Internet
  |
  +--> Caddy/Nginx/Traefik (HTTPS, security headers, /api routing)
          |
          +--> Nexora Web static assets
          +--> Nexora API
                    |
                    +--> PostgreSQL/pgvector on private loopback/network
                    +--> Dragonfly on private loopback/network
                    +--> Neo4j on private loopback/network
                    +--> worker processes with bounded concurrency
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
                    |
                    +--> worker Deployment
                    +--> PostgreSQL operator or managed PostgreSQL
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

The release version is SemVer. For the current `0.2.0` release, both runtime images and CI artifacts use the `0.2.0` tag/name. `latest` and commit-derived tags are not part of the release policy. Updating a release requires keeping the API, web, workflow artifacts, image tags, and Kustomize image mapping aligned.

The application repositories' CI pipelines compile or build each application once, upload the result as a `0.2.0` workflow artifact, and build the runtime image from that artifact in a dependent job. On pushes to `main`, CI publishes the versioned image to GHCR using the repository secret `NUGET_TOKEN`; pull requests do not publish images. CI never accesses the private server or applies Kubernetes resources. CD remains an operator responsibility.

## Current Kubernetes workstream

The team is currently working on the Kubernetes installation so Nexora can scale beyond a single VPS. The next implementation work is to apply the reviewed base artifacts through an operator-owned overlay, deploy them to the target cluster, exercise migrations and persistent volumes, and verify snapshot publication, graph projection, web/API routing, backups, and recovery under the real cluster configuration.

## Current publication boundary

Version `0.2.0` provides the application container build contracts, CI artifact flow, and reviewed Kubernetes base inputs described here. The platform behavior has already been validated in a real self-hosted deployment. The public source does not yet provide a universal production sizing profile, managed database service, or high-availability guarantee; those remain environment-specific operational concerns and require their own tested overlays and evidence.
