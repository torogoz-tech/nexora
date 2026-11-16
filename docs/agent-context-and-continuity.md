# Agent context and delivery continuity

One of Nexora's central purposes is to solve a bottleneck in AI-assisted engineering: coding agents are capable of producing changes, but they are often given fragmented context. A prompt, a few files, and a task description are not the same thing as the organization's technical memory.

Nexora combines the missing pieces into a governed context that both agents and people can inspect.

## How the pieces are mixed

```text
Repository
  -> profile-driven snapshot
  -> symbols, relationships, diagnostics, coverage, and evidence

Requirements and decisions
  -> reviewed documents and project context

Tasks and service requests
  -> acceptance criteria, dependencies, conversations, and responsibility

Policies and workflows
  -> allowed transitions, required checks, approvals, and delivery rules

Commits, reviews, releases, and evidence
  -> what changed, what was tested, what was approved, and what was published

All of the above
  -> bounded, queryable context for the next human or agent
```

Knowledge flows back into the system through the agent as well: the skill gives the agent a structure for turning verified context into a proposed decision, requirement, rule, explanation, or cross-repository relationship. The proposal then follows review and publication rules rather than bypassing them.

The important design choice is not simply storing these objects. It is preserving their relationships, scope, revision, authority, and evidence so that an agent can distinguish:

- observed code from an intended business rule;
- a proposal from an approved decision;
- a task assignment from work that actually started;
- a local commit from a merged change;
- a successful check from a production deployment;
- a current snapshot from an older historical snapshot;
- missing evidence from evidence that proves a negative.

## Why this makes agents more capable

Nexora does not change the underlying model's weights. It improves the context supplied to the model and constrains the actions around that context.

An agent can receive:

1. the relevant repository snapshot instead of an uncontrolled live directory;
2. symbols, dependencies, references, and source evidence instead of only text matches;
3. the requirement, decision, or knowledge document connected to the work;
4. the task's acceptance criteria, dependencies, and current workflow stage;
5. applicable policies and their previous findings;
6. prior commits, tested revisions, reviews, approvals, and release evidence;
7. explicit unknowns where the system cannot justify a conclusion.

The context can be transversal. A single project package may bring together several repositories, languages, deployment manifests, and technical decisions while keeping the evidence anchor for each part.

That context reduces repeated discovery and makes an agent's answer easier to review. The agent can reason from more relevant information, while Nexora keeps the scope and authority of that information visible.

## Uniformity without forcing one implementation

Companies often need a consistent engineering line: naming and architecture rules, required reviews, security controls, approved workflows, documentation standards, and release gates. Nexora represents those expectations as profiles, policies, workflows, task types, templates, and reviewed knowledge.

This creates uniformity at the level of decisions and delivery rules without requiring every repository to be identical. A team can maintain independent language profiles and repository-specific context while applying common governance principles.

## Preserving continuity during continuous delivery

Continuous delivery can destroy context when a task, branch, review, deployment, or document is treated as disposable. Nexora reduces that risk through durable identity and history:

- analysis results belong to immutable snapshots;
- documents have revisions and publication state;
- tasks retain history, dependencies, evidence, and tested revisions;
- workflows retain versions and transition runs;
- approvals are tied to defined operations and current revisions;
- commits and provider operations remain distinct from local claims;
- releases preserve their composition and delivery evidence;
- knowledge links connect decisions to code and work.

The result is a continuity chain:

```text
requirement
  -> decision and knowledge
  -> task and acceptance criteria
  -> code change and snapshot
  -> review, policy result, and evidence
  -> approval and release
  -> durable context for the next change
```

This does not guarantee that a deployment cannot fail or that a human cannot make a bad decision. It prevents the system from treating the next delivery as if the previous work, evidence, and decisions never existed.

## A practical agent interaction

Before changing a repository, an authorized agent can:

1. read the task and its acceptance criteria;
2. inspect blocking dependencies and the published workflow;
3. retrieve the relevant project knowledge and decisions;
4. query the pinned repository snapshot for symbols and dependencies;
5. read repository-specific development policy;
6. make the change in the authorized branch context;
7. run checks and upload evidence;
8. report the actual commit, tests, findings, and remaining uncertainty;
9. request the next governed transition rather than claiming delivery prematurely.

The agent becomes more effective because the context is richer. It becomes safer because the authority, evidence, and state transitions are explicit.
