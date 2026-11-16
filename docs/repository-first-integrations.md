# Repository-first integrations

Nexora is repository-first. The repository is the anchor that connects source code, analysis profiles, snapshots, tasks, policies, knowledge, branches, reviews, and releases.

This is different from starting with an isolated ticket. A task may describe work, but the work becomes technically meaningful when Nexora can associate it with the authorized repository or repositories, the relevant source revision, the development policy, the branch context, and the resulting evidence.

## Local and remote repositories

Nexora works across two repository realities:

### Local repositories

The local engine can analyze a filesystem root through the CLI or local MCP. It validates the root, applies a selected profile, creates a snapshot, and records source facts without executing the code. Local analysis is useful for development and offline verification.

### Remote repositories

The platform can register repositories hosted by GitHub or GitLab. The remote repository has a stable Nexora identity and provider metadata. Provider authorization, repository selection, source revision, webhooks, and jobs are kept separate from the local filesystem path used by a developer.

This separation matters: a local checkout is not proof that a remote branch was pushed, and a provider connection is not permission to inspect every repository in an account.

## Connecting GitHub

The GitHub connection model uses an installation-scoped GitHub App flow. The installation is authorized, the provider association is verified, and the user selects repositories that Nexora may access. Nexora stores protected references to provider credentials and uses the authorized installation scope when reading repository metadata, commits, branches, checks, or pull requests.

The callback alone is not treated as proof that a repository belongs to the installation. The platform verifies the remote installation and repository association before registering the repository for project work.

## Connecting GitLab

The GitLab connection model uses a configured OAuth application for the installation and host. The authorization-code flow uses PKCE, callback state is bound to the initiating context, scopes are minimized, and the authorized user selects the repositories Nexora may use. Token renewal and provider status are tracked separately from Nexora login.

GitHub/GitLab repository consent is not the same as logging into Nexora. An OIDC login does not automatically grant Git access, and a Git provider consent does not create a Nexora user session.

## Connection lifecycle

```text
configure provider application
  -> start authorization
  -> provider consent and callback
  -> verify installation/account and repository scope
  -> register repository in a project
  -> configure analysis profile and development policy
  -> synchronize a pinned commit
  -> publish/query snapshot and receive webhook updates
```

Secrets, refresh tokens, webhook secrets, and private keys remain outside source control and are protected by the installation's secret-management policy. Webhooks are authenticated, size-bounded, deduplicated, and associated with the correct connection and repository.

## What Nexora can do with a connected repository

Within authorization and the published workflow, Nexora can:

- register and change repository metadata;
- list remote repositories available to the authorized connection;
- synchronize a repository and create an analysis job;
- pin and verify a commit before analysis;
- apply an analysis profile and report issues;
- create provider-backed work branches from a verified base commit;
- associate a task with its provider branch and immutable base SHA;
- inspect commits, branches, pull requests, files, comments, and checks;
- create pull requests as a governed workflow transition when the configured policy permits it;
- link pull requests to tasks or document revisions;
- evaluate provider branch protection and required checks;
- preserve provider-confirmed merge and delivery evidence for releases.

Branch and pull-request creation are not unrestricted convenience commands. They are provider operations guarded by repository authority, branch policy, current revision, expected head/base SHA, idempotency, and workflow approval. If the provider outcome is uncertain, Nexora reconciles the provider instead of blindly creating a duplicate.

Workflows can bind repository operations to their states and transitions. A state may require a verified base branch, and a transition may create a task branch, verify its push, open a pull request against a configured target, or wait for merge and deployment evidence. The binding is configuration-driven and provider-verified; a state does not create a missing branch automatically, and a reported branch does not prove that remote work exists.

## Remote delivery flow

```text
task and requirements
  -> authorized repository selection
  -> Take / work preparation
  -> provider-created branch from pinned base SHA
  -> local developer or agent changes
  -> commit and checks
  -> governed pull-request transition
  -> provider review and approvals
  -> merge or deployment evidence
  -> release composition and next snapshot
```

Nexora distinguishes all of these states. Preparing a branch does not mean code was changed. Reporting a commit does not prove it was pushed. A pull request does not prove it was merged. A merge does not prove production deployment. A task is not globally complete until the configured workflow and provider evidence establish the required delivery state.

## Why this makes Nexora larger than a code indexer

The repository is where static facts meet real engineering work. Nexora can connect a finding to a task, a task to a branch, a branch to a pull request, a pull request to checks and review, a release to its included work, and the next repository snapshot to the delivered state.

That chain gives agents a bounded place to read context and a governed path to act. It also gives companies a way to preserve a consistent engineering line across repositories without pretending that every repository has the same language, architecture, or release cadence.

## Current boundary

Provider operations are authorization- and workflow-dependent. The GitHub connection and provider workflow have been checked in the current verification work. GitLab remains pending live review and verification this week; its contracts and fixtures must not be presented as equivalent proof of operational readiness. Neither integration should be generalized to every external account or deployment path without verifying the real connection, repository scope, branch operation, pull request, checks, merge, and deployment in that environment.
