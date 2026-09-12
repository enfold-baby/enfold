#!/usr/bin/env bash
# Deploy enfold.baby landing to VPS (existing landing container).
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PUBLIC="$ROOT/public"
REMOTE_HOST="${REMOTE_HOST:-u_bloomdue@135.125.226.37}"
REMOTE_TMP="/tmp/enfold-landing-$$"
REMOTE_PUBLIC="/home/u_bloomdue/bloomdue-platform/landing/public"
COMPOSE_DIR="/home/u_bloomdue/bloomdue-platform"

if [[ -z "${SSHPASS:-}" ]]; then
  printf 'Set SSHPASS for VPS deploy (%s).\n' "$REMOTE_HOST" >&2
  exit 1
fi

if ! command -v sshpass >/dev/null 2>&1; then
  printf 'sshpass is required for deploy.\n' >&2
  exit 1
fi

export SSHPASS

ssh_cmd() {
  sshpass -e ssh -o StrictHostKeyChecking=accept-new \
    -o PreferredAuthentications=password -o PubkeyAuthentication=no \
    "$REMOTE_HOST" "$@"
}

scp_cmd() {
  sshpass -e scp -o StrictHostKeyChecking=accept-new \
    -o PreferredAuthentications=password -o PubkeyAuthentication=no \
    "$@"
}

printf '==> Preparing remote temp directory\n'
ssh_cmd "rm -rf ${REMOTE_TMP} && mkdir -p ${REMOTE_TMP}"

printf '==> Uploading landing assets\n'
scp_cmd -r "$PUBLIC"/. "$REMOTE_HOST:$REMOTE_TMP/"

printf '==> Installing files and rebuilding landing container\n'
ssh_cmd "cp -a ${REMOTE_TMP}/. ${REMOTE_PUBLIC}/ && rm -f ${REMOTE_PUBLIC}/language.js && cd ${COMPOSE_DIR} && docker compose -f docker-compose.prod.yml --env-file .env build landing && docker compose -f docker-compose.prod.yml --env-file .env up -d landing && echo DEPLOY_OK"

printf '==> Done — https://enfold.baby/\n'