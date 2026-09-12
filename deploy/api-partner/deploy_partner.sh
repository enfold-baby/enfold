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

export SSHPASS

ssh_cmd() {
  sshpass -e ssh -o StrictHostKeyChecking=no "$REMOTE_HOST" "$@"
}

scp_cmd() {
  sshpass -e scp -o StrictHostKeyChecking=no "$@"
}

printf '==> Upload partner API files\n'
scp_cmd "$ROOT/models.py" "$REMOTE_HOST:/tmp/bloomdue-models.py"
scp_cmd "$ROOT/schemas.py" "$REMOTE_HOST:/tmp/bloomdue-schemas.py"
scp_cmd "$ROOT/care_events.py" "$REMOTE_HOST:/tmp/bloomdue-care_events.py"
scp_cmd "$ROOT/push.py" "$REMOTE_HOST:/tmp/bloomdue-push.py"
scp_cmd "$ROOT/firebase_credentials.py" "$REMOTE_HOST:/tmp/bloomdue-firebase_credentials.py"
scp_cmd "$ROOT/devices.py" "$REMOTE_HOST:/tmp/bloomdue-devices.py"
scp_cmd "$ROOT/../../backend/requirements.txt" "$REMOTE_HOST:/tmp/bloomdue-requirements.txt"
scp_cmd "$ROOT/../../backend/alembic/versions/20260903_0003_device_fcm_token_unique.py" \
  "$REMOTE_HOST:/tmp/bloomdue-alembic-0003.py"
scp_cmd "$ROOT/migration.sql" "$REMOTE_HOST:/tmp/bloomdue-partner-migration.sql"

printf '==> Install files, run migration, restart backend\n'
ssh_cmd "sudo cp /tmp/bloomdue-models.py ${REMOTE_DIR}/backend/app/models.py && \
  sudo cp /tmp/bloomdue-schemas.py ${REMOTE_DIR}/backend/app/schemas.py && \
  sudo cp /tmp/bloomdue-care_events.py ${REMOTE_DIR}/backend/app/routers/care_events.py && \
  sudo cp /tmp/bloomdue-push.py ${REMOTE_DIR}/backend/app/services/push.py && \
  sudo cp /tmp/bloomdue-firebase_credentials.py ${REMOTE_DIR}/backend/app/services/firebase_credentials.py && \
  sudo cp /tmp/bloomdue-devices.py ${REMOTE_DIR}/backend/app/routers/devices.py && \
  sudo cp /tmp/bloomdue-requirements.txt ${REMOTE_DIR}/backend/requirements.txt && \
  sudo cp /tmp/bloomdue-alembic-0003.py ${REMOTE_DIR}/backend/alembic/versions/20260903_0003_device_fcm_token_unique.py && \
  sudo chown u_bloomdue:u_bloomdue \
    ${REMOTE_DIR}/backend/app/models.py \
    ${REMOTE_DIR}/backend/app/schemas.py \
    ${REMOTE_DIR}/backend/app/routers/care_events.py \
    ${REMOTE_DIR}/backend/app/services/push.py \
    ${REMOTE_DIR}/backend/app/services/firebase_credentials.py \
    ${REMOTE_DIR}/backend/app/routers/devices.py \
    ${REMOTE_DIR}/backend/requirements.txt \
    ${REMOTE_DIR}/backend/alembic/versions/20260903_0003_device_fcm_token_unique.py && \
  sudo -u u_bloomdue bash -c 'cd ${REMOTE_DIR} && \
    set -a && source .env && set +a && \
    cat /tmp/bloomdue-partner-migration.sql | \
      docker compose -f ${COMPOSE_FILE} --env-file .env exec -T postgres \
        psql -U \"\$POSTGRES_USER\" -d \"\$POSTGRES_DB\" && \
    docker compose -f ${COMPOSE_FILE} --env-file .env up -d --build backend' && \
  echo DEPLOY_OK"

printf '==> Done\n'