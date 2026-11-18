# Docker Compose deployment

The `0.4.0` Compose files document a staged migration of the existing single-host installation. They are not a stand-alone installation recipe. They expect the existing data-service project, configuration, secrets, and volumes to remain in place.

Compose loads `compose.yaml` and `compose-0.4.0.yaml` together. The base file defines the API, web, and compatibility worker. The overlay adds MCP, RabbitMQ, and the four independent workers. It requires `NEXORA_LEGACY_API_IMAGE` for the compatibility worker until that service is retired. PostgreSQL holds durable job state, and RabbitMQ wakes the workers. The release worker is intended to own recovery of pending task transitions and release composition.

Before removing the compatibility worker, verify both release-worker functions in a controlled, isolated environment. Stop or exclude the legacy worker from that test, direct only the release worker to the isolated database schema and RabbitMQ queue, and create one eligible pending task transition and one queued release composition. Verify each run's database state transition and correlate it with the release worker's logs and consumed wake-up. Record the release worker identity and resulting run or release IDs as evidence. Repeat after a release-worker restart to verify startup recovery. A completion while the legacy worker is active does not establish which worker performed it. Retire the compatibility worker only after attributable evidence confirms both functions and startup recovery.

The API binds to `127.0.0.1:18081`, MCP to `127.0.0.1:18083`, web to `127.0.0.1:18082`, and RabbitMQ to `127.0.0.1:5672`. The host Nginx continues to serve port `18080`, route browser API and MCP traffic, and proxy static content. Cloudflare Tunnel and the data-service project are not changed by this application deployment.

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

## Activate version 0.4.0

Before stopping services, verify that every configured image is available and that the database, configuration files, and encryption keys have recoverable backups. Preserve the previous `.env` and image digests for rollback.

Validate and pull the exact deployment configuration:

```bash
cd /opt/nexora/deploy/app
docker compose --env-file .env -f compose.yaml -f compose-0.4.0.yaml config --quiet
docker compose --env-file .env -f compose.yaml -f compose-0.4.0.yaml pull
```

Stop application writers before applying database migrations. Run the API's versioned migration command once, then start the services and wait for their health checks:

```bash
docker compose --env-file .env -f compose.yaml -f compose-0.4.0.yaml stop api worker analysis-worker release-worker knowledge-worker notification-worker
docker compose --env-file .env -f compose.yaml -f compose-0.4.0.yaml run --rm --no-deps api --connections /etc/nexora/connections.json --schema nexora_platform migrate
docker compose --env-file .env -f compose.yaml -f compose-0.4.0.yaml up -d --wait --wait-timeout 180
```

Verify API readiness, web and MCP health, RabbitMQ health, and one successful job lifecycle for analysis, release, knowledge, and notifications. Confirm browser access through the existing Nginx and Cloudflare Tunnel before retiring any compatibility service.

## Recovery

Keep the prior `.env`, image digests, database backup, configuration, and encryption keys until the new deployment and job lifecycles are verified. If a migration changed the schema, do not blindly run older binaries; restore only with the matching database and private configuration backup. Never run `docker compose down -v`, remove volumes, or regenerate encryption keys during recovery.

For status and logs:

```bash
cd /opt/nexora/deploy/app
docker compose --env-file .env -f compose.yaml -f compose-0.4.0.yaml ps
docker compose --env-file .env -f compose.yaml -f compose-0.4.0.yaml logs --tail 100 api mcp rabbitmq analysis-worker release-worker knowledge-worker notification-worker
```

`update.sh` supports the earlier two-image API/web deployment. Use the versioned Compose overlay above for the seven-service `0.4.0` topology.
