# Repository catalog

All public repositories are independent Git projects. They share a product family but do not share Git history.

## Product repositories

| Repository | Responsibility | Version |
| --- | --- | --- |
| `nexora` | Product, scientific, architecture, benchmark, and cross-repository documentation | `0.1.0` |
| `nexora-api` | Rust engine, CLI, server, persistence, governance, MCP, and platform API | `0.1.0` |
| `nexora-web` | React/TypeScript browser application and bilingual human interface | `0.1.0` |
| `nexora-skill` | Agent skills, workflow boundaries, and authoring guidance | `0.1.0` |

## Analysis profile repositories

Each profile is separately maintained and released:

`javascript`, `typescript`, `tsx`, `jsx`, `html`, `css`, `lua`, `csharp`, `csharp-views`, `razor`, `razor-views`, `dart-flutter`, `java`, `kotlin`, and `swift`.

## Dependency direction

Profiles provide declarative language packages to the API and engine. The web client consumes the API. Skills describe how agents use authorized Nexora capabilities. Documentation describes the boundaries and evidence; it does not execute in production.

## Historical archive

The original working trees and historical technical records are preserved separately from the public source layout. They are not replaced by this catalog.
