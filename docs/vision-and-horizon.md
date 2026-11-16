# Nexora vision and horizon

Nexora is not intended to remain only a code analyzer, a task manager, or an MCP server. Its long-term purpose is to become a governed operating context for software engineering: a durable layer where repositories, architecture, knowledge, work, policies, evidence, and delivery history remain connected and available to both people and agents.

## The problem we want to solve completely

AI agents are becoming better at producing code, but software organizations still lose time and reliability at the boundaries around code:

- the agent does not know the repository's real structure;
- decisions are scattered across conversations and documents;
- different repositories use different languages and delivery processes;
- tasks lose their evidence when they move between people or workflows;
- continuous delivery can erase the reason a change was made;
- an external provider can report an uncertain result;
- knowledge is introduced without enough provenance or review.

Nexora's horizon is to make those boundaries explicit, queryable, and governed so that increasing agent capability produces more consistent engineering instead of more uncontrolled change.

## North-star outcome

An authorized agent should be able to enter a project, understand the current technical and organizational context, propose a change grounded in evidence, carry it through the correct repository and workflow boundaries, and leave behind durable knowledge for the next person or agent.

The organization should be able to answer:

1. What do we know about this system?
2. Which repository revision and evidence support that knowledge?
3. Which decisions and policies govern the proposed change?
4. What work has actually been performed and verified?
5. Which actions can the agent take, and which require a person?
6. What remains unknown, pending, or unsafe to infer?

## Horizon by stage

### Stage 1: public foundation — `0.1.0`

This is the first open-source release line. It establishes the architecture and the core contracts:

- deterministic, profile-driven static analysis;
- immutable snapshots with source evidence and explicit unknowns;
- PostgreSQL, Dragonfly, Neo4j, and vector-assisted retrieval with separate responsibilities;
- repository-first work across local repositories and GitHub/GitLab integration paths;
- agent-mediated knowledge proposals with provenance and review;
- tasks, help desk, workflows, approvals, branches, pull requests, releases, and reconciliation;
- bilingual human-facing web experience;
- independently maintained language profiles and skills.

The goal of this stage is a credible, inspectable foundation—not a claim that every connector, language, or deployment topology is complete.

### Stage 2: operational hardening — the next release line

The next stage focuses on finishing the work already visible in the current product:

- complete GitLab live verification;
- continue the 10-developer validation cycle and close task/workflow fixes;
- install and test the Kubernetes scale-out architecture;
- turn operational lessons into reproducible deployment, backup, recovery, and observability artifacts;
- strengthen compatibility checks between the API, web client, skill, and independent profiles;
- expand provider reconciliation and failure reporting from real team use.

This stage is about proving that the governed contracts remain reliable under continuous work, not merely adding more screens or tools.

### Stage 3: broader engineering coverage

Once the foundation is hardened, Nexora can grow across the engineering lifecycle:

- first-class Azure DevOps connectivity;
- more language and framework profiles maintained independently;
- richer cross-repository context packages and architectural relationship analysis;
- stronger policy composition for security, architecture, testing, documentation, and release controls;
- better workflow handoffs between product, implementation, review, release, operations, and support;
- reproducible organization-level knowledge with clearer freshness and impact tracking;
- metrics that measure reduced repeated discovery, preserved continuity, review quality, and delivery confidence.

### Stage 4: governed agent teams

The long-term direction is not unrestricted agent autonomy. It is coordinated agent work within explicit authority:

- agents specialize in analysis, implementation, review, documentation, operations, or support;
- Nexora supplies each agent only the bounded context and permissions required;
- agents can hand work between workflows and repositories without losing identity or evidence;
- risky actions require human approval or stronger policy gates;
- every external operation is idempotent, reconciled, and reversible where possible;
- accepted knowledge becomes reusable context instead of disappearing into one conversation.

The objective is an engineering system in which agents become more capable because the context is better structured, while people retain meaningful control over decisions and irreversible actions.

## What will not change

The horizon does not abandon the principles that make Nexora trustworthy:

- repository facts remain separate from agent interpretation;
- observed, declared, proposed, reviewed, and published knowledge remain distinct;
- missing evidence becomes `UNKNOWN`, not invented certainty;
- published workflow versions and historical revisions remain durable;
- independent profiles remain independently maintainable;
- provider consent, Nexora identity, and human approval remain different authorities;
- scaling the infrastructure does not weaken the evidence and governance model.

## How we will know we are advancing

Progress is not measured only by feature count. Each stage should produce evidence that:

- agents need less repeated repository discovery;
- developers can resume work from durable context;
- cross-repository changes preserve their rationale and evidence;
- tasks do not silently skip required workflow boundaries;
- provider uncertainty does not create duplicate branches, pull requests, or releases;
- profiles expose their real support limits and remain compatible with the engine;
- operators can restore the system and verify its historical knowledge;
- human reviewers can understand and reverse consequential agent actions.

Nexora's first public version is therefore the beginning of a trajectory, not the end of the product definition. `0.1.0` publishes the foundation; the horizon explains what that foundation is intended to become.
