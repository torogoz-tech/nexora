# Kubernetes deployment inputs

These manifests describe the coordinated Nexora `0.4.0` service set. They are deployment inputs for an operator-managed cluster; environment-specific secrets, ingress, storage, network policies, and resource overlays remain operator-owned.

## Services and routing

The base includes the web application, private API, MCP gateway, and four independent workers: analysis, release, knowledge, and notifications. The API stores durable jobs in PostgreSQL. RabbitMQ carries wake-up messages. Each worker recovers eligible work from PostgreSQL at startup and broker reconnect, and claims jobs using database leases. The release worker owns recovery of pending task transitions and release composition. The API must not be exposed directly to the public network. Route browser `/api` traffic to `nexora-api`; route `/mcp` to `nexora-mcp`. The gateway forwards MCP requests to the API's cluster-private `/mcp` endpoint. The API remains authoritative for MCP authentication, authorization, tools, and execution.

All seven images use the explicit `0.4.0` tag. The manifests use generic image names so an operator overlay can set the private registry without changing the shared base.

## Before applying

1. Set the public browser origin and private API service URL in `base/configuration.example.yaml`, then create `nexora-api-config` and `nexora-worker-config` from the ConfigMap documents in that example. The Secret documents are examples only; do not apply their placeholder values.
2. Create `nexora-api-connections` out of band. Its `connections.json` key must contain the private database connection document used by the API and workers.
3. Provision a RabbitMQ service that the API and all four workers can reach on a private network. Configure a user and virtual host for Nexora. The base does not deploy the broker. Create `nexora-runtime-secrets` out of band with `rabbitmq-url` and `openai-api-key`. Set `rabbitmq-url` to the broker URI, including the configured credentials and virtual host. Restrict access to the Secret.
4. Create the `nexora-language-profiles` PVC and populate it with the profile directories referenced by `analysis-worker.json`. The example shows one JavaScript profile; configure each enabled profile and mount its directory at the declared path.
5. Configure the API and release worker Git network policies and credentials through private settings and restricted egress. Analysis and release require Git access; do not store credentials in ConfigMaps.
6. Review worker requests and limits against repository sizes, model/provider limits, and expected concurrency. Scale worker deployments independently after validating database lease and provider limits.
7. Add an Ingress or reverse proxy in a private overlay. Expose the web application and route `/api` to the API only through the trusted proxy. Route `/mcp` to the gateway. Do not add a public route directly to the API service.
8. Back up PostgreSQL, apply the API migrations as an explicit operator step, then apply the base and private overlays. Verify `/health` and `/ready` for API, `/health` for web and MCP, and one job lifecycle for each worker queue.

The analysis and release workers use an `emptyDir` source workspace. Their init containers set it to mode `0700` and ownership `10001`; cluster policy must permit that narrow init-container ownership setup. The workspace is disposable and is not a source of truth. The analysis profile PVC is read-only to the worker. The API and workers use a read-only root filesystem and non-root runtime identities.

## Secrets and private database hosts

The example Secret contains placeholders only. Replace them through a secret manager or a private deployment overlay; never commit credentials. The `connections.json` file is loopback-only unless `allow_remote_host: true` is explicitly set. When enabled, the database hostname must resolve to an approved private endpoint and be restricted by network policy and database firewall rules. The current PostgreSQL connector does not configure TLS, so use this only on a trusted private network.

## Rollback

Set the component image tags to the previous coordinated release in a private overlay, apply it, and verify health/readiness and a worker job lifecycle. Database migrations must be checked for backward compatibility before rolling application images back.
