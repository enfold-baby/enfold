#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.prod.yml}"
ENV_FILE="${ENV_FILE:-.env}"
BRANCH="${BRANCH:-main}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/bloomdueapp}"

cd "$ROOT_DIR"

log() {
  printf '\n[%s] %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*"
}

compose() {
  docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" "$@"
}

if [[ ! -f "$ENV_FILE" ]]; then
  printf 'Missing %s in %s\n' "$ENV_FILE" "$ROOT_DIR" >&2
  exit 1
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git remote get-url origin >/dev/null 2>&1; then
    log "Pulling latest code from origin/$BRANCH"
    if [[ -f "$SSH_KEY" ]]; then
      export GIT_SSH_COMMAND="ssh -i $SSH_KEY -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
    fi
    git fetch --prune origin
    git checkout "$BRANCH"
    git pull --ff-only origin "$BRANCH"
  else
    log "No git origin remote configured; skipping pull"
  fi
else
  log "Not inside a git worktree; skipping pull"
fi

log "Validating Compose config"
compose config >/dev/null

log "Building production images"
compose build

log "Starting database, cache, and landing page"
compose up -d postgres redis landing

log "Running Alembic migrations"
compose run --rm backend alembic upgrade head

log "Starting API backend"
compose up -d backend

log "Pruning stopped containers from this project"
compose rm -f >/dev/null || true

log "Deployment status"
compose ps
