# Nexora Open Source

Nexora is an open-source code intelligence and governance platform. It combines a deterministic analysis engine, declarative language profiles, an API/MCP platform, a web client, and agent skills.

This repository is the documentation hub for the Nexora ecosystem. It contains no runtime source code. The implementation is maintained in separate repositories so each component can evolve independently.

## Components

- `nexora-api` — Rust server, analysis engine, CLI, MCP, storage, governance, and infrastructure.
- `nexora-web` — React and TypeScript web application.
- `nexora-skill` — Skills and guidance for Nexora-aware agents.
- `nexora-profile-*` — One independent repository per analysis profile.

Every public component starts at version `0.1.0`. See [the repository catalog](docs/repository-catalog.md) for the complete list.

## Open-source status

The first public release is an early, self-hostable release. Capabilities are documented honestly; unsupported syntax, incomplete semantic coverage, and provider-dependent integrations are reported as limitations instead of being presented as complete understanding.

## Documentation

- [Repository catalog](docs/repository-catalog.md)
- [Architecture](docs/architecture.md)
- [Installation map](docs/installation.md)
- [Versioning and release policy](docs/versioning.md)
- [Contribution guide](../nexora-api/CONTRIBUTING.md)
- [Security policy](../nexora-api/SECURITY.md)

## License

Nexora is released under the MIT License. Each source repository contains its own license file.
