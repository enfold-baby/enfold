#!/usr/bin/env bash
# Nightly Postgres dump for Enfold production. Installed on the VPS as the
# u_bloomdue crontab (see ops/README.md). Keeps 14 daily dumps under
# ~/backups/db. Writes the outcome to backup.log and, on failure, leaves a
# FAILED marker and pings HEALTHCHECK_URL/fail if one is configured.
set -Eeuo pipefail

CONTAINER="${CONTAINER:-bloomdue-postgres}"
DB_USER="${DB_USER:-bloomdue}"
DB_NAME="${DB_NAME:-bloomdue}"
DEST="${DEST:-$HOME/backups/db}"
KEEP_DAYS="${KEEP_DAYS:-14}"
HEALTHCHECK_URL="${HEALTHCHECK_URL:-}"   # e.g. https://hc-ping.com/<uuid>; empty = no ping

mkdir -p "$DEST"
STAMP="$(date -u '+%Y%m%d-%H%M%S')"
OUT="$DEST/enfold-db-$STAMP.sql.gz"
LOG="$DEST/backup.log"

fail() {
  printf '%s FAIL %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$1" | tee -a "$LOG" >&2
  printf '%s %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$1" > "$DEST/FAILED"
  [[ -n "$HEALTHCHECK_URL" ]] && curl -fsS -m 10 --retry 3 "$HEALTHCHECK_URL/fail" >/dev/null 2>&1 || true
  exit 1
}

docker exec "$CONTAINER" pg_dump -U "$DB_USER" --no-owner --no-privileges "$DB_NAME" | gzip -9 > "$OUT" \
  || fail "pg_dump exited non-zero"

SIZE=$(stat -c %s "$OUT" 2>/dev/null || stat -f %z "$OUT")
[[ "$SIZE" -gt 1000 ]] || fail "dump too small ($SIZE bytes): $OUT"
gzip -t "$OUT" || fail "gzip integrity check failed: $OUT"

find "$DEST" -name 'enfold-db-*.sql.gz' -mtime +"$KEEP_DAYS" -delete
rm -f "$DEST/FAILED"
printf '%s OK %s %s bytes\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$OUT" "$SIZE" >> "$LOG"
[[ -n "$HEALTHCHECK_URL" ]] && curl -fsS -m 10 --retry 3 "$HEALTHCHECK_URL" >/dev/null 2>&1 || true
