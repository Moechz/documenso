#!/bin/sh
# TOS wrapper: Documenso needs NEXTAUTH_SECRET at startup. Generate one on the
# first start, keep it on the data volume, then run the upstream entrypoint.
set -u
set -e
mkdir -p /data
F=/data/nextauth_secret
if [ ! -s "$F" ]; then
  head -c 32 /dev/urandom | base64 | tr -d '\n' > "$F"
fi
export NEXTAUTH_SECRET="$(cat "$F")"
exec docker-entrypoint.sh sh start.sh
