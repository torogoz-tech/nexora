# From code to governed work

Nexora connects technical context to the work that changes a system.

```text
requirement
  -> task and acceptance criteria
  -> code change
  -> repository snapshot
  -> policy evaluation and evidence
  -> review or approval
  -> release context
  -> durable technical knowledge
```

The platform contains task pools, task types, dependencies, comments, templates, workflow versions, transitions, approvals, documents, evidence, release composition, and repository integrations. The exact available transition depends on the configured workflow and permissions.

Transitions are executable governance rules. They define the guards that must be true, the ordered repository or delivery actions that may run, the point at which state advances, and the notifications or handoffs that follow. See [Workflow transitions](workflow-transitions.md) for the complete contract, including what agents and humans can and cannot do.

States can also define a required base branch or ref, while transitions can create or verify working branches, push state, pull requests, checks, merges, and deployments. This binds the workflow state to repository evidence without pretending that a state name automatically creates a remote branch.

A task can also move from one published workflow to another through an explicit handoff transition. This allows a product workflow to pass work to implementation, review, release, or deployment workflows while preserving the same task identity and history. Each receiving workflow applies its own permissions, guards, branch rules, approvals, and terminal conditions.

## A developer-facing example

An engineer can start from a task, inspect the repository context attached to the project, query a snapshot for a symbol or dependency, review a governance finding, attach evidence to the task, request approval, and preserve the final decision in a document or release record.

## Agents and workflows

MCP gives agents bounded operations over the context that the installation authorizes. The agent can ask for facts, documents, tasks, or workflow state. It does not receive an unrestricted license to edit source or approve governance decisions merely because it can query them.

The web interface presents these workflows to people in English or Spanish. Language changes presentation, not permissions, evidence, or state transitions.
