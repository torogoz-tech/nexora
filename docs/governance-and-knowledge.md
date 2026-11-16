# Governance and knowledge

Nexora has two related but distinct forms of understanding.

## Code facts

The analyzer creates facts from source: files, declarations, symbols, imports, dependencies, diagnostics, coverage, and evidence. These facts belong to a snapshot and can be queried without re-reading the live repository.

## Human knowledge

The platform stores reviewed documents, decisions, requirements, best practices, security guidance, technical debt, features, reviews, and context packages. Knowledge has identity, revisions, links, evidence, publication state, and review history.

## Deterministic governance

Policies are compiled into bounded evaluation plans. They can inspect attributes, relationships, coverage, and evidence. Findings keep their target, severity, policy version, snapshot identity, and supporting evidence.

The result model is intentionally conservative:

- `PASS`: the required condition is supported;
- `FAIL`: the condition is contradicted or violated;
- `UNKNOWN`: the available evidence or coverage cannot justify a conclusion.

Limits are explicit. Exhausting an evaluation budget does not become a pass. Unsupported graph relationships are not fabricated to satisfy a policy.

## Human review remains meaningful

Knowledge contributions, policy changes, approvals, and waivers are separate concerns. The platform can record a proposed change and its evidence without pretending that an approval happened automatically.
