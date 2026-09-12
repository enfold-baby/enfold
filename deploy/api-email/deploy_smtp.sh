#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
REMOTE_HOST="${REMOTE_HOST:-ubuntu@135.125.226.37}"
REMOTE_DIR="/home/u_bloomdue/bloomdue-platform"
COMPOSE_FILE="docker-compose.prod.yml"

if [[ -z "${SSHPASS:-}" ]]; then
  printf 'Set SSHPASS for VPS deploy.\n' >&2
  exit 1
fi

if [[ -z "${SMTP_PASSWORD:-}" ]]; then
  printf 'Set SMTP_PASSWORD (contact@globinary.io mailbox password).\n' >&2
  exit 1
fi

export SSHPASS

ssh_cmd() {
  sshpass -e ssh -o StrictHostKeyChecking=no "$REMOTE_HOST" "$@"
}

scp_cmd() {
  sshpass -e scp -o StrictHostKeyChecking=no "$@"
}

printf '==> Upload email.py and config.py\n'
scp_cmd "$ROOT/email.py" "$REMOTE_HOST:/tmp/bloomdue-email.py"
scp_cmd "$ROOT/config.py" "$REMOTE_HOST:/tmp/bloomdue-config.py"

printf '==> Install files, update .env, restart backend\n'
ssh_cmd "sudo cp /tmp/bloomdue-email.py ${REMOTE_DIR}/backend/app/services/email.py && \
  sudo cp /tmp/bloomdue-config.py ${REMOTE_DIR}/backend/app/config.py && \
  sudo chown u_bloomdue:u_bloomdue ${REMOTE_DIR}/backend/app/services/email.py ${REMOTE_DIR}/backend/app/config.py && \
  sudo -u u_bloomdue bash -c 'cd ${REMOTE_DIR} && \
    grep -v \"^SMTP_\" .env | grep -v \"^DEV_MAGIC_CODE_LOG=\" > .env.tmp && mv .env.tmp .env && \
    python3 - <<'PY'
from pathlib import Path
import os

root = Path(".env")
lines = [l for l in root.read_text().splitlines() if not l.startswith(("SMTP_", "DEV_MAGIC_CODE_LOG="))]
# Docker Compose treats $ as variable interpolation — escape each $ as $$.
escaped_pw = os.environ["SMTP_PASSWORD"].replace("$", "$$")
lines.extend(
    [
        "SMTP_HOST=mail.privateemail.com",
        "SMTP_PORT=587",
        "SMTP_USER=contact@globinary.io",
        f"SMTP_PASSWORD={escaped_pw}",
        "SMTP_FROM_EMAIL=contact@globinary.io",
        "SMTP_FROM_NAME=Enfold",
        "SMTP_USE_SSL=false",
        "DEV_MAGIC_CODE_LOG=false",
    ]
)
root.write_text("\n".join(lines) + "\n")
PY
    docker compose -f ${COMPOSE_FILE} --env-file .env up -d --build backend' && \
  echo DEPLOY_OK"

printf '==> Done\n'