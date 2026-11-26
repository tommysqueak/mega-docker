# Mega Docker

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

Headless [MEGAcmd](https://github.com/meganz/MEGAcmd) Docker image - sync MEGA cloud storage on a server or NAS without having to install the desktop app.

## Features
- Ligtweight container - Debian slim base
- Multi-arch (`amd64`/`arm64`)
- Runs as an unprivileged user
- MEGAcmd version pinned and checksum-verified at build

## Quickstart

1. **Setup**  
Clone this repo and configure ENV vars in `.env`:

   ```sh
   cp .env.example .env
   ```

   - set `SYNC_DIR` to the folder on your host
   - set `PUID`/`PGID` to your host user (`id -u`, `id -g`)

2. **Start container**:

   ```sh
   docker compose up -d --build
   ```

3. **Sign-in to Mega**  
Wait for `healthy` in `docker ps`, then log in:

   ```sh
   docker compose exec --user 1000 --env HOME=/home/mega megacmd mega-cmd  # your PUID if you changed it
   ```

   ```sh
   login you@example.com   # prompts for the password
   ```

4. **Setup sync folder:**

   ```sh
   sync /data/sync /Photos   # local folder ↔ cloud folder. This will sync /Photos (your chose cloud foler) with the $SYNC_DIR on your host machine
   ```

5. **Done**

   ```sh
   exit
   ```

This will exit mega-cmd setup, leaving mega-cmd to keep the folder in-sync with it's cloud counterpart.


## Useful commands

Open bash on the container:

```sh
docker compose exec --user 1000 --env HOME=/home/mega megacmd sh  # your PUID if you changed it
```

Then run any of these or any from the [full list of commands](https://github.com/meganz/MEGAcmd/blob/master/UserGuide.md#command-summary)
```
mega-mount # lists the available root cloud folders
mega-sync /data/sync/theirs //from/their.email@example.com:share-name # sync a folder to a folder thats been shared with you
mega-sync # List currently synced folders
mega-help # list possible commands
mega-whoami # Shows who is signed in
```

### Other commands


All [`mega-*` commands ](https://github.com/meganz/MEGAcmd/blob/master/UserGuide.md#command-summary)work. Run them as the service user (as above), never as root — a root client is refused by the session socket and spawns a stray second server.

## Configuration

Values live in `.env` — copy `.env.example`.

| Env | Default | Purpose |
| --- | --- | --- |
| `PUID` | 1000 | uid files are synced as; match your host user |
| `PGID` | 1000 | gid files are synced as |
| `SYNC_DIR` | required | host folder mapped to `/data/sync` |

| Mount | Purpose |
| --- | --- |
| `/data/sync` | host folder synced with the cloud |
| `/etc/machine-id` (read-only) | host machine id, used as the sync device identity — [meganz/MEGAcmd#623](https://github.com/meganz/MEGAcmd/issues/623) |
| `/home/mega/.megaCmd` | named volume `megacmd-config`; login session, survives redeploys |

Only `/data/sync` and the login session persist. Files downloaded elsewhere in the container are lost on redeploy.

## Build for elsewhere

Build on any machine e.g. Mac, load on the target e.g. Linux:

```sh
docker buildx build --platform linux/amd64 -t megacmd-local -o type=docker,dest=megacmd-local.tar .
# on the target host:
docker load -i megacmd-local.tar
```

For arm64 targets use `--platform linux/arm64`.

## License

[Apache-2.0](LICENSE)
