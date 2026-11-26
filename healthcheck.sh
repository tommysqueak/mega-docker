#!/bin/sh
set -e

exec gosu "${PUID:-1000}:${PGID:-1000}" env HOME=/home/mega mega-help >/dev/null 2>&1
