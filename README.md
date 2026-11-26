# mega-docker

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

Headless [MEGAcmd](https://github.com/meganz/MEGAcmd) Docker image: sync MEGA cloud storage on a server or NAS.
Multi-arch (`amd64`/`arm64`), MEGAcmd version pinned and checksum-verified at build, runs as an unprivileged user.

## Quickstart

1. Clone this repo and edit `docker-compose.yaml`:
   - map your host folder into `/data/sync`
   - set `PUID`/`PGID` to your host user (`id -u`, `id -g`)
2. Start:

   ```sh
   docker compose up -d --build
   ```

3. Wait for `healthy` in `docker ps`, then log in:

   ```sh
   docker compose exec --user 1000 --env HOME=/home/mega megacmd mega-cmd
   ```

   ```
   login you@example.com   # prompts for the password
   ```

   One-shot alternative: `mega-login you@example.com 'password'` — the password ends up in your local shell history.

4. Sync:

   ```
   mega-sync /data/sync /Photos   # local folder ↔ cloud folder
   ```

### Shared folders

```
mega-mount                                                       # lists incoming shares
mega-sync /data/sync/theirs //from/their.email@example.com:share-name
```

### Other commands

All `mega-*` commands work. Run them as the service user (as above), never as root — a root client is refused by the session socket and spawns a stray second server.

## Configuration

| Env | Default | Purpose |
| --- | --- | --- |
| `PUID` | 1000 | uid files are synced as; match your host user |
| `PGID` | 1000 | gid files are synced as |

| Mount | Purpose |
| --- | --- |
| `/data/sync` | host folder synced with the cloud |
| `/etc/machine-id` (read-only) | host machine id, used as the sync device identity — [meganz/MEGAcmd#623](https://github.com/meganz/MEGAcmd/issues/623) |
| `/home/mega/.megaCmd` | named volume `megacmd-config`; login session, survives redeploys |

Only `/data/sync` and the login session persist. Files downloaded elsewhere in the container are lost on redeploy.

## Logs

```sh
docker compose logs -f megacmd
```

## Health

The image ships a `HEALTHCHECK` that runs `mega-help` against the MEGAcmd socket as the service user. `docker ps` shows `healthy` once the server answers.

## Build elsewhere, deploy to NAS

Build on any machine, load on the target:

```sh
docker buildx build --platform linux/amd64 -t megacmd-local -o type=docker,dest=megacmd-local.tar .
# on the target host:
docker load -i megacmd-local.tar
```

For arm64 targets use `--platform linux/arm64`.

## Upgrading MEGAcmd

Bump `MEGACMD_VERSION` and the matching `MEGACMD_SHA256_*` in the `Dockerfile`; current values are listed in [MEGA's repo index](https://mega.nz/linux/repo/Debian_13/Packages).

## License

[Apache-2.0](LICENSE)
