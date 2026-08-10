#!/usr/bin/env bash
# Compare SQLAlchemy models (expected columns) to live Postgres.
# Exit 0 when in sync; non-zero on drift.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

COMPOSE="${COMPOSE:-docker compose}"
# shellcheck disable=SC2086
$COMPOSE exec -T postgres psql -U "${POSTGRES_USER:-bloomdue}" -d "${POSTGRES_DB:-bloomdue}" -t -A -F '|' -c "
SELECT table_name, column_name
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name <> 'alembic_version'
ORDER BY 1, 2;
" > /tmp/bloomdue_db_cols.txt

python3 - <<'PY'
from pathlib import Path

# Keep in lockstep with backend/app/models.py
expected = {
    "users": {"id", "email", "display_name", "created_at"},
    "families": {"id", "name", "created_at"},
    "family_memberships": {"id", "family_id", "user_id", "role", "created_at"},
    "children": {"id", "family_id", "name", "birth_date", "created_at"},
    "care_events": {
        "id",
        "child_id",
        "family_id",
        "type",
        "occurred_at",
        "details",
        "note",
        "client_updated_at",
        "created_by_user_id",
        "created_by_display_name",
        "created_at",
        "updated_at",
    },
    "devices": {"id", "user_id", "platform", "fcm_token", "created_at", "last_seen_at"},
}

actual: dict[str, set[str]] = {}
for line in Path("/tmp/bloomdue_db_cols.txt").read_text().splitlines():
    line = line.strip()
    if not line or "|" not in line:
        continue
    table, col = line.split("|", 1)
    actual.setdefault(table, set()).add(col)

errors = 0
for name in sorted(set(expected) | set(actual)):
    exp = expected.get(name, set())
    act = actual.get(name, set())
    missing = sorted(exp - act)
    extra = sorted(act - exp)
    if missing or extra or name not in expected or name not in actual:
        errors += 1
        print(f"DRIFT {name}")
        if name not in actual:
            print("  table missing from DB")
        if name not in expected:
            print("  table not in models")
        if missing:
            print("  missing columns:", ", ".join(missing))
        if extra:
            print("  extra columns:", ", ".join(extra))
    else:
        print(f"OK    {name} ({len(act)} cols)")

if errors:
    print(f"\nFAIL: {errors} table(s) drifted")
    raise SystemExit(1)
print("\nPASS: models ↔ Postgres in sync")
PY

echo "=== alembic ==="
# shellcheck disable=SC2086
$COMPOSE exec -T backend alembic current
