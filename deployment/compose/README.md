# Official images on the existing Nexora VPS

This installation uses the official GHCR API and web images. API and worker are separate containers using the same API image; no additional worker repository or Rust compilation is needed on the host. The API image must include Git and its HTTPS transport (API 0.2.1 or later).

The existing PostgreSQL/pgvector, Dragonfly and Neo4j Compose project and persistent volumes remain unchanged. Host networking for API/worker is intentional: Nexora currently accepts only loopback database hosts in connections.json. The API binds to 127.0.0.1:18081, not a public interface. The web container binds to 127.0.0.1:18082; the existing host Nginx on 18080 routes browser API/MCP traffic and proxies static content. Cloudflare Tunnel is not changed.

## Release flow

1. Correct and commit on develop, push, and open a PR to main.
2. CI validates the code and the assembled API image, including startup without linker warnings, non-root execution, writable working directory, Git and its HTTPS transport.
3. After authorized merge to main, CI publishes the component's SemVer image to GHCR. The web keeps its independently published version when unchanged.
4. On the server, run the update command only after both requested image versions are published. It pulls official images, validates the API runtime, resolves immutable digests, stops application writers, backs up PostgreSQL/configuration/encryption keys after stopping application writers, runs migrations, starts the containers and checks local readiness. It does not rebuild images, transfer executable archives, recreate databases or delete volumes.
5. Verify public HTTPS, CORS, authenticated browser API, MCP authorization, synchronization, and the browser console before declaring publication complete. The local update checks do not replace these public acceptance checks.

## Initial installation on the existing host

Install compose.yaml, web-nginx.conf and executable update.sh together under /opt/nexora/deploy/app as root-owned files. Preserve /etc/nexora, /var/lib/nexora, /opt/nexora/deploy/data and the existing native releases for rollback. Docker Compose must already be installed. The registry packages must be public or the operator must independently configure read-only registry access; no registry token belongs in source or the images.

Run on the server:

```bash
sudo /opt/nexora/deploy/app/update.sh 0.2.1 0.2.0
```

The first successful activation disables the old native API/worker systemd units. Nginx, Cloudflare Tunnel and the existing data service remain in place. Docker's unless-stopped policy restarts the application containers after a host restart. Existing secrets/configuration are mounted at their original paths, and API/worker use the numeric UID/GID of the existing nexora runtime account. Neither credentials nor private SSH keys are placed in the Compose file, source or images.

The update writes /opt/nexora/deploy/app/.env containing image digests and numeric runtime identity only, with private permissions. It serializes updates using a lock and stores backups/receipts under /var/backups/nexora/images-*. Image validation or registry failure occurs before interrupting the active application.

## Failure and recovery

A failed activation attempts to restore the previous proxy and application only if the database migration version is unchanged. A failed first transition restores the native services and removes the candidate image configuration; a container-to-container update restores the previous image configuration. CI exercises both paths in disposable containers with mocked service/database commands and no host or network access. If a migration changed the schema, it stops and reports the matching backup instead of blindly running older binaries. A database restore also requires its matching private encryption keys/configuration. Do not use compose down -v, delete volumes or regenerate keys during recovery. Backups, old native releases and previous image digests must be retained until recovery has been verified.

For logs and status:

```bash
cd /opt/nexora/deploy/app
sudo docker compose ps
sudo docker compose logs --tail 100 api worker web
```

images.env.example documents the variables; do not copy its sample numeric identity over a real installation. update.sh reads the existing runtime account and resolves the requested official tags automatically.
