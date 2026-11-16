# Identity and permissions

Nexora's authorization model is scoped. A person or agent does not receive access to every object merely because they can log in or hold an API key.

## Scope hierarchy

```text
Installation
  -> actors and users
      -> grants and roles
          -> projects
              -> repositories
                  -> snapshots and analysis
              -> tasks, documents, knowledge, workflows, releases
```

The exact permission is evaluated at the operation boundary. Project visibility does not automatically grant repository source access. Help-desk visibility does not automatically grant technical task or knowledge access. A Git provider consent does not create a Nexora login.

Workflow transitions are operation boundaries too. Being able to read a task or workflow does not grant the ability to advance it, create a branch, open a pull request, approve a transition, merge code, publish a release, or deploy an environment.

## Human and agent identities

Nexora distinguishes human actors, technical actors, sessions, API keys, provider identities, and repository ownership. An agent may act through an authorized MCP key or platform session, but that does not make it a human approver.

Human approval remains a separate authority for operations that require it. A successful agent request, branch report, or code review does not manufacture a human approval receipt.

## Repository and snapshot scope

Repository operations are bounded by installation, project, repository, provider connection, and current authorization. Snapshot queries are additionally bounded by snapshot identity. A client cannot choose an arbitrary tenant, root, or repository path to escape those boundaries.

## Approval and revision control

Mutations use current revisions and idempotency keys where the domain requires them. An approval is tied to the resource, operation, workflow transition, version, and relevant parameters. If the resource or provider state changes before execution, Nexora requires reconciliation or a new approval rather than silently reusing the old decision.

## Practical rule

Always discover current permissions and the current workflow before acting. Treat cached project lists, old branch facts, stale snapshots, and previously observed provider access as evidence to re-check, not as permanent authorization.
