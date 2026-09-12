# Last session

**Date:** 2026-09-10  
**Version:** `1.0.0+20` · Drift schema **v13** · 55 unit/widget + 3 integration test files  
**API:** `https://api.enfold.baby` · local `http://127.0.0.1:8282` (emulator `http://10.0.2.2:8282`)  
**Contact:** `support@enfold.baby`  
**Display:** Enfold · bundle `baby.enfold.app`

## Done recently

Sideload APK **`enfold-1.0.0-20.apk`** on Desktop — first **1.0.0** (Play live numbering). Includes vitamin reminder, 12/24h, log Load more, no Private beta badge.

- **Daily vitamin reminder:** optional, one time of day. Today shows “not logged yet” + Given. Local ping, no streak. Drift **v13**. 2×/day and short courses later.
- **Time format:** Settings → Time. 12-hour (AM/PM) or 24-hour. Default 12-hour. Drift v12.
- **4-tab shell:** Today / Logs / Learn / Settings. Center-docked **Add** FAB → quick-add sheet (all log types + growth; pregnancy when expecting).
- **Pregnancy** is no longer a tab — Settings row, Today shortcut while expecting, and quick-add.
- **Growth trend charts** on Growth (weight / length / head history; not WHO percentiles).
- Care-log date pickers: **3 years back**, last date **tomorrow** (`LogDateBounds`).
- Pull-to-refresh on Today, Logs, Growth, Settings. Periodic partner pull ~45s while open.
- Evening check-in (local, off by default). Leave family. Caregiver profile (Mom/Dad/name).
- API client is `EnfoldApiClient`. `/help/` redirects to `/support/`. Public `/roadmap/` HTML updated locally (redeploy landing to publish).
- Already in this tree: Enfold rebrand, SES from `noreply@enfold.baby`, FCM Android, Play upload keystore, in-app account delete, still-sleeping + Today banner, dark secondary AA.

## Next up

1. Founder: connect Stripe plugin (`/mcps` → stripe → `i`), then hang Payment Links on `/support/`
2. Install `~/Desktop/enfold-1.0.0-20.apk` on the phone
3. Play Console: phone screenshots, Data safety, upload AAB (`1.0.0+20`)
4. iOS family installs: Apple Developer + TestFlight (cannot sideload like Android)

## Blockers / waiting on

- Stripe plugin: **auth required**
- iOS FCM: APNs `.p8`
- Play: phone screenshots on a real phone
- Apple Developer / TestFlight

## Quick resume

```
Read feature/SESSION.md, feature/PICKUP.md, and feature/todos/README.md.
Enfold 1.0.0+20, Drift v13, API https://api.enfold.baby.
Keep markdown current as we ship (feature/MAINTAIN.md).
```
