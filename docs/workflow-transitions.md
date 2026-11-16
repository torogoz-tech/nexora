# Workflow transitions

Nexora workflows are executable governance rules, not labels attached to tasks. A workflow version defines states, transitions, guards, ordered actions, publication rules, and—when required—the evidence and authority needed to move work forward.

## What a transition means

A transition is a directed operation from one state to another. It is valid only when:

1. the task or document is using the expected workflow version;
2. the requested transition starts at the resource's current state;
3. the caller has the capability and project scope required for the operation;
4. every guard is satisfied by trusted server-side context;
5. the ordered steps can execute without violating the workflow contract;
6. the expected revision and provider facts are still current.

The web application and MCP expose the same domain rules. A button in the web interface and an MCP operation are two ways to request the same governed transition; neither bypasses authorization or evidence requirements.

## Guards: what must be true before advancing

The current workflow model supports guards such as:

| Guard | Meaning |
| --- | --- |
| `required_field` | A named task field must be present and valid. |
| `assignee` | The task must have the required assignment context. |
| `reason` | The caller must provide an explanatory reason. |
| `resolution` | The task must include a resolution. |
| `dependencies_satisfied` | Blocking dependencies must be complete or otherwise resolved. |
| `evidence_valid` | Required evidence must be present and valid. |
| `approved_document_version` | The required document revision must be approved. |
| `working_branch_reported` | The authorized work branch must have been prepared and reported. |
| `human_approval` | A valid, scoped human approval must exist for this operation. |

All configured guards are evaluated. Supplying a field in an agent request does not forge trusted evidence: branch reports, approvals, provider results, and persisted workflow facts are verified independently.

## Ordered transition execution

For transitions with actions, Nexora enforces this order:

```text
preconditions and guards
  -> approval requirement and approval validation
  -> provider actions and evidence checks
  -> exactly one state advancement
  -> notifications or handoff
```

The state does not advance while a required precondition or provider operation is unresolved. A notification failure does not roll back an already valid state advancement, and it must not repeat an external operation such as creating a second pull request.

The current action model can cover branch creation, push verification, pull-request creation, technical review, contributor ratings, pull-request merge verification, merge, pipeline verification, deployment verification, release publication, workflow handoff, notifications, and the state advancement itself. Availability depends on the configured workflow, resource type, repository scope, and provider capability.

## States and repository branches

Workflow states can be connected to repository work. A state may declare a required base branch or ref that Nexora verifies at the provider before the task enters or leaves that state. A transition may then create a working branch from that base, verify a push, create a pull request from the task branch to a configured target, verify checks or a merge, and use the resulting evidence to decide whether the task can advance.

The relationship is explicit rather than magical:

```text
workflow state
  -> required and verified base branch
  -> transition creates or selects working branch
  -> push / pull request / checks / merge evidence
  -> next governed state
```

The workflow does not automatically create a remote branch merely because a state names one. Missing branches, insufficient provider permissions, stale heads, and invalid target refs produce actionable failures. A branch report is also not proof of a push or merge; those facts must be verified independently.

This allows different workflows to express policies such as “work starts from `develop`”, “the pull request targets `stage`”, or “the release transition may only continue after the provider confirms the merge and deployment”. The exact branch names, repository identifiers, and target selectors remain configuration of the published workflow version.

## Moving a task between workflows

A task is not permanently trapped in one workflow. A valid transition can hand it off to another published workflow when the work reaches a boundary that belongs to a different team, discipline, repository process, or delivery stage. The handoff is an explicit workflow action, not an informal status rename.

For example:

```text
Product workflow
  -> requirement accepted
  -> handoff to implementation workflow
  -> code review and repository delivery
  -> handoff to release workflow
  -> deployment verification
  -> final completed state
```

The task keeps its durable identity, requirements, knowledge links, comments, attachments, work logs, repository references, commits, evidence, and transition history. The receiving workflow receives the task at its configured entry point and applies its own guards, permissions, branch rules, approvals, and delivery evidence.

A handoff cannot bypass the source workflow's required guards or approvals, and it cannot make the receiving workflow appear complete. The receiving workflow must be published, authorized for the project and task type, and compatible with the handoff operation. The task is only considered finished when the configured final workflow reaches its valid terminal condition and all required delivery evidence exists.

## What an agent can do

An authorized agent can:

- read the current workflow, state, available outgoing transitions, guards, and transition history;
- inspect the task, requirements, dependencies, repository context, and evidence needed for a transition;
- prepare or report repository work when the assigned capability and workflow permit it;
- create a branch or pull request through a configured provider when the transition authorizes it;
- submit evidence, request approval, and ask the server to execute a permitted transition;
- retry a failed transition using the recorded request identity;
- report uncertainty when a provider operation cannot be confirmed.

An agent cannot:

- choose a transition that is not outgoing from the current state;
- bypass a guard, permission, dependency, revision check, or repository policy;
- manufacture a human approval through MCP or by sending `human_approval` as a field;
- turn a local branch or commit into proof of a remote push, merge, deployment, or release;
- treat an unknown provider result as success or blindly repeat an uncertain operation;
- edit a published workflow version in place;
- claim that a terminal task state proves production delivery unless the workflow requires and verifies it.

## What a human can authorize

A human with the required authority can review evidence, approve or reject a specific operation, publish a workflow version, revise a draft, change assignments, and perform the transitions allowed by the configured permissions. Approval is bound to the resource, operation, workflow transition, current revision, and relevant parameters. A later change to those values requires reconciliation or a new approval.

Human authority is not unlimited. It is still constrained by project scope, resource permissions, immutable published versions, valid workflow graphs, provider authorization, and the evidence required by the selected transition.

## Workflow design rules

- A workflow must have one reachable initial state.
- Transition endpoints must exist in the graph.
- Published versions are immutable; changes create or update a draft and require a new publication.
- A terminal state means the configured workflow has reached its terminal condition; it does not automatically mean that a release is deployed.
- A `publishable` document state explicitly grants publication eligibility; terminal status alone does not.
- States may prevent backtracking by requiring an ordered progress value.
- Automatic final pipelines are restricted to the terminal-state rules defined by the workflow contract.
- Existing tasks keep their pinned workflow versions until an authorized migration changes them.

## Failure, retry, and reconciliation

Every transition attempt has durable history. Nexora distinguishes validation failure, authorization denial, provider rejection, temporary failure, and unknown provider outcome. Retrying is safe only when the same request identity and compatible parameters are used. If the provider outcome is unknown, Nexora reconciles the branch, pull request, checks, merge, or deployment before continuing.

This is why a workflow transition is more than a status update: it is a controlled, auditable boundary between intention, evidence, external repository work, and the next valid state.
