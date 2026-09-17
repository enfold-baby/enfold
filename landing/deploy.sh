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

# Key auth by default. Set SSHPASS to fall back to password auth via sshpass.
if [[ -n "${SSHPASS:-}" ]]; then
  command -v sshpass >/dev/null 2>&1 || { printf 'sshpass is required for password auth.\n' >&2; exit 1; }
  export SSHPASS
  SSH_BIN=(sshpass -e ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no)
  SCP_BIN=(sshpass -e scp -o PreferredAuthentications=password -o PubkeyAuthentication=no)
else
  SSH_BIN=(ssh -o BatchMode=yes)
  SCP_BIN=(scp -o BatchMode=yes)
fi

ssh_cmd() {
  "${SSH_BIN[@]}" -o StrictHostKeyChecking=accept-new "$REMOTE_HOST" "$@"
}

scp_cmd() {
  "${SCP_BIN[@]}" -o StrictHostKeyChecking=accept-new "$@"
}

printf '==> Preparing remote temp directory\n'
ssh_cmd "rm -rf ${REMOTE_TMP} && mkdir -p ${REMOTE_TMP}"

printf '==> Uploading landing assets\n'
scp_cmd -r "$PUBLIC"/. "$REMOTE_HOST:$REMOTE_TMP/"

printf '==> Installing files and rebuilding landing container\n'
ssh_cmd "cp -a ${REMOTE_TMP}/. ${REMOTE_PUBLIC}/ && rm -f ${REMOTE_PUBLIC}/language.js && cd ${COMPOSE_DIR} && docker compose -f docker-compose.prod.yml --env-file .env build landing && docker compose -f docker-compose.prod.yml --env-file .env up -d landing && echo DEPLOY_OK"

printf '==> Done — https://enfold.baby/\n'