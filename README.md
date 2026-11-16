# Nexora

Nexora is an open-source context and governance platform for AI-assisted software engineering. It turns source code, technical knowledge, engineering work, policies, and delivery evidence into traceable, queryable context.

It combines a deterministic static-analysis engine with a knowledge and governance platform. The engine reads source code without executing it, applies declarative analysis profiles, builds a structured representation with evidence, and publishes versioned snapshots. The platform makes those snapshots, documents, policies, tasks, approvals, and workflows available to developers and agents through an authenticated API, a web interface, and MCP integrations.

Nexora is designed to address one of the largest bottlenecks in AI-assisted engineering today: giving coding agents structured, verifiable, and governed context. Teams need more than text search. They need agents to understand what a repository contains, how parts relate, which conclusions are supported by evidence, what is still unknown, which engineering rules apply, and how technical decisions move into governed work.

## Architecture and stewardship

Nexora's architecture, initial implementation, repository separation, deterministic analysis model, governance boundaries, and ongoing maintenance are led by [Abner Velasco](https://www.linkedin.com/in/abnervelasco/), the project's architect and maintainer.

## Agent-mediated knowledge

Technical knowledge enters Nexora through a governed agent workflow. The agent uses the Nexora skill to classify and structure a proposed requirement, decision, rule, good practice, security observation, technical debt item, or explanation. It grounds that proposal in facts and evidence that Nexora provides from authorized snapshots, repositories, documents, tasks, policies, and previous knowledge.

This creates an important quality boundary: the agent does not write arbitrary unstructured notes and present them as truth. Nexora records whether the content is observed, declared, proposed, reviewed, or published. Human review and publication remain meaningful authority steps.

The knowledge can also be transversal. A project context can combine several repositories and technologies, allowing an agent to connect a frontend repository, an API, infrastructure, mobile clients, language profiles, and shared architectural decisions without pretending they are one codebase.

## Read this first

- [What is Nexora?](docs/what-is-nexora.md) — the product in human terms.
- [How the analysis works](docs/static-analysis-model.md) — the deterministic pipeline and its evidence model.
- [Architecture](docs/architecture.md) — the system boundaries and data flow.
- [Analysis profiles](docs/declarative-profile-model.md) — how languages are maintained independently.
- [Storage rationale](docs/storage-rationale.md) — why PostgreSQL, Dragonfly, Neo4j, and vector search have different roles.
- [Governance and knowledge](docs/governance-and-knowledge.md) — policies, findings, documents, evidence, and review.
- [Task management](docs/task-management.md) — backlog, tasks, dependencies, evidence, approvals, and delivery.
- [Help desk](docs/help-desk.md) — service requests, support conversations, attachments, and handoff.
- [Knowledge management](docs/knowledge-management.md) — documents, revisions, contributions, review, and retrieval.
- [Agent context and continuity](docs/agent-context-and-continuity.md) — how code, knowledge, work, governance, and delivery history are combined.
- [Repository-first integrations](docs/repository-first-integrations.md) — local repositories, GitHub, GitLab, branches, pull requests, and remote delivery.
- [Identity and permissions](docs/identity-and-permissions.md) — installations, actors, projects, repositories, grants, and approvals.
- [GitHub and GitLab connections](docs/github-gitlab-connections.md) — authorization, repository selection, webhooks, and revocation.
- [Jobs and reconciliation](docs/jobs-and-reconciliation.md) — leases, retries, provider uncertainty, and publication state.
- [Observability](docs/observability.md) — what operators need to monitor.
- [Backups and recovery](docs/backups-and-recovery.md) — durable data, restore tests, RPO, and RTO.
- [End-to-end delivery](docs/end-to-end-delivery.md) — the complete repository-to-release workflow.
- [Workflows](docs/workflows.md) — how code, knowledge, and engineering work connect.
- [Workflow transitions](docs/workflow-transitions.md) — guards, ordered actions, approvals, agent limits, and reconciliation.
- [Benchmarks](docs/benchmarks.md) — measured results and what they do not prove.
- [Implementation status](docs/implementation-status.md) — implemented, measured, partial, and future capabilities.
- [Vision and horizon](docs/vision-and-horizon.md) — where Nexora is going beyond the `0.1.0` foundation.
- [Reproducibility](docs/reproducibility.md) — how to inspect and reproduce the evidence.
- [Versioning and release policy](docs/versioning.md) — SemVer, component compatibility, `0.1.0`, and the path to `1.0.0`.

## A simple mental model

