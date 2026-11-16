# Repository catalog

All public repositories are independent Git projects. They share a product family but do not share Git history. Each link opens the corresponding public GitHub repository; every repository currently publishes the `v0.1.0` tag.

## Product repositories

| Repository | Responsibility | Version |
| --- | --- | --- |
| [`nexora`](https://github.com/torogoz-tech/nexora) | Product, scientific, architecture, benchmark, and cross-repository documentation | `0.1.0` |
| [`nexora-api`](https://github.com/torogoz-tech/nexora-api) | Rust engine, CLI, server, persistence, governance, MCP, and platform API | `0.1.0` |
| [`nexora-web`](https://github.com/torogoz-tech/nexora-web) | React/TypeScript browser application and bilingual human interface | `0.1.0` |
| [`nexora-skill`](https://github.com/torogoz-tech/nexora-skill) | Agent skills, workflow boundaries, and authoring guidance | `0.1.0` |

## Analysis profile repositories

Each profile is separately maintained and released:

| Profile | Repository | Version |
| --- | --- | --- |
| JavaScript | [`nexora-profile-javascript`](https://github.com/torogoz-tech/nexora-profile-javascript) | `0.1.0` |
| TypeScript | [`nexora-profile-typescript`](https://github.com/torogoz-tech/nexora-profile-typescript) | `0.1.0` |
| TSX | [`nexora-profile-tsx`](https://github.com/torogoz-tech/nexora-profile-tsx) | `0.1.0` |
| JSX | [`nexora-profile-jsx`](https://github.com/torogoz-tech/nexora-profile-jsx) | `0.1.0` |
| HTML | [`nexora-profile-html`](https://github.com/torogoz-tech/nexora-profile-html) | `0.1.0` |
| CSS | [`nexora-profile-css`](https://github.com/torogoz-tech/nexora-profile-css) | `0.1.0` |
| Lua | [`nexora-profile-lua`](https://github.com/torogoz-tech/nexora-profile-lua) | `0.1.0` |
| C# | [`nexora-profile-csharp`](https://github.com/torogoz-tech/nexora-profile-csharp) | `0.1.0` |
| C# Views | [`nexora-profile-csharp-views`](https://github.com/torogoz-tech/nexora-profile-csharp-views) | `0.1.0` |
| Razor | [`nexora-profile-razor`](https://github.com/torogoz-tech/nexora-profile-razor) | `0.1.0` |
| Razor Views | [`nexora-profile-razor-views`](https://github.com/torogoz-tech/nexora-profile-razor-views) | `0.1.0` |
| Dart / Flutter | [`nexora-profile-dart-flutter`](https://github.com/torogoz-tech/nexora-profile-dart-flutter) | `0.1.0` |
| Java | [`nexora-profile-java`](https://github.com/torogoz-tech/nexora-profile-java) | `0.1.0` |
| Kotlin | [`nexora-profile-kotlin`](https://github.com/torogoz-tech/nexora-profile-kotlin) | `0.1.0` |
| Swift | [`nexora-profile-swift`](https://github.com/torogoz-tech/nexora-profile-swift) | `0.1.0` |

## Dependency direction

Profiles provide declarative language packages to the API and engine. The web client consumes the API. Skills describe how agents use authorized Nexora capabilities. Documentation describes the boundaries and evidence; it does not execute in production.

## Historical archive

The original working trees and historical technical records are preserved separately from the public source layout. They are not replaced by this catalog.
