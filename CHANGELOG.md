# Changelog

## 0.4.0

- Begin the coordinated component split for the API, remote MCP endpoint, and four independently scalable worker responsibilities.
- Define PostgreSQL as the durable job authority and RabbitMQ as the worker wake-up transport.
- Prepare the deployment and compatibility documentation for the seven-repository 0.4.0 set; Kubernetes inputs remain pending until the standalone service images and commands are available.

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
