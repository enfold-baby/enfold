#!/usr/bin/env bash
# Upload a release APK and bump remote version for sideload beta updates.
# Usage:
#   APP_VERSION_ADMIN_TOKEN=dev-local-apk-admin \
#   API_BASE=http://127.0.0.1:8282 \
#   ./scripts/publish_beta_apk.sh [path/to.apk] [version] [build]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APK="${1:-$ROOT/build/app/outputs/flutter-apk/app-release.apk}"
VERSION="${2:-0.1.0}"
BUILD="${3:-}"
API_BASE="${API_BASE:-http://127.0.0.1:8282}"
TOKEN="${APP_VERSION_ADMIN_TOKEN:-}"

if [[ -z "$TOKEN" ]]; then
  echo "Set APP_VERSION_ADMIN_TOKEN" >&2
  exit 1
fi
if [[ ! -f "$APK" ]]; then
  echo "APK not found: $APK" >&2
  echo "Build with: flutter build apk --release" >&2
  exit 1
fi
if [[ -z "$BUILD" ]]; then
  # Parse +N from pubspec version: 0.1.0+9
  BUILD="$(rg -n '^version:' "$ROOT/pubspec.yaml" | head -1 | sed -E 's/.*\+([0-9]+).*/\1/')"
fi

echo "==> Upload $APK"
curl -sS -X POST "$API_BASE/v1/app-version/upload" \
  -H "X-Admin-Token: $TOKEN" \
  -F "file=@${APK};type=application/vnd.android.package-archive"
echo

echo "==> Set version=$VERSION build_number=$BUILD"
curl -sS -X PUT "$API_BASE/v1/app-version" \
  -H "Content-Type: application/json" \
  -H "X-Admin-Token: $TOKEN" \
  -d "{\"version\":\"$VERSION\",\"build_number\":$BUILD,\"force_update\":false,\"download_url\":\"/v1/app-version/download\"}"
echo
echo "Done. Clients with build < $BUILD will see the update dialog."
