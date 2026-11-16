# End-to-end repository delivery

This is the complete Nexora story: repository context becomes governed work and then becomes durable history for the next change.

```text
GitHub/GitLab connection or local repository
  -> repository registration and authorization
  -> profile selection
  -> pinned commit and analysis job
  -> snapshot, graph, coverage, and evidence
  -> requirement, knowledge, or service context
  -> task and acceptance criteria
  -> dependency and workflow checks
  -> provider-created branch from verified base SHA
  -> local developer/agent implementation
  -> tests, evidence, and commit binding
  -> governed pull request
  -> checks, review, policy evaluation, and approval
  -> merge/deployment evidence
  -> release composition
  -> next repository snapshot and preserved context
```

## What the agent can see

The agent can receive the pinned task, requirements, project knowledge, repository policy, snapshot queries, code evidence, previous findings, branch facts, and workflow state. It does not need unrestricted filesystem or provider access to understand the work.

## What the agent cannot claim automatically

The agent cannot turn a task assignment into authorization, a local commit into a push, a pull request into a merge, a green check into a deployment, or a proposed document into approved knowledge. Each boundary has its own evidence and authority.

The same task can cross multiple workflow boundaries before reaching its final outcome. A governed handoff preserves the task's history and evidence while requiring the receiving workflow to validate its own entry conditions. This lets one task coordinate product, implementation, review, release, and deployment processes without collapsing them into one ambiguous status field.

## Why continuity matters

The next delivery can start from the actual published state, not from a fresh prompt that forgets the previous decision. If a provider operation or deployment is uncertain, Nexora preserves the uncertainty and reconciles it instead of creating a duplicate or erasing history.

The current GitHub path has been checked in the available verification work. The GitLab path remains scheduled for live review and verification this week, so GitLab must remain marked as pending operational verification in release claims.

The current operational validation is being performed with a continuous group of 10 developers. Fixes found while managing real tasks and workflows will be completed before the same end-to-end flow is used as the basis for Kubernetes scale testing. GitHub, GitLab, and Azure DevOps are the planned principal repository connectors; Azure DevOps remains a roadmap integration in the current source.
