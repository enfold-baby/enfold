#!/bin/zsh
# Build and sign the Enfold iOS app for App Store Connect from this Mac.
#
# Same cloud-managed signing as FormKiosk (formkiosk-claude/docs/RUNBOOK.md):
# the team-wide App Store Connect API key lets Xcode create and renew the
# distribution certificate and profile itself, so no Apple ID has to be signed
# in to Xcode. The .p8 lives in ~/.appstoreconnect/private_keys/ (Mac only).
#
# Traps carried over from FormKiosk:
# - `xcodebuild archive` with automatic signing wants a development profile,
#   which needs a registered device; the team has none, so archive unsigned
#   and sign for real at export time.
# - An unsigned archive carries no entitlements, so the exported app would have
#   no aps-environment and push would silently never arrive (FormKiosk has no
#   push, so it never hit this). Before export the archived app gets an ad-hoc
#   signature with Runner.entitlements; export keeps those and signs with the
#   distribution profile, which turns aps-environment into production.
# - Apple's /usr/bin/rsync spawns Homebrew's rsync from PATH and the export
#   dies with "Copy failed", so the export runs with a system-only PATH.
#
# Version and build number come from pubspec.yaml; bump the build number for
# every upload, App Store Connect refuses one it has seen.
#
# usage: ./ios/release.sh            archive + signed IPA only
#        ./ios/release.sh --upload   also validate and upload to App Store Connect
set -euo pipefail
cd "$(dirname "$0")/.."

KEY_ID=2HQ47C3P9P
ISSUER_ID=57422db1-38af-473f-ba55-47f3058555be
KEY_PATH=~/.appstoreconnect/private_keys/AuthKey_${KEY_ID}.p8
OUT=${TMPDIR:-/tmp}/enfold-ios-release
UPLOAD=${1:-}

[ -f "$KEY_PATH" ] || { echo "missing $KEY_PATH"; exit 1; }
rm -rf "$OUT"; mkdir -p "$OUT"
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

echo "== flutter config + pods"
flutter build ios --release --config-only >/dev/null

echo "== archive (unsigned)"
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release \
  -destination 'generic/platform=iOS' -archivePath "$OUT/Runner.xcarchive" \
  CODE_SIGNING_ALLOWED=NO archive | grep -E "error:|\*\* ARCHIVE"

echo "== ad-hoc sign with entitlements"
APP_IN_ARCHIVE="$OUT/Runner.xcarchive/Products/Applications/Runner.app"
for f in "$APP_IN_ARCHIVE"/Frameworks/*.framework "$APP_IN_ARCHIVE"/Frameworks/*.dylib(N); do
  codesign --force --sign - "$f"
done
codesign --force --sign - --entitlements ios/Runner/Runner.entitlements "$APP_IN_ARCHIVE"

cat > "$OUT/exportOptions.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>app-store-connect</string>
  <key>destination</key><string>export</string>
  <key>signingStyle</key><string>automatic</string>
  <key>teamID</key><string>F2884WFRCG</string>
  <key>uploadSymbols</key><true/>
  <key>manageAppVersionAndBuildNumber</key><false/>
</dict>
</plist>
PLIST

echo "== export (cloud-signed with Apple Distribution)"
env PATH=/usr/bin:/bin:/usr/sbin:/sbin xcodebuild -exportArchive \
  -archivePath "$OUT/Runner.xcarchive" -exportOptionsPlist "$OUT/exportOptions.plist" \
  -exportPath "$OUT/export" -allowProvisioningUpdates \
  -authenticationKeyPath "$KEY_PATH" -authenticationKeyID "$KEY_ID" -authenticationKeyIssuerID "$ISSUER_ID" \
  | grep -E "error:|EXPORT"

IPA=$(ls "$OUT"/export/*.ipa)
codesign -dvv "$IPA" 2>&1 | grep -E "Authority|TeamIdentifier|Identifier=" || true
plutil -p "$OUT/Runner.xcarchive/Info.plist" | grep -E "CFBundleShortVersionString|CFBundleVersion"
echo "IPA: $IPA"

if [ "$UPLOAD" = "--upload" ]; then
  echo "== validate + upload"
  xcrun altool --validate-app -f "$IPA" -t ios --apiKey "$KEY_ID" --apiIssuer "$ISSUER_ID" | grep -E "SUCCEEDED|error"
  xcrun altool --upload-app -f "$IPA" -t ios --apiKey "$KEY_ID" --apiIssuer "$ISSUER_ID" | grep -E "SUCCEEDED|error|Delivery UUID"
  echo "uploaded; it appears under TestFlight in App Store Connect after processing (usually 5-20 minutes)."
else
  echo "not uploaded (pass --upload once the App Store Connect record exists)"
fi
