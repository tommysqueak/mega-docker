# ENV-based setup — design

## Intent
Setup today means editing `docker-compose.yaml`: the host sync path and `PUID`/`PGID`. Move those values to a compose `.env` file so users never touch the compose file.

## Goals
- Setup = `cp .env.example .env`, edit, `docker compose up -d --build`.
- Compose file identical for everyone.

## Non-goals
- No parameterizing `MEGACMD_VERSION` (checksum-pinned build arg; moving it would weaken verification).
- No changes to `entrypoint.sh`/`healthcheck.sh` (already env-driven with 1000 defaults).

## Approaches
1. **Compose `.env` interpolation (chosen)** — native compose behavior, no tooling.
2. Shell-exported vars (`PUID=1001 SYNC_DIR=/x docker compose up`) — works but not discoverable or persistent; rejected.
3. Wrapper script generating compose — needless abstraction; rejected.

## Design
- `.env.example` (committed): `PUID=1000`, `PGID=1000`, `SYNC_DIR=`.
- `docker-compose.yaml`: `PUID=${PUID:-1000}`, `PGID=${PGID:-1000}`, `${SYNC_DIR:?...}:/data/sync`.
- Missing `SYNC_DIR` fails `docker compose up` with a clear message (over a `./sync` default: no silently syncing an empty folder).
- `.gitignore` (new): `.env`.
- README: setup step becomes copy+edit `.env`; Configuration table gains `SYNC_DIR`; exec examples annotated — they hardcode `--user 1000`, which breaks when PUID ≠ 1000.

## Left to builder
- Exact README wording.
- Verification: `docker compose config` fails without `.env`, resolves with it; container smoke run if the daemon is available.
