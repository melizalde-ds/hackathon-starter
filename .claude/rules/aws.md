# AWS Deploy Pack

Next.js deploys on Vercel (`next.md`). Anything else deploys here. Delete this file, `deploy/` and `scripts/deploy.sh` if the project is Next.js only.

Hackathon scale: one live URL that survives judging. Not production.

## Pick the host

| Host | Pick it when | Runs as |
|------|--------------|---------|
| Lightsail (default) | A long-running service: SSE, in-memory state, a Rust or Python server | Caddy + systemd on one box (`deploy/`) |
| EC2 | Lightsail falls short: GPU, more RAM, or the app needs an IAM role on the box | Same box recipe |
| Lambda + Function URL | Stateless API, webhook or scheduled job. No long streams, no in-memory state | One function per service |
| S3 + CloudFront | Vite-only, no backend | Static files |

Skip ECS, EKS, App Runner and CDK or CloudFormation stacks unless a track requires them.

## Box (Lightsail or EC2)

- `[AWS-01]` One box runs the service and serves the static build. Caddy sends `/api/*` to the service and everything else to the SPA. Same origin: no CORS, no build-time API URL.
- `[AWS-02]` HTTPS with no domain: host is `<ip-with-dashes>.sslip.io` on a static IP. Caddy gets the cert itself.
- `[AWS-03]` `scripts/deploy.sh <host>` builds, uploads and restarts. Safe to rerun. Rust builds in Docker (`rust:1-bookworm`) to match the box's glibc. Python ships the source and runs `uv sync --frozen` on the box.
- `[AWS-04]` Settings live in `/etc/<app>.env`, written from `.env` on first deploy only. Never in the repo or the unit file.
- `[AWS-05]` Qdrant runs on the box in Docker, reachable only from the box (`QDRANT=yes` in `scripts/deploy.sh`). Size: `nano` (0.5 GB) fits a Rust binary alone; Python or a model SDK needs 1 GB; add Qdrant and take 2 GB.

## Lambda

- `[AWS-06]` Python: zip with deps, or a container image if deps are heavy. Rust: `cargo lambda build --release` then `cargo lambda deploy`.
- `[AWS-07]` Function URL for HTTPS, no API Gateway. Hit it once before the demo to warm it.

## IAM

- `[AWS-08]` Every command runs as the `hackathon` profile (`AWS_PROFILE=hackathon`), never root or `default`. Region `us-west-2`.
- `[AWS-09]` The running app gets its own identity, allowed only what it calls (`deploy/iam-app.json`):
  - EC2: an instance role. No keys on the box.
  - Lambda: the execution role.
  - Lightsail can't take an IAM role: a `hackathon-app` user with that policy. Its keys go in `.env` as `APP_AWS_ACCESS_KEY_ID` / `APP_AWS_SECRET_ACCESS_KEY`, and `scripts/deploy.sh` writes them to the box as `AWS_*`.
- `[AWS-10]` A $20 budget alarm on Day 0. Delete the box and the app user's keys after the event.

## AWS as a sponsor

One service is the hero of one demo moment. The box stays the host.

| Service | Hero when | Watch out |
|---------|-----------|-----------|
| Bedrock | The agent, extraction or explanation (`bedrock.md`) | Model access and quota on Day 0 |
| S3 | Users upload files, or the demo serves generated ones | Presigned URLs, never a public bucket |
| DynamoDB | State must survive a restart and the brief needs writes | One table, on-demand billing |

Skip Bedrock Knowledge Bases: the OpenSearch Serverless floor is about $345 a month. Use Qdrant (`bedrock.md`).

## Fallbacks

- `[AWS-11]` Every sponsor or model API has a mock mode switched by one env var, so the live demo survives their outage with one restart.
