#!/bin/sh
# TOS wrapper for Documenso:
#   * NEXTAUTH_SECRET is generated once and kept on the data volume;
#   * a self-signed signing certificate is generated once (PKCS#12) so document
#     signing works out of the box; replace /data/signing.p12 to use your own.
set -e
set -u

mkdir -p /data

SECRET=/data/nextauth_secret
[ -s "$SECRET" ] || head -c 32 /dev/urandom | base64 | tr -d '\n' > "$SECRET"
export NEXTAUTH_SECRET="$(cat "$SECRET")"

CERT=/data/signing.p12
PASSFILE=/data/signing_pass
[ -s "$PASSFILE" ] || head -c 24 /dev/urandom | base64 | tr -d '\n' > "$PASSFILE"
if [ ! -s "$CERT" ]; then
  TMP=$(mktemp -d)
  openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes \
    -keyout "$TMP/key.pem" -out "$TMP/cert.pem" \
    -subj "/CN=Documenso Self-Signed" >/dev/null 2>&1
  openssl pkcs12 -export -out "$CERT" -inkey "$TMP/key.pem" -in "$TMP/cert.pem" \
    -password "pass:$(cat "$PASSFILE")" -name "documenso" >/dev/null 2>&1
  rm -rf "$TMP"
fi
export NEXT_PRIVATE_SIGNING_TRANSPORT=local
export NEXT_PRIVATE_SIGNING_LOCAL_FILE_PATH="$CERT"
export NEXT_PRIVATE_SIGNING_PASSPHRASE="$(cat "$PASSFILE")"

exec docker-entrypoint.sh sh start.sh
