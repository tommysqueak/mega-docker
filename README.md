MegaCMD docker image based on Debian

## Build image on Mac for deployment on Linux
docker buildx build --platform linux/amd64 \
  -t megacmd-local \
  -o type=docker,dest=megacmd-local.tar .

## Setup
After deploying container. Open a shell to the running container.

### Login
`mega-login username password`

### Setup a sync

Syncing a cloud folder
`mega-sync /local-dir /cloud-dir`

Syncing a folder share with you (use mega-mount to get shared dir)
`mega-sync /data/vega //from/their.email@example.com:share-name`

### Useful commands

- `mega-mount` list the cloud dir and folder... but also any incoming and outgoing shares.
