#!/usr/bin/env bash
# API-level e2e: two real emails against local docker API.
# Pass your own inboxes: ACCOUNT_A=you@example.com ACCOUNT_B=you+2@example.com ./scripts/e2e_account_switch_api.sh
# Verifies each account only sees its own children/care events.
set -euo pipefail

API="${API_BASE:-http://127.0.0.1:8282}"
ACCOUNT_A="${ACCOUNT_A:?set ACCOUNT_A to an inbox you own}"
ACCOUNT_B="${ACCOUNT_B:?set ACCOUNT_B to a second inbox you own}"

echo "== health =="
curl -sf "$API/health" | python3 -m json.tool

token_for() {
  local email="$1"
  local code token
  code=$(curl -sf -X POST "$API/v1/auth/magic-code/request" \
    -H 'Content-Type: application/json' \
    -d "{\"email\":\"$email\"}" | python3 -c 'import sys,json; print(json.load(sys.stdin)["dev_code"])')
  token=$(curl -sf -X POST "$API/v1/auth/magic-code/verify" \
    -H 'Content-Type: application/json' \
    -d "{\"email\":\"$email\",\"code\":\"$code\"}" | python3 -c 'import sys,json; print(json.load(sys.stdin)["access_token"])')
  echo "$token"
}

ensure_child() {
  local token="$1" name="$2"
  local children child
  children=$(curl -sf "$API/v1/children" -H "Authorization: Bearer $token")
  child=$(echo "$children" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d[0]["id"] if d else "")')
  if [[ -z "$child" ]]; then
    child=$(curl -sf -X POST "$API/v1/children" \
      -H "Authorization: Bearer $token" \
      -H 'Content-Type: application/json' \
      -d "{\"name\":\"$name\"}" | python3 -c 'import sys,json; print(json.load(sys.stdin)["id"])')
  fi
  echo "$child"
}

create_event() {
  local token="$1" child="$2" type="$3" id="$4"
  local now
  now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  local payload
  payload=$(python3 -c "import json; print(json.dumps({
    'id': '$id',
    'child_id': '$child',
    'type': '$type',
    'occurred_at': '$now',
    'details': {},
    'note': 'e2e-$type',
  }))")
  local code body
  body=$(curl -sS -w '\n%{http_code}' -X POST "$API/v1/care-events" \
    -H "Authorization: Bearer $token" \
    -H 'Content-Type: application/json' \
    -d "$payload")
  code=$(echo "$body" | tail -1)
  if [[ "$code" != "200" && "$code" != "201" ]]; then
    echo "create_event failed HTTP $code: $(echo "$body" | sed '$d')" >&2
    return 1
  fi
}

list_event_ids() {
  local token="$1" child="$2"
  curl -sf "$API/v1/care-events?child_id=$child" \
    -H "Authorization: Bearer $token" \
    | python3 -c 'import sys,json; print(" ".join(e["id"] for e in json.load(sys.stdin)))'
}

echo "== sign in A: $ACCOUNT_A =="
TOKEN_A=$(token_for "$ACCOUNT_A")
CHILD_A=$(ensure_child "$TOKEN_A" "Baby A")
EVENT_A="$(uuidgen | tr '[:upper:]' '[:lower:]')"
create_event "$TOKEN_A" "$CHILD_A" "diaper" "$EVENT_A"
echo "A child=$CHILD_A event=$EVENT_A"

echo "== sign in B: $ACCOUNT_B =="
TOKEN_B=$(token_for "$ACCOUNT_B")
CHILD_B=$(ensure_child "$TOKEN_B" "Baby B")
EVENT_B="$(uuidgen | tr '[:upper:]' '[:lower:]')"
create_event "$TOKEN_B" "$CHILD_B" "feeding" "$EVENT_B"
echo "B child=$CHILD_B event=$EVENT_B"

echo "== isolation checks =="
IDS_A=$(list_event_ids "$TOKEN_A" "$CHILD_A")
IDS_B=$(list_event_ids "$TOKEN_B" "$CHILD_B")
echo "A events: $IDS_A"
echo "B events: $IDS_B"

echo "$IDS_A" | grep -q "$EVENT_A" || { echo "FAIL: A missing own event"; exit 1; }
echo "$IDS_B" | grep -q "$EVENT_B" || { echo "FAIL: B missing own event"; exit 1; }
if echo "$IDS_A" | grep -q "$EVENT_B"; then
  echo "FAIL: A can see B event"
  exit 1
fi
if echo "$IDS_B" | grep -q "$EVENT_A"; then
  echo "FAIL: B can see A event"
  exit 1
fi

# Cross-account access must fail or return empty / 404
CROSS=$(curl -s -o /tmp/cross.json -w '%{http_code}' \
  "$API/v1/care-events?child_id=$CHILD_A" \
  -H "Authorization: Bearer $TOKEN_B")
echo "B reading A child HTTP $CROSS body=$(cat /tmp/cross.json | head -c 200)"
if [[ "$CROSS" == "200" ]]; then
  if grep -q "$EVENT_A" /tmp/cross.json; then
    echo "FAIL: B listed A's events"
    exit 1
  fi
fi

echo "== PASS: account isolation at API layer =="
