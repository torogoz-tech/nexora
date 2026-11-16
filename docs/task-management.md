# Task management

Nexora includes a governed task-management system. It is not only a list of tickets: it connects work to requirements, features, repositories, code evidence, approvals, workflow stages, commits, releases, and delivery records.

## What a task represents

A task is executable work. It can investigate, design, implement, correct, review, or deliver something. Nexora keeps the task distinct from the ideas that explain why the work exists:

- a requirement describes a business need or intentional behavior change;
- a feature describes a reusable product or system capability;
- a task describes work that can be assigned and executed;
- a service request asks for help with something already offered or built.

Keeping these concepts separate prevents a support conversation from silently becoming a product commitment and prevents implementation work from losing its original requirement.

## Task lifecycle

The task domain includes:

- task pools and backlogs;
- task types and templates;
- acceptance criteria;
- dependencies and relations;
- subtasks;
- comments and collaboration;
- task documents and knowledge links;
- work logs and work reports;
- attachments and delivery evidence;
- commits and tested revisions;
- approvals and transition history;
- releases and release composition.

Tasks move through a published workflow. A visible terminal state can complete one stage without proving that the entire delivery pipeline has finished. Nexora distinguishes local work, committed changes, provider publication, merge, checks, deployment, and production delivery.

Each transition is evaluated as a governed operation: the current workflow version, outgoing edge, guards, permissions, expected revision, required evidence, and provider facts must all match. The transition may create or verify repository work, require human approval, advance the task exactly once, and then notify or hand off. See [Workflow transitions](workflow-transitions.md) for the detailed execution and authority model.

Tasks may pass through several workflows during their lifetime. A handoff can move work from product discovery to implementation, from implementation to review, or from delivery to release and deployment. The task remains the same durable work item; only the active workflow boundary changes, and the next workflow starts with its own published rules rather than inheriting an unverified completion state.

## Governance of work

Starting a governed task may require an explicit take operation, current revision, assigned repository scope, branch preparation, acceptance criteria, and a published transition. Dependencies can block starting or completing work. Human approvals authorize the specific parameters and evidence; agents must not invent them.

## Why this helps developers

A developer can begin with a task, inspect its requirements and linked knowledge, select an authorized repository, prepare a provider branch from a pinned base commit, work in a local checkout, attach evidence, record the tested revision, open a governed pull request, request review, and preserve the delivery outcome. The result is a work history that explains not only what changed, but why it changed, where it was changed, and what evidence supported the change.
