# Help desk and service requests

Nexora includes a help desk for support, incidents, and service requests about something already built or already offered. It is deliberately separate from the engineering backlog.

## Why it is separate from tasks

A service request keeps its own conversation, state, files, and responsible context. It may later reveal a requirement or link to a task, but it does not become implementation work automatically.

For example:

- “I did not receive the OTP” is a service request.
- “Add OTP expiration, resend, and attempt limits” is a requirement.
- “Implement the resend limit and tests” is a task.

These may be related, but they have different meanings and different lifecycle rules.

## Help desk capabilities

The platform source contains service-request handlers, request workspaces, attachments, links, reports, policies, mutations, and MCP tools. A support conversation can preserve its history while linking to the technical work that eventually resolves it.

The help desk can therefore provide a controlled handoff:

```text
service request
  -> investigation and evidence
  -> linked requirement or task, when justified
  -> technical resolution
  -> response and durable history
```

The handoff does not erase the original support context or retroactively change what the requester asked for.
