# Last session

**Date:** 2026-08-10  
**Version:** `0.1.0+9` · Drift schema **v9** · unit/widget tests under `test/`  
**API:** `https://api.bloomdue.baby` · Landing: `https://bloomdue.baby`  
**Git:** `main` @ `e78a99e` (local = GitHub = prod VPS)

## Done (recent arc)

### Mobile app
- Private beta at **`0.1.0+9`** — S24 APK at `~/Downloads/bloomdue-baby-0.1.0+9.apk`
- Sync **create + edit + delete** to server shipped (PATCH/DELETE + pull reconciliation)
- Theme persist (schema v9), brand icon, INTERNET permission for release APK
- Demo screenshot tooling: `integration_test/demo_screenshots_test.dart` + `scripts/capture_demo_screenshots.sh`
- Emulator captures with Damian demo day → `~/Downloads/bloomdue-x-screenshots/`

### Landing + legal + beta signup (prod)
- Landing redesigned to match mobile v3 design + mobile care carousel
- **Privacy** + **Terms** live (`/privacy/`, `/terms/`) — EN, controller Globinary SRL, contact `contact@globinary.io`
- No cookie banner (Simple Analytics only)
- Inline **#join-beta** form → `POST /v1/beta-requests` → SMTP to `contact@globinary.io` + auto-reply
- Nginx redirect fix (no `:3000` bounce)
- Landing/backend redeployed; monorepo synced local ↔ GitHub ↔ VPS

### Docs / ideas
- **No past dates while expecting** logged → [`todos/DATE_PICKER_NO_PAST.md`](./todos/DATE_PICKER_NO_PAST.md)

## Next up (mobile-first)

1. **Small UX win:** no past dates on pregnancy due/appointment pickers → [`todos/DATE_PICKER_NO_PAST.md`](./todos/DATE_PICKER_NO_PAST.md)
2. **Pull-to-refresh sync** on Today (partner refresh)
3. **Account switching / local isolation** → [`todos/ACCOUNT_SWITCHING.md`](./todos/ACCOUNT_SWITCHING.md)
4. **Dogfood:** two-parent invite → join → edit/delete sync on real devices
5. **Store path** (when DUNS ready) → [`todos/STORE_RELEASE.md`](./todos/STORE_RELEASE.md)
6. **Content review** with neonat/pediatric clinicians → [`todos/CONTENT_REVIEW.md`](./todos/CONTENT_REVIEW.md)
7. FCM partner push — deferred until Firebase → [`todos/FCM_PARTNER_PUSH.md`](./todos/FCM_PARTNER_PUSH.md)

## Blockers / waiting on

- **DUNS** → Play Store / App Store org setup
- Android still **debug keystore** for sideload (OK for friends/family)
- FCM: no Firebase project yet
- Formal physician sign-off on 25 learn cards

## Deploy notes

| Target | How |
|---|---|
| Landing | `landing/deploy.sh` as `u_bloomdue@135.125.226.37` (or scp + `docker compose … landing`) |
| Backend | copy app files + `docker compose … backend` on VPS |
| GitHub push from laptop | no local key for `Gl0deanR/bloomdue-baby`; push via VPS deploy key or add a laptop key |

## Quick resume prompt

```
Read feature/SESSION.md, feature/PICKUP.md, and feature/todos/README.md in bloomdue_baby.
App is 0.1.0+9, Drift v9. Landing/legal/beta form are live on prod; monorepo is synced.
Continue mobile app feature work. Prefer small shippable UX/features. Update SESSION.md and related docs as we go.
```
