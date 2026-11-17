# Versioning and release policy

Nexora is split into independently maintained repositories, so versioning must describe both each component and the compatibility relationship between components. The project uses Semantic Versioning (`MAJOR.MINOR.PATCH`) with an explicit pre-1.0 policy.

## Why `0.1.0` is the correct initial public version

`0.1.0` is appropriate for the first public open-source release. It communicates that the implementation is real and usable, while the public API, MCP catalog, profile contract, deployment packaging, and operational guarantees are still being consolidated through continuous use and review.

It would be premature to call this `1.0.0` while the Kubernetes scale-out work, GitLab live verification, Azure DevOps connector work, and the fixes emerging from the 10-developer validation group are still active. `0.1.0` is not a statement that the product is a toy; it is an honest stability boundary.

## Component versions

Each repository owns its own version and release history:

| Component | Version source | Compatibility responsibility |
| --- | --- | --- |
| `nexora` | `VERSION`, release documentation, and release tag | Describes the ecosystem and its coordinated release map. |
| `nexora-api` | Cargo workspace version | Owns the engine, storage, HTTP API, MCP contracts, and runtime compatibility. |
| `nexora-web` | `package.json` and lockfile root metadata | Owns the browser application and its API client contract. |
| `nexora-skill` | `VERSION` | Owns agent workflow guidance and the expected MCP/authority interaction. |
| `nexora-profile-*` | `VERSION` and `profile/language.yaml` | Owns one declarative language profile and its fixtures and support boundary. |

The version of a dependency must be recorded in release notes or a compatibility matrix. A profile release is not automatically an API release, and a web release is not automatically proof that a provider integration is operational in every environment.

## Container versions

Runtime images use the SemVer version of the component release. For the `0.2.0` API and web release, the image tags are:

```text
nexora-api:0.2.0
nexora-web:0.2.0
```

Floating and commit-derived tags are not part of the release policy. Kubernetes manifests reference the explicit release tag, and operators change that tag through a reviewed release update or private overlay.

## Pre-1.0 rules

Until `1.0.0`, Nexora follows these rules:

- `PATCH` (`0.1.1`) fixes defects, improves documentation, expands verification, or makes an internal change without intentionally changing the published contract.
- `MINOR` (`0.2.0`) adds capabilities or changes a contract that may require consumers to adapt. Breaking changes are allowed in the `0.x` phase, but they must be explicit, documented, and accompanied by migration notes.
- `MAJOR` remains `0` until the project declares the core engine, API/MCP boundaries, profile contract, and deployment expectations stable enough for a first compatibility commitment.

This policy is stricter than treating every pre-1.0 build as disposable. Existing users should be able to understand what changed and which repositories must move together.

## Profile versioning

Profiles are independent products within the Nexora ecosystem:

- Increment the patch version for corrected fixtures, diagnostics, documentation, or a compatible recognition fix.
- Increment the minor version when adding a documented, backward-compatible supported construct or new evidence projection.
- Increment the minor version for a pre-1.0 breaking profile contract, including incompatible schema expectations, removed syntax support, or changed graph meaning. Record the compatible API engine range.

Every profile release must state the compatible `nexora-api` version, tested fixtures, recognized constructs, rejected or partial constructs, unresolved behavior, and known limitations.

## Coordinated release checklist

Before publishing an ecosystem release:

1. choose the component versions and record them in the common release map;
2. verify API, web, skill, and profile compatibility;
3. update each repository's changelog and release notes;
4. run the component tests and profile fixtures;
5. record provider verification separately from local or fixture evidence;
6. create tags in the individual repositories only after the documentation and source have been reviewed;
7. publish a common release note that states what is implemented, verified, pending, and not certified.

The first public release will therefore be the `0.1.0` release line for the current repositories, with independent tags and an explicit compatibility map rather than one monolithic repository version.

## When Nexora should become `1.0.0`

The move to `1.0.0` should happen only after the project has an explicit compatibility commitment for the core API/MCP surface and profile contract, repeatable installation and recovery procedures, verified provider workflows for the supported connectors, and a documented migration policy. Kubernetes scale testing and ongoing team validation are part of the evidence needed for that decision, but scale testing alone does not define semantic stability.

## Architecture and stewardship

Nexora's architecture, initial implementation, repository separation, deterministic analysis model, governance boundaries, and ongoing maintenance are led by [Abner Velasco](https://www.linkedin.com/in/abnervelasco/), the project's architect and maintainer.
