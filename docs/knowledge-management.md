# Knowledge management

Nexora treats knowledge as a managed product domain, not as a folder of markdown files. Its most important ingestion path is agent-mediated: an agent uses the Nexora skill to turn evidence-backed observations and decisions into structured knowledge.

## The agent is the authoring channel

The agent does not receive a blank text box and write whatever it wants. The skill teaches it to classify the content, identify its scope, connect it to the right repository, project, task, or document, and attach evidence. The agent can propose requirements, technical decisions, business or technical rules, good practices, security controls and threats, technical debt, feature context, explanations of observed code, and cross-repository architectural relationships.

The proposal must be grounded in facts Nexora can provide. The source of those facts may be an authorized repository snapshot, a document, a task, a policy result, a previous reviewed decision, or supplied evidence. The agent's proposal is not automatically an approved organizational rule.

This structure gives knowledge a criterion: the agent is expected to explain what was observed, what is being proposed, what evidence supports it, and what remains uncertain.

## What can be managed

The platform supports knowledge articles and documents covering requirements, decisions, business rules, good practices, security controls, threats, technical debt, features, reviews, project context, and operational guidance.

Knowledge can be:

- created and revised;
- linked to tasks, repositories, requirements, and other documents;
- submitted for review;
- approved or published through a document workflow;
- exported or packaged as project context;
- searched through structured and vector-assisted retrieval;
- connected to evidence and code snapshots.

## Human review and publication

The initial authoring may be performed by an agent, but review and publication remain separate authority steps. A human can inspect the evidence, revise the document, approve or reject the proposal, and publish the accepted version. This prevents “the agent wrote it” from becoming equivalent to “the organization approved it.”

## Knowledge is not automatically truth

Observed code, declared business rules, and agent proposals are different kinds of information. Nexora preserves that distinction. A document revision can contain an assertion, but publication and review state explain whether the organization has accepted it.

## Connection to code

A repository snapshot provides observed code facts. A knowledge document provides agent-proposed, human-authored, or reviewed context with an explicit provenance state. Links between them allow a developer or agent to move from a policy or decision to the code evidence that matters, and from a code finding back to the decision or requirement that explains it.

## Transversal project knowledge

Knowledge is not restricted to one repository or one language. A project context can connect several repositories and technologies: for example, a React web client, a Rust API, a Flutter application, Kubernetes configuration, and shared architectural decisions. The context package preserves which repository and snapshot support each statement so cross-system knowledge remains traceable instead of becoming an unqualified summary.

## Retrieval and agents

MCP and API retrieval can expose documents, context packages, knowledge contributions, reviews, and code-context chunks within authorized scope. Retrieval helps an agent find relevant context; it does not authorize the agent to approve, publish, or rewrite knowledge without the required operation and human authority.
