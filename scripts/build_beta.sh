#!/usr/bin/env bash
# Build BloomDue Baby beta artifacts (run from repo root).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> Running tests"
flutter test

echo "==> Building Android App Bundle (Play internal / closed testing)"
flutter build appbundle --release

echo "==> Building Android APK (sideload / emulator smoke)"
flutter build apk --release

echo ""
echo "Beta artifacts:"
echo "  AAB: build/app/outputs/bundle/release/app-release.aab"
echo "  APK: build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "iOS (requires macOS + signing):"
echo "  flutter build ipa --release"
echo ""
echo "Upload AAB to Play Console → Internal testing."
echo "Upload IPA to App Store Connect → TestFlight."