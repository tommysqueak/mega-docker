#!/bin/bash
set -e

PUID=${PUID:-1000}
PGID=${PGID:-1000}

# create group/user matching the requested IDs, reusing them if they already exist
if ! getent group "$PGID" >/dev/null; then
    groupadd -g "$PGID" mega
fi
GROUP_NAME=$(getent group "$PGID" | cut -d: -f1)

if ! getent passwd "$PUID" >/dev/null; then
    useradd -u "$PUID" -g "$GROUP_NAME" -m -d /home/mega mega
fi
USER_NAME=$(getent passwd "$PUID" | cut -d: -f1)

mkdir -p /home/mega/MEGA
chown -R "$PUID:$PGID" /home/mega

export HOME=/home/mega

exec gosu "$USER_NAME" mega-cmd-server