```text
Source code
  -> profile-driven analysis
  -> tokens, syntax, symbols, relationships, evidence
  -> immutable snapshot
  -> queries, policies, knowledge, workflows, and agent context
  -> an agent receives bounded context and a developer can inspect the fact, its evidence, and the decision built from it
```

Nexora does not claim that every language construct is understood. It records the boundary between what was recognized, what was unresolved, and what was not assessed. This makes an incomplete answer visible instead of silently presenting it as fact.

## A ten-second example

An agent can ask the local MCP server for a symbol without reading the live repository again:

```text
nexora_find_symbol(name: "PaymentService")
```

The response is tied to a tenant, repository, and snapshot, and returns the matching node with its source path and evidence span. A governance check can then report a finding such as:

```text
FAIL  architecture.no-payment-imports
Target: src/checkout/CheckoutService.ts
Evidence: IMPORTS -> src/payments/PaymentService.ts (line 18)
Snapshot: 8f2c...
Why: this module crosses the declared checkout/payments boundary
```

If the import cannot be resolved or the snapshot does not cover the required relationship, Nexora reports `UNKNOWN` instead of presenting the boundary as compliant. The example illustrates the product contract: queryable facts, visible evidence, and a decision that can be reviewed by a person.

## Complex examples

The following scenarios are illustrative compositions of Nexora capabilities. They are intentionally more complete than a single query: the value appears when analysis, knowledge, repository work, and governance are used together.

### Example 1: one change across several repositories

Suppose a team wants to change authentication behavior. The work touches a React web application, a Rust API, a Flutter client, and Kubernetes configuration. A conventional coding agent may receive one ticket and search one checkout at a time. Nexora can create a bounded project context package containing the relevant repositories, published snapshots, architecture decisions, security requirements, open tasks, and deployment constraints.

An authorized agent can begin by retrieving the context and querying the code facts it needs:

```text
nexora_context_package_create(
  project_id: "checkout-platform",
  request_id: "context-auth-001",
  selection: {
    name: "Authentication change context",
    context_manifest_id: "manifest-auth-17",
    task_ids: ["AUTH-214"],
    document_versions: [
      { document_id: "architecture-auth", version_id: "decision-auth-9" }
    ],
    reason: "Prepare bounded context for authentication work"
  }
)

nexora_find_references(
  snapshot: "api-snapshot-42",
  node: "AuthenticationService"
)

nexora_knowledge_context_search(
  project_id: "checkout-platform",
  search: "session renewal and mobile authentication requirements"
)
```

The agent can then determine that the web client calls an API endpoint, the mobile client uses a different token refresh path, and the Kubernetes deployment provides the relevant secret and environment boundary. It does not have to assume that similarly named code in four repositories is the same implementation: each fact remains anchored to its repository and snapshot.

The agent may propose a cross-repository architectural decision through the skill:

```text
nexora_contribute_knowledge(
  request_id: "knowledge-auth-001",
  snapshot: "api-snapshot-42",
  draft: {
    kind: "decision",
    statement: "Session renewal is centralized at the API boundary; clients consume the resulting session contract.",
    source: null,
    target: null,
    relation: null,
    evidence: [
      { path: "src/auth/AuthenticationService.rs", start_line: 42, line_count: 18 },
      { path: "src/auth/session_contract.rs", start_line: 10, line_count: 24 }
    ]
  }
)
```

That proposal is not silently accepted as organizational truth. A reviewer can inspect the source spans, requirements, security policy, and affected repositories, request changes, approve the revision, and publish it. The resulting knowledge is transversal, but its evidence is not blurred into one artificial codebase.

### Example 2: a governed repository delivery

Consider a task that changes a payment boundary. Its implementation workflow might be configured like this:

```text
Ready
  -> In progress       [assigned, dependencies satisfied]
  -> Review             [working branch reported, evidence valid]
  -> Approved           [human approval, pull request checks passed]
  -> Merged             [provider confirms merge into stage]
  -> Released           [deployment verified]
```

The `In progress` state can require `develop` as the verified base branch. Its transition can create a task branch, while the review transition can verify the push and create a pull request from that branch to `stage`. The approval transition can require a human decision tied to the exact task revision, workflow version, pull request, and expected head SHA.

The agent can inspect the task, retrieve the relevant snapshots, prepare the authorized branch operation, run checks, attach evidence, and request the next transition. It cannot claim that a local commit was pushed, that a pull request was merged, or that a deployment occurred. Nexora verifies those facts with the provider and preserves the transition run.

If the provider response is lost after a pull-request request, Nexora records an unknown outcome and reconciles the provider before retrying. It does not blindly create a duplicate pull request. If a human approval was issued for an older revision, it is not reused for a changed task or branch head.

