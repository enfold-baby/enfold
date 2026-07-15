# Last session

**Date:** 2026-07-13
**Version:** `0.1.0+7` · Drift schema **v9** · **90** tests passing
**API:** `https://api.bloomdue.baby` (partner attribution deployed)

## Done this session

- **Sync delete + edit to server** shipped (PATCH/DELETE + partner pull reconciliation)
- 3 new sync tests; **87** tests passing
- Pixel 8 emulator launched for manual testing
- **S24 login fix:** release APK was missing `INTERNET` in `android/app/src/main/AndroidManifest.xml` — added permission; rebuilt APK at `~/Downloads/bloomdue-baby-0.1.0+4-fix-internet.apk`
- **Brand launcher icon:** BloomDue bloom mark from `landing/public/favicon.svg` → `assets/brand/` + `flutter_launcher_icons`; APK `~/Downloads/bloomdue-baby-0.1.0+5.apk`
- **Delete fix** (context.mounted bug) + trash “delete forever” — `0.1.0+6`
- **Dark theme:** contrast pass + **theme now persists** in Drift (`app_settings.theme_mode`, schema v9) — `0.1.0+7`
- **Account switching** documented → [`todos/ACCOUNT_SWITCHING.md`](./todos/ACCOUNT_SWITCHING.md) (P2, before public beta)

## Next up (recommended)

1. **Two-parent prod test** on S24 + emulator (invite → join → edit/delete sync)
2. **Pull-to-refresh sync** on Today (quick UX win)
3. **Account switching prompt** → [`todos/ACCOUNT_SWITCHING.md`](./todos/ACCOUNT_SWITCHING.md)
4. **Signed beta build** → [`todos/STORE_RELEASE.md`](./todos/STORE_RELEASE.md)
5. **FCM partner push** — deferred → [`todos/FCM_PARTNER_PUSH.md`](./todos/FCM_PARTNER_PUSH.md)

## Manual test script (emulator)

1. Complete onboarding → Today
2. Settings → sign in with magic code
3. Quick-log a feed → check Recent shows `will sync` then `synced`
4. Long-press entry → Edit → change note → save → should re-sync
5. Long-press → Delete → confirm → entry leaves Recent (soft delete)
6. Settings → Partner → Sync now (if signed in)

## Blockers / waiting on

- FCM: deferred until later (Firebase project + config files)
- Physician review of 25 learn cards (human in the loop)

## Quick resume prompt

```
Read feature/SESSION.md, feature/PICKUP.md, and feature/todos/README.md in bloomdue_baby.
Pick up where we left off. Keep feature/SESSION.md and related docs up to date as we go.
```