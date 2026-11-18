# Changelog

## 0.4.0

- Prepare the coordinated architecture for web, API, remote MCP, and four independent workers: analysis, release, knowledge, and notifications.
- Document PostgreSQL as the source of truth for domain state and durable jobs, with RabbitMQ carrying worker wake-up messages and workers recovering pending work at startup.
- Assign AI task reviews and contributor ratings to the knowledge worker, with the release worker resuming the task transition after completion.
- Record the shared-library boundary as separate repositories and document the deployment and recovery checks required before claiming release readiness.
- Release and deployment status: in preparation; this changelog does not assert that the target topology or its recovery paths have been deployed or verified.

## 0.2.1

- Add the official-image VPS deployment for API, worker and web, preserving existing databases, secrets and Cloudflare routing.
- Resolve release tags to immutable image digests and guard activation with runtime checks, backups and schema-aware recovery.

## 0.2.0

- Added versioned Kubernetes deployment inputs for the API and web applications.
- Added operator guidance for configuration, migrations, routing, storage, backups, health checks, and rollback.
- Documented SemVer image tags and provider-neutral deployment configuration.
- Added manifest rendering and schema validation for the Kubernetes base resources.

## 0.1.0

- Initial public documentation hub for the Nexora open-source ecosystem.
- Defined independent repositories for the API, web client, skills, and analysis profiles.
