#!/usr/bin/env bash
# Capture demo screenshots from Pixel emulator while integration test runs.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export PATH="${HOME}/Library/Android/sdk/platform-tools:${HOME}/development/flutter/bin:${PATH}"
DEVICE="${DEVICE:-emulator-5554}"
OUT_DIR="${OUT_DIR:-$HOME/Downloads/bloomdue-x-screenshots}"
LOCAL_DIR="$ROOT/screenshots/x_post"
LOG="$ROOT/screenshots/drive_capture.log"

mkdir -p "$OUT_DIR" "$LOCAL_DIR"
: >"$LOG"

echo "==> Device: $DEVICE"
adb -s "$DEVICE" wait-for-device
adb -s "$DEVICE" shell pm clear baby.bloomdue.app >/dev/null 2>&1 || true

echo "==> Starting flutter drive (demo seed + holds)"
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/demo_screenshots_test.dart \
  -d "$DEVICE" \
  >"$LOG" 2>&1 &
DRIVE_PID=$!

cleanup() {
  kill "$DRIVE_PID" 2>/dev/null || true
}
trap cleanup EXIT

echo "==> Watching for ###SHOT### markers (pid=$DRIVE_PID)"
seen=""
deadline=$((SECONDS + 600))
while kill -0 "$DRIVE_PID" 2>/dev/null && (( SECONDS < deadline )); do
  if grep -q '###SHOT_DONE###' "$LOG" 2>/dev/null; then
    break
  fi
  while IFS= read -r line; do
    name="${line#*###SHOT### }"
    name="$(echo "$name" | tr -d '\r' | awk '{print $1}')"
    [[ -z "$name" ]] && continue
    case " $seen " in
      *" $name "*) continue ;;
    esac
    seen="$seen $name"
    echo "   capturing $name …"
    sleep 1.5
    adb -s "$DEVICE" exec-out screencap -p >"$LOCAL_DIR/${name}.png"
    cp -f "$LOCAL_DIR/${name}.png" "$OUT_DIR/${name}.png"
    ls -lh "$OUT_DIR/${name}.png"
  done < <(grep '###SHOT###' "$LOG" 2>/dev/null || true)
  sleep 1
done

# Final pass for any remaining markers
sleep 2
while IFS= read -r line; do
  name="${line#*###SHOT### }"
  name="$(echo "$name" | tr -d '\r' | awk '{print $1}')"
  [[ -z "$name" ]] && continue
  case " $seen " in
    *" $name "*) continue ;;
  esac
  seen="$seen $name"
  echo "   late capture $name …"
  adb -s "$DEVICE" exec-out screencap -p >"$LOCAL_DIR/${name}.png"
  cp -f "$LOCAL_DIR/${name}.png" "$OUT_DIR/${name}.png"
done < <(grep '###SHOT###' "$LOG" 2>/dev/null || true)

wait "$DRIVE_PID" || true
trap - EXIT

echo ""
echo "==> Screenshots in $OUT_DIR"
ls -lah "$OUT_DIR"
count=$(find "$OUT_DIR" -name 'bloomdue_*.png' | wc -l | tr -d ' ')
echo "Count: $count"
if [[ "$count" -lt 1 ]]; then
  echo "No screenshots captured. Last log lines:"
  tail -40 "$LOG"
  exit 1
fi
echo "Done."
