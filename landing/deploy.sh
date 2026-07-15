#!/usr/bin/env bash
# Deploy bloomdue.baby landing to VPS (bloomdue-platform-landing container).
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PUBLIC="$ROOT/public"
REMOTE_HOST="${REMOTE_HOST:-ubuntu@135.125.226.37}"
REMOTE_TMP="/tmp/bloomdue-landing-new"
REMOTE_PUBLIC="/home/u_bloomdue/bloomdue-platform/landing/public"
COMPOSE_DIR="/home/u_bloomdue/bloomdue-platform"

if [[ -z "${SSHPASS:-}" ]]; then
  printf 'Set SSHPASS for VPS deploy (ubuntu@%s).\n' "${REMOTE_HOST#*@}" >&2
  exit 1
fi

if ! command -v sshpass >/dev/null 2>&1; then
  printf 'sshpass is required for deploy.\n' >&2
  exit 1
fi

export SSHPASS

ssh_cmd() {
  sshpass -e ssh -o StrictHostKeyChecking=no "$REMOTE_HOST" "$@"
}

scp_cmd() {
  sshpass -e scp -o StrictHostKeyChecking=no "$@"
}

printf '==> Preparing remote temp directory\n'
ssh_cmd "mkdir -p $REMOTE_TMP && rm -rf ${REMOTE_TMP:?}/*"

printf '==> Uploading landing assets\n'
scp_cmd -r "$PUBLIC"/* "$REMOTE_HOST:$REMOTE_TMP/"

printf '==> Installing files and rebuilding landing container\n'
ssh_cmd "sudo cp -r ${REMOTE_TMP}/* ${REMOTE_PUBLIC}/ && \
  sudo rm -f ${REMOTE_PUBLIC}/language.js && \
  sudo chown -R u_bloomdue:u_bloomdue ${REMOTE_PUBLIC} && \
  sudo -u u_bloomdue bash -c 'cd ${COMPOSE_DIR} && docker compose -f docker-compose.prod.yml --env-file .env build landing && docker compose -f docker-compose.prod.yml --env-file .env up -d landing' && \
  echo DEPLOY_OK"

printf '==> Done — https://bloomdue.baby/\n'