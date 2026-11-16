# Reproducibility and evidence

Every public claim about Nexora should answer four questions:

1. Which source, profile, engine version, and configuration produced it?
2. Which corpus, fixture, or test exercised it?
3. Which result file or evidence span supports it?
4. What boundary prevents the result from being generalized further?

The repository keeps historical reports and raw result files in the original source archive. Public documentation summarizes them without changing their scope. Benchmark reports record operating system, architecture, CPU, build profile, sample count, warmups, timings, RSS, fingerprints, and pass/fail state.

## Reproducing the engine

From `nexora-api`, use the locked Rust toolchain and workspace commands documented in `docs/build-and-test.md`. Build and test commands must run with the same lockfile and profile used by the comparison. Live PostgreSQL, Dragonfly, and Neo4j tests are explicit; the offline suite does not silently depend on local services.

## Reproducing a claim

Do not cite a benchmark number without its scenario and corpus identity. Do not cite a profile as generally supported without reading its capability and limitation documents. Do not cite a governance result without its snapshot, policy version, evidence, and coverage.
