# Installation Map

Install only the component required for the use case.

## Local analysis

Clone `nexora-api`, install the stable Rust toolchain, and use the CLI in offline mode. Add the required profile repositories beside it or provide their package directory explicitly.

## Self-hosted platform

Clone `nexora-api`, provision its documented data services, configure secrets outside the repository, and serve `nexora-web` through a host that proxies `/api` to the API service.

## Agent integration

Install `nexora-skill` in the supported agent environment and configure access to an authorized Nexora API or MCP endpoint. Skills do not contain credentials.
