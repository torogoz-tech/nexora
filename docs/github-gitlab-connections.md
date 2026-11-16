# GitHub and GitLab connections

Nexora connects to Git providers through explicit installation authorization. The connection is separate from Nexora login and separate from the repository analysis profile.

## GitHub

The intended GitHub path is an installation-scoped GitHub App:

1. configure the App and its callback/manifest settings;
2. start authorization from an authorized Nexora installation;
3. complete provider consent and installation;
4. verify the installation identity and account association;
5. list repositories visible to that installation;
6. select the repositories Nexora may register;
7. store protected credential references and provider metadata;
8. configure webhooks and synchronization jobs.

The callback is not treated as repository ownership proof by itself. Nexora must verify the provider installation and repository association before permitting source operations.

## GitLab

The intended GitLab path is a configured OAuth application for the installation and host:

1. configure the GitLab application and redirect URI;
2. start authorization with PKCE and state bound to the initiating context;
3. obtain consent with the minimum required scopes;
4. exchange and protect the token;
5. list and select authorized repositories;
6. register the repository in the target project;
7. configure webhook verification and synchronization.

GitLab hosts may be self-managed, so the installation must validate the configured host and network policy rather than trusting a URL returned by an untrusted request.

## Connector strategy

The principal repository systems for the team are GitHub, GitLab, and Azure DevOps. GitHub and GitLab use the provider-authorization model described above. Azure DevOps is a planned first-class connector; it is not represented as an implemented provider adapter in the current public source yet.

## Webhooks

Provider webhooks are inputs to synchronization, not authority to read arbitrary data. The receiver must verify the provider signature or token over the original body, enforce a size limit, identify the connection and repository, deduplicate delivery IDs or hashes, and enqueue bounded work.

## Secrets and revocation

OAuth tokens, GitHub installation credentials, private keys, webhook secrets, and refresh tokens belong in the installation secret store. They must never be committed, printed, placed in browser storage, or embedded in an agent prompt.

Revocation must stop future provider access, invalidate or quarantine affected repository bindings as appropriate, and preserve historical snapshots and evidence. Revoking a connection must not erase the organization's historical delivery record.

## Provider verification checklist

Before calling an integration production-ready, verify with a real authorized test installation:

- connection start and callback;
- repository selection;
- commit and branch reads;
- webhook authenticity and deduplication;
- token expiration and renewal;
- provider rate-limit classification;
- branch creation from an exact SHA;
- pull-request creation and reconciliation;
- checks and review state;
- revocation and access denial.

Fixtures and provider contracts are valuable evidence, but they do not replace this live verification.

## Current verification status

- **GitHub:** connection and provider workflow checked in the current verification work and exercised in the validated deployment path.
- **GitLab:** live review and verification pending for this week. Until that work is complete, GitLab support is documented as an implemented integration path with pending operational verification, not as a fully verified production integration.
- **Azure DevOps:** principal roadmap connector; implementation and provider verification remain future work.
