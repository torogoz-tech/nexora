# Ecosystem Architecture

Nexora is split by responsibility rather than by deployment convenience.

```text
analysis profiles  ->  nexora-api  <-  nexora-web
                         ^
                         |
                    nexora-skill

                    nexora (documentation)
```

The API repository owns deterministic analysis, persistence, governance, MCP, and server-side authorization. Profiles describe syntax and projection rules as data. The web application owns presentation and browser interaction. Skills provide agent-facing workflows and do not replace server authorization.

The separation allows a profile to be updated without releasing the web client and allows the API to evolve without embedding a particular language implementation into the documentation repository.
