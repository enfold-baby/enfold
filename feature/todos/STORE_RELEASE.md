# Todo — store release (private beta)

> **Priority:** P2 · **Status:** Internal APK/AAB only

## Current state

| Platform | Status |
|---|---|
| Android debug APK/AAB | ✅ `./scripts/build_beta.sh` |
| Android signed release | 🔲 Uses debug keystore |
| iOS TestFlight | 🔲 Needs Apple Developer signing |

**Version:** `0.1.0+4` in `pubspec.yaml` — increment `+N` before each upload.

## Android — release keystore

1. Generate keystore (once, store password safely):
   ```bash
   keytool -genkey -v -keystore bloomdue-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias bloomdue
   ```
2. Create `android/key.properties` (gitignored)
3. Update `android/app/build.gradle.kts` signing config
4. Build: `flutter build appbundle --release`
5. Upload AAB to Play Console → internal testing track

## iOS — TestFlight

1. Apple Developer account + App ID `baby.bloomdue.app`
2. Xcode signing (automatic or manual profiles)
3. Push Notifications capability (needed for FCM later)
4. `flutter build ipa --release`
5. Upload via Transporter or Xcode Organizer

## Before any store upload

- [ ] Privacy policy URL on landing page
- [ ] Medical disclaimer visible in app + store listing
- [ ] Screenshots (Today, Learn, Partner settings)
- [ ] `flutter test` green
- [ ] Smoke test on physical device (Pixel + iPhone if possible)

## References

- [`BRANDING.md`](../../BRANDING.md) — bundle ID, beta badge
- [`scripts/build_beta.sh`](../../scripts/build_beta.sh)