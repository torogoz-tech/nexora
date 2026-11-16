# Repository Catalog

All repositories are independent Git projects. They share the Nexora product name but do not share a Git history.

## Core repositories

| Repository | Responsibility | Initial version |
|---|---|---|
| `nexora-api` | Server, engine, CLI, MCP, persistence, governance, and infrastructure | `0.1.0` |
| `nexora-web` | Browser application and user interface | `0.1.0` |
| `nexora-skill` | Agent skills and authoring guidance | `0.1.0` |

## Analysis profile repositories

Each profile is maintained and released independently:

`javascript`, `typescript`, `tsx`, `jsx`, `html`, `css`, `lua`, `csharp`, `csharp-views`, `razor`, `razor-views`, `dart-flutter`, `java`, `kotlin`, and `swift`.

## Dependency direction

Profiles provide declarative language packages to the API and engine. The web client consumes the API. Skills describe how agents use the platform. Documentation describes the ecosystem but is not a runtime dependency.
