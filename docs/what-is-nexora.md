# What is Nexora?

Nexora helps a development team build a reliable working picture of a software system and give that context to AI coding agents in a structured, verifiable, and governed way.

Most developer tools answer one narrow question: where is this text, what does this test do, or which files changed? Nexora connects several kinds of context:

- the structure of source code;
- dependencies and relationships;
- technical documents and decisions;
- policies and findings;
- tasks, approvals, and releases;
- evidence that supports each result.

The result is not an unqualified “AI understanding” of a repository. It is a versioned body of facts and reviewed knowledge that a person or an agent can query and inspect.

## Knowledge enters through structured agent work

Nexora's technical knowledge workflow is agent-mediated. The Nexora skill teaches the agent how to classify and structure a proposed requirement, decision, rule, practice, security observation, technical debt item, or explanation. The agent grounds that proposal in authorized Nexora facts: repository snapshots, source evidence, policies, documents, tasks, workflows, and previous decisions.

This means knowledge is not treated as an arbitrary note written without context. Nexora preserves the distinction between observed code, declared organizational knowledge, agent proposal, review, and publication. Humans retain authority over review and publication even when the agent performs the initial authoring.

The same knowledge model can be transversal across repositories and technologies. A project can connect a web application, API, infrastructure repository, mobile client, and shared architectural decision in one context package.

## What Nexora does

Nexora can analyze source using declarative language profiles, produce a code knowledge graph, publish snapshots, reuse unchanged analysis, evaluate deterministic governance policies, expose read-oriented MCP tools, store reviewed knowledge, and connect engineering work to code and documents.

The web and API layers add identity, projects, repositories, documents, tasks, workflows, approvals, Git integrations, and bilingual user interaction around that core.

## What Nexora does not do

Nexora does not execute analyzed source code. It does not use an LLM to invent syntax facts or silently convert missing information into approval. It does not currently provide complete semantic understanding for every language or every construct. Those limits are part of the product contract.

## Who it is for

- Developers who need fast, evidence-backed repository context.
- Reviewers who need to understand architectural or governance findings.
- Teams maintaining technical knowledge over time.
- Platform engineers integrating repositories, workflows, and releases.
- Agents that need bounded context instead of unrestricted filesystem access.

## The central promise

Nexora makes software context explicit: what was observed, where it came from, which snapshot it belongs to, which requirement or decision it relates to, what policy applies, how confident the system can be, and what remains unknown.

The platform also preserves continuity across delivery. Tasks, documents, snapshots, commits, reviews, approvals, workflows, releases, and evidence remain connected so the next agent or developer can continue from the actual state of the work instead of reconstructing it from memory.
