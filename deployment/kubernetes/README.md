# Kubernetes deployment inputs

These manifests are deployment inputs, not a CD system. They are maintained in the common Nexora documentation repository so the API and web repositories remain independently buildable.

## Version policy

The release version for this set is `0.2.0`. The API and web images use the same SemVer release tag:

```text
nexora-api:0.2.0
nexora-web:0.2.0
```

`latest` and commit-derived tags are not part of the Nexora release policy. A future release must update the application versions, image tags, and this Kustomize image mapping together.

## Operator workflow

1. Import the `nexora-api:0.2.0` and `nexora-web:0.2.0` images into the private server or cluster registry.
2. Create `nexora-api-config` from `base/configuration.example.yaml` with the real browser origin and schema.
3. Create `nexora-api-connections` out of band with the private `connections.json` document.
4. Configure the reverse proxy or Ingress to send browser traffic to `nexora-web` and `/api` plus `/mcp` traffic to `nexora-api`.
5. Back up PostgreSQL and other durable stores, run the API migration as an explicit operator step, and then apply the Deployment and Service resources.
6. Verify `/health` and `/ready` on the API, `/health` on the web service, authentication, API routing, and a synthetic repository operation.
7. Roll back by selecting the previous release tag in an operator-owned overlay and repeating the health and readiness checks.

The example Secret contains a placeholder only. Credentials, TLS material, provider configuration, persistent-volume definitions, ingress hosts, and environment-specific replica/resource choices belong in the operator's private overlay or secret manager.
