#!/usr/bin/env bash
# Deploy enfold.baby landing to VPS (existing landing container).
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PUBLIC="$ROOT/public"

# Host, user and compose directory live outside the repo. Either export
# REMOTE_HOST and REMOTE_DIR yourself or keep them in the private ops env file.
OPS_ENV="${ENFOLD_OPS_ENV:-$HOME/Documents/enfold/ops/ops.env}"
if [[ -f "$OPS_ENV" ]]; then
  # shellcheck source=/dev/null
  source "$OPS_ENV"
fi
if [[ -z "${REMOTE_HOST:-}" || -z "${REMOTE_DIR:-}" ]]; then
  printf 'Set REMOTE_HOST (user@host) and REMOTE_DIR (compose directory), or create %s.\n' "$OPS_ENV" >&2
  exit 1
fi
REMOTE_TMP="/tmp/enfold-landing-$$"
REMOTE_PUBLIC="$REMOTE_DIR/landing/public"
COMPOSE_DIR="$REMOTE_DIR"

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