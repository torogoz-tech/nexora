# Ecosystem architecture

Nexora 0.4.0 defines seven application services with separate responsibilities.

| Service | Responsibility |
| --- | --- |
| `nexora-web` | Browser interface for people using the platform. |
| `nexora-api` | Authenticated HTTP API, platform authority, and durable job creation. |
| `nexora-mcp` | Remote MCP transport. The API authorizes and executes tool calls. |
| `nexora-analysis-worker` | Repository checkout and language analysis. |
| `nexora-release-worker` | Recovery of pending task transitions and composition of release branches. |
| `nexora-knowledge-worker` | Knowledge synthesis, embeddings, daily analysis, and ratings. |
| `nexora-notification-worker` | External email and notification delivery. |

PostgreSQL is the source of truth for domain state and jobs. RabbitMQ sends wake-up messages. Each worker claims its eligible jobs from PostgreSQL and checks for pending jobs at startup and after reconnecting to the broker.

Profiles supply declarative language knowledge. Local roots and authorized remote repositories feed the same snapshot, policy, and delivery model. The agent skill describes workflows subject to platform authorization. The common documentation repository has no runtime role.

See the [deployment architecture](deployment-architecture.md) for infrastructure, routing, and verification requirements.
