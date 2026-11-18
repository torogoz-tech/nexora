# Docker Compose deployment

The `0.4.0` Compose files are deployment preparation inputs for the approved seven-service application topology. They are not a verified deployment or stand-alone installation recipe. Before using them, inspect the actual Compose configuration and confirm that all referenced images, settings, host paths, networks, and volumes match the target host. Preserve existing data and secrets unless a separately reviewed migration plan says otherwise.

The intended configuration combines `compose.yaml` and `compose-0.4.0.yaml`. The application topology is web, API, MCP gateway, and four independent workers: analysis, release, knowledge, and notifications. PostgreSQL is the source of truth for domain state and durable jobs; RabbitMQ carries worker wake-up messages. Workers must recover eligible pending work on startup. The knowledge worker processes AI reviews and contributor ratings, then release worker resumes the associated task transition. Confirm that the current Compose files and images implement this contract before activation; this guide does not certify that they do.

Before any cutover, verify all four worker lifecycles in an isolated environment. Confirm that pending jobs are recovered after worker restart and after RabbitMQ restart; verify message acknowledgement only after durable job state is safely handled. Exercise analysis, notification delivery, knowledge review/rating, and release composition. For the knowledge-to-release handoff, correlate the durable job and transition state with logs from both workers, then restart each worker while work is pending and repeat. Do not remove or disable an existing compatibility service until evidence shows that the new release worker owns and completes the relevant transition and composition work.

The example Compose configuration uses host ports for the API, MCP, web, and RabbitMQ. Verify actual bind addresses and reverse-proxy routing before use; do not expose RabbitMQ or data services publicly. Any existing Nginx, tunnel, or data-service configuration is outside this guide's verified scope and should not be changed as part of applying these preparation inputs.

## Prepare the host

Install `compose.yaml`, `compose-0.4.0.yaml`, `web-nginx.conf`, and the deployment scripts under `/opt/nexora/deploy/app`. Keep `/etc/nexora`, `/var/lib/nexora`, `/opt/nexora/deploy/data`, and the existing database volumes intact.

Copy `images.env.example` to `.env`, set file permissions to `0600`, then replace all sample image references with the approved registry and published `0.4.0` images. Set the numeric runtime UID/GID. Configure the RabbitMQ URI and its user, password, and virtual host consistently. Do not commit `.env`, credentials, private keys, or worker settings.

Provide the following operator-managed files outside the image:

- `/etc/nexora/connections.json` for the API.
- `/etc/nexora/worker-connections.json` for workers.
- `/etc/nexora/worker-secrets/` for provider credentials.
- `/etc/nexora/git-policy.json` and `/etc/nexora/analysis-worker.json`.
- `/etc/nexora/release-worker.json` and `/etc/nexora/reasoning.json`.
- `/var/lib/nexora/workspaces/analysis` and `/var/lib/nexora/workspaces/release` with ownership and permissions that allow the container UID `10001` to write.

The current PostgreSQL connector does not configure TLS. Keep the database endpoint on the trusted host/private network and retain its explicit host validation settings.

## Prepare a 0.4.0 deployment

Do not stop or migrate an existing installation based only on this guide. First verify that the exact Compose configuration is valid, every referenced image is available and compatible, and the database, configuration files, and encryption keys have recoverable backups. Preserve the current deployment configuration and image digests for rollback. Test migrations and recovery on a disposable database before applying them to a target environment.

Validate and pull the exact deployment configuration:

```bash
cd /opt/nexora/deploy/app
docker compose --env-file .env -f compose.yaml -f compose-0.4.0.yaml config --quiet
docker compose --env-file .env -f compose.yaml -f compose-0.4.0.yaml pull
```

Only after those checks and an approved environment-specific change plan, stop application writers before applying database migrations. Run the API's versioned migration command once, then start the services and wait for their health checks:

```bash
docker compose --env-file .env -f compose.yaml -f compose-0.4.0.yaml stop api worker analysis-worker release-worker knowledge-worker notification-worker
docker compose --env-file .env -f compose.yaml -f compose-0.4.0.yaml run --rm --no-deps api --connections /etc/nexora/connections.json --schema nexora_platform migrate
docker compose --env-file .env -f compose.yaml -f compose-0.4.0.yaml up -d --wait --wait-timeout 180
```

Verify API readiness, web and MCP health, RabbitMQ health, and a successful job lifecycle for each worker, including startup recovery and the knowledge-to-release transition handoff. Confirm browser access through the environment's configured reverse proxy before retiring any compatibility service. Record evidence and actual deployed revisions; the Compose files alone do not establish a successful deployment.

## Recovery

Keep the prior `.env`, image digests, database backup, configuration, and encryption keys until the new deployment and job lifecycles are verified. If a migration changed the schema, do not blindly run older binaries; restore only with the matching database and private configuration backup. Never run `docker compose down -v`, remove volumes, or regenerate encryption keys during recovery.

For status and logs:

```bash
cd /opt/nexora/deploy/app
docker compose --env-file .env -f compose.yaml -f compose-0.4.0.yaml ps
docker compose --env-file .env -f compose.yaml -f compose-0.4.0.yaml logs --tail 100 api mcp rabbitmq analysis-worker release-worker knowledge-worker notification-worker
```

`update.sh` supports the earlier two-image API/web deployment. The versioned Compose files describe the seven-service `0.4.0` target topology; deployment readiness remains subject to the verification steps above.
