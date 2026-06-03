# CLAUDE.md

Personal finance app (Nuxt 3 + Nitro on Bun, Drizzle + SQLite).

To run locally: `bun install` then `bun run dev` (http://localhost:3000).

## Platform contract

- The deploy action must be a full Gitea URL. On deploy, the workflow builds and pushes the image, then calls the shared `deploy-stack` action. The action renders the host `.env`, rsyncs `compose.yml` to `/opt/compose/money/`, and runs `docker compose up -d`.
- `traefik-public` is external and platform-owned. Never invent a new network. A stack-local network can't reach Traefik.
- This stack serves the subdomain `money.victor.etc.br` under the platform's wildcard cert for the `victor.etc.br` zone.
- `.env.example` is the full env schema: every variable the app reads, each with a local-dev default. Non-secret config stays here, not hoisted into `compose.yml`. The production `DATABASE_URL` is supplied as a CI override in `deploy.yml`, not committed.
- `/opt/data/money` holds the SQLite database (mounted at `/data`); it is persistent host state, never touched by a deploy.
- This repo carries the Gitea topic `codelab-stack` so it appears in the derived stack inventory.

Canonical contract (networks, middlewares, the deploy action, the stack template) lives in [codelab-infra](https://git.codelab.tec.br/codelab/infra) (`CONTEXT.md`, `docs/adr/`, `templates/stack/`) and [deploy-stack](https://git.codelab.tec.br/codelab/deploy-stack). When in doubt, read these repositories.
