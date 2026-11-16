# Ecosystem architecture

Nexora is split by responsibility rather than by deployment convenience.

```text
independent profiles
        |
        v
nexora-api: engine, snapshots, governance, MCP, platform authority
        |
        +--> nexora-web: human interface in English and Spanish
        |
        +--> nexora-skill: bounded agent workflows

nexora: conceptual, scientific, and cross-repository documentation
```

The API and engine own facts, identity, authorization, publication, and governance. Profiles provide language knowledge as data. The repository is the primary integration boundary: local roots and authorized GitHub/GitLab repositories can feed the same work, snapshot, policy, and delivery model. The web application presents platform state to people. Skills describe safe agent workflows but never replace authorization. The common repository explains the ecosystem but is not a runtime dependency.

This split lets a profile evolve independently from the web client, keeps source analysis independent from browser presentation, and makes the boundary between local analysis and authenticated platform operations visible.
