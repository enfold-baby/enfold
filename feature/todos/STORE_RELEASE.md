# Todo — store release (private beta)

> **Priority:** P2 · **Status:** Internal APK/AAB only · waiting on **DUNS** / store org

## Current state

| Platform | Status |
|---|---|
| Android sideload APK | ✅ `flutter build apk --release` (debug keystore OK for friends/family) |
| Android signed release | 🔲 Uses debug keystore — swap before open beta |
| iOS TestFlight | 🔲 Needs Apple Developer + signing |
| Privacy policy URL | ✅ https://bloomdue.baby/privacy/ |
| Terms URL | ✅ https://bloomdue.baby/terms/ |

**Version:** `0.1.0+9` in `pubspec.yaml` — increment `+N` before each store upload.

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

Simulator works for UI day-to-day without a physical iPhone.

## Before any store upload

- [x] Privacy policy URL on landing page  
- [x] Terms URL on landing page  
- [ ] Medical disclaimer visible in app + store listing  
- [ ] Screenshots (Today, Learn, Logs — demo tooling exists)  
- [ ] `flutter test` green  
- [ ] Smoke test on physical device (S24 + iPhone if possible)  
- [ ] Signed Android keystore  
- [ ] DUNS / developer accounts ready  

## References

- [`BRANDING.md`](../../BRANDING.md) — bundle ID, beta badge  
- [`scripts/build_beta.sh`](../../scripts/build_beta.sh)  
- Landing legal: `landing/public/privacy/`, `landing/public/terms/`  
