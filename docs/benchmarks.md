# Benchmarks and measured evidence

Nexora publishes measurements with their method and limits. The results are baselines, not universal claims about every repository or language.

## Conformance baseline

The historical baseline recorded on 2026-11-01 used Rust 1.99.1, release builds, macOS arm64, and 14 logical CPUs. It used five measured processes and one warmup per scenario. Forty-two cases passed: 24 curated and 18 synthetic. Within that corpus, 42 expected facts produced 42 true positives, 0 false positives, and 0 false negatives.

That result means precision and recall were 1.0 within the measured corpus. It does not mean complete language coverage, complete semantic understanding, or production-wide correctness.

## Incremental baseline

The incremental corpus contained 44 cases and compared cold, warm, and edited phases across 90 snapshot comparisons. The warm passes reused all unchanged file fragments. Single-file scenarios showed approximately 3.88x–6.58x ratios in the recorded measurements; small replicated repositories were close to 1x. The measurements therefore support a workload-dependent reuse benefit, not a universal speed guarantee.

## Reproduction

The authoritative method, metric definitions, corpus provenance, and raw result files remain in the preserved historical archive from which this public summary was prepared.

The API repository contains the executable corpus and benchmark tooling. A valid comparison requires matching corpus fingerprints, selected cases, engine/profile identity, build mode, environment, sample count, and warmups.

## What the measurements do not establish

They do not establish superiority over another analyzer, universal latency, full language compliance, complete semantic analysis, or production capacity at arbitrary repository sizes. Those claims require new controlled experiments.
