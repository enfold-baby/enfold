# Pickup points — resume a session

**Every new session:** read [`SESSION.md`](./SESSION.md) first (latest handoff).  
**Every end of session:** update `SESSION.md` per [`MAINTAIN.md`](./MAINTAIN.md).

Copy one of these into a fresh chat:

---

## General resume (default — mobile features)

```
Read feature/SESSION.md, feature/PICKUP.md, and feature/todos/README.md in bloomdue_baby.
Flutter app at 0.1.0+9, Drift schema v9.
API: https://api.bloomdue.baby · Landing: https://bloomdue.baby (legal + beta form live).
Monorepo main is synced local/GitHub/prod.
Continue mobile feature work. Update feature/SESSION.md and related docs as we ship.
```

---

## No past dates while expecting (small UX)

```
Read feature/todos/DATE_PICKER_NO_PAST.md.
While still expecting, clamp due-date and pregnancy appointment pickers to today+ (local TZ).
Do not change care-log backfill (past feeds/sleep still allowed).
```

---

## Pull-to-refresh / partner sync polish

```
On Today (and maybe Logs), add pull-to-refresh that runs syncIfSignedIn / pull recent care events.
Read lib/services/sync/sync_service.dart and today screen providers.
```

---

## Account switching

```
Read feature/todos/ACCOUNT_SWITCHING.md.
Before public beta: isolate local Drift data when a different email signs in (upload-or-fresh prompt).
```

---

## Store / beta release

```
Read feature/todos/STORE_RELEASE.md and BRANDING.md build section.
Privacy/terms URLs are live on bloomdue.baby. Still need signed Android keystore + iOS TestFlight when DUNS/accounts ready.
```

---

## Content / medical review

```
Read feature/todos/CONTENT_REVIEW.md.
25 learn cards are in content/cards/ — physician review workflow with neonat/pediatric collaborators.
```

---

## FCM partner push (deferred)

```
Read feature/todos/FCM_PARTNER_PUSH.md — scaffold is done, Firebase project not created yet.
Only pick this up when ready to create Firebase + wire Flutter + VPS.
```

---

## Landing / API only (rare)

```
Landing source: landing/public/. Deploy via landing/deploy.sh as u_bloomdue@135.125.226.37.
Backend: backend/app/ on VPS docker compose. Beta requests: POST /v1/beta-requests.
Do not touch due.bloomdue.baby.
```

---

## Current stack (for agents)

| Layer | Detail |
|---|---|
| **Flutter** | Riverpod, go_router, Drift SQLite, offline-first |
| **Version** | `0.1.0+9` · Drift **v9** |
| **API** | `lib/services/api/bloomdue_api_client.dart` → `https://api.bloomdue.baby` |
| **Sync** | create + **edit + delete** + pull (`sync_service.dart`) |
| **Auth** | Magic code email → JWT in secure storage |
| **Partner** | Family invite/join, attribution, gentle nudge, FCM prep (no-op) |
| **Landing** | v3 design, legal pages, join-beta form + SMTP |
| **Deploy** | `landing/deploy.sh`, `deploy/api-email/`, `deploy/api-partner/` |
| **VPS** | `u_bloomdue@135.125.226.37` → `/home/u_bloomdue/bloomdue-platform` |

## Run locally

```bash
cd bloomdue_baby
flutter pub get
dart run build_runner build    # after Drift schema changes
flutter test
flutter run
# emulator screenshots (optional):
# ./scripts/capture_demo_screenshots.sh
```

## Build beta

```bash
./scripts/build_beta.sh
# or: flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```