### Example 3: one task, several workflows, one final outcome

A task can cross workflow boundaries as the nature of the work changes:

```text
Product discovery
  -> accepted requirement
  -> handoff to implementation
  -> code review workflow
  -> handoff to release workflow
  -> deployment verification
  -> completed
```

The task keeps its identity, requirements, comments, knowledge links, repository references, commits, evidence, and history. Each receiving workflow starts from its own published entry rules. A release workflow cannot inherit “implemented” as proof that code was reviewed, and a deployment workflow cannot inherit “merged” as proof that production is healthy.

This separation lets an organization keep one continuous work record while assigning different responsibilities and controls to product, engineering, reviewers, release managers, and operators. The final state is reached only when the configured terminal workflow and its required evidence say that the intended outcome has actually been achieved.

### Example 4: continuity after the first delivery

Weeks later, a different agent receives a task to extend the same authentication change. Instead of starting from a blank prompt, it can retrieve the published decision, the exact code snapshot that supported it, the task's tested revision, the review findings, the release composition, and the deployment evidence.

The agent can compare the current repository snapshot with the historical one, identify what changed after the original release, and continue from the accepted architecture. If a previous provider operation was incomplete, it sees the recorded uncertainty and reconciliation result. If the system cannot prove that a relationship still holds, it receives `UNKNOWN` and must investigate rather than treating stale context as fact.

This is how Nexora protects delivery continuity: the next change begins from durable, evidence-linked context instead of reconstructing organizational memory from chat history, scattered tickets, and a live filesystem.

## The problem Nexora is built to solve

AI coding agents are often capable of writing code but lack the durable context of the organization they are helping. They may see a prompt and a few files while missing the repository's architecture, accepted decisions, previous work, workflow rules, evidence, and delivery history. The result is repeated discovery, inconsistent implementation, lost decisions, and continuous delivery that can accidentally discard or contradict work already completed.

Nexora combines those sources into one governed context:

```text
code snapshots + profiles + knowledge + requirements + tasks
        + policies + evidence + workflows + releases
                              ↓
              structured agent context
                              ↓
          more consistent and verifiable engineering work
```

Nexora does not make an agent infallible and it does not guarantee that delivery can never fail. It gives the agent and the people supervising it a durable record of what was known, what was decided, what was changed, what was verified, and what still requires attention.

## A bilingual product

Nexora's user interface is bilingual in English and Spanish. The language choice belongs to the human-facing application layer; it does not change the identity of repositories, snapshots, profile schemas, policy results, or evidence. Technical identifiers remain stable while labels, navigation, messages, and guidance can be presented in either supported language.

The public source documentation is written in English so that contributors can work across repositories. Product documentation describes both English and Spanish user journeys.

## Repository map

The project is intentionally split into independently maintained repositories. See [the repository catalog](docs/repository-catalog.md) for the boundaries and release policy.

## Release status

All public repositories currently target the `0.1.0` initial public release line. Each repository is versioned independently under the policy in [Versioning and release policy](docs/versioning.md). The first public release is documentation-first: the repositories must be reviewed before code is pushed to their public remotes.

## Validated deployment and current infrastructure focus

Nexora has already been exercised successfully in a real self-hosted deployment. The public repositories describe the reusable source and operational contracts; deployment-specific identifiers, URLs, credentials, and private infrastructure details are intentionally excluded.

The current operational validation is being carried out with a continuous working group of 10 developers. Their ongoing use of repositories, tasks, workflows, knowledge, reviews, and delivery processes is being used to identify and close the fixes that appear under real team work.

The team's principal repository connectors are GitHub, GitLab, and Azure DevOps. GitHub is the connector currently checked in the available verification work; GitLab is scheduled for live review this week; Azure DevOps is part of the connector roadmap and will be incorporated as a first-class provider without changing Nexora's repository-first model.

The current infrastructure work is focused on the Kubernetes installation needed to scale beyond a single-host deployment. This includes packaging the API, web application, workers, PostgreSQL/pgvector, Dragonfly, and Neo4j with persistent storage, secret management, TLS, observability, migrations, backups, and recovery verification. Kubernetes scale-out is an active workstream, while the existing platform behavior has already been validated in real operation.

Kubernetes scale testing will begin after the fixes identified through continuous task and workflow management have been completed. This sequence lets the team validate the behavior that will actually be scaled, rather than scaling an unfinished workflow contract.

## License

Nexora is released under the MIT License. See [LICENSE](LICENSE).
