# The static-analysis model

Nexora treats source code as input data. It never executes the source during analysis.

## Pipeline

```text
source file
  -> lexical rules
  -> tokens and source spans
  -> concrete syntax tree (CST)
  -> normalized abstract syntax tree (AST)
  -> symbols and scopes
  -> resolution results
  -> code graph with evidence
  -> coverage and diagnostics
  -> immutable snapshot
```

The common Rust engine owns the pipeline. A language profile supplies the declarative rules. This keeps language-specific knowledge outside the engine and lets each profile evolve in its own repository.

## Evidence is part of the result

Nexora associates facts with source paths, spans, AST or CST anchors, profile rules, and snapshot identity. A relationship can be resolved, ambiguous, or unresolved. The graph does not turn a textual coincidence into a confirmed call or reference.

The snapshot is the unit of historical context. A query against a snapshot can still recover the analyzed source context even when the working tree has changed later.

## Determinism and uncertainty

The same source, profile, engine contract, and configuration should produce the same structured result. The engine records diagnostics and coverage rather than hiding unsupported constructs.

Governance uses `PASS`, `FAIL`, and `UNKNOWN`. `UNKNOWN` means that the evidence or coverage is insufficient for a conclusion; it is not a disguised pass.

## Current boundary

The MVP recognizes a documented subset of language constructs. Bodies, parameters, nested scopes, calls, and type semantics are not universally complete. The current graph vocabulary is broader than the current extractor. A declared enum value is not evidence that every relationship of that kind is already extracted.

See the engine documentation in `nexora-api`. Historical technical records are preserved in the original working archive and are used as source material for the public summaries.
