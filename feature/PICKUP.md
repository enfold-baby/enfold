# Pickup points — resume a session

**Every new session:** read [`SESSION.md`](./SESSION.md) first (latest handoff).  
**Every end of session:** update `SESSION.md` per [`MAINTAIN.md`](./MAINTAIN.md).

Copy one of these into a fresh chat:

---

## General resume (default)

```
Read feature/SESSION.md, feature/PICKUP.md, and feature/todos/README.md in bloomdue_baby.
Flutter app at 0.1.0+4, Drift schema v8, 84 tests passing.
API: https://api.bloomdue.baby (VPS FastAPI + Postgres).
Pick up where we left off. Update feature/SESSION.md and related docs as we ship work.
```

---

## Finish FCM partner push

```
Let's finish FCM partner push.
Read feature/todos/FCM_PARTNER_PUSH.md — scaffold is done, Firebase project not created yet.
We'll set up Firebase together, then wire Flutter + VPS.
```

---

## Sync improvements

```
Read feature/todos/SYNC_UPDATES.md.
Care log create sync works; delete/edit are local-only.
Implement server delete + update sync for partner consistency.
```

---

## Store / beta release

```
Read feature/todos/STORE_RELEASE.md and BRANDING.md build section.
Prepare signed Android AAB and/or iOS TestFlight for private beta.
```

---

## Content / medical review

```
Read feature/todos/CONTENT_REVIEW.md.
25 learn cards are in content/cards/ — need physician review workflow.
```

---

## Current stack (for agents)

| Layer | Detail |
|---|---|
| **Flutter** | Riverpod, go_router, Drift SQLite, offline-first |
| **API** | `lib/services/api/bloomdue_api_client.dart` |
| **Sync** | `lib/services/sync/sync_service.dart` — push pending + pull 2-day lookback |
| **Auth** | Magic code email → JWT in secure storage |
| **Partner** | Family invite/join, attribution, gentle nudge, FCM prep (no-op) |
| **Deploy** | `deploy/api-partner/`, `deploy/api-email/`, `landing/deploy.sh` |
| **VPS** | `ubuntu@135.125.226.37` → `/home/u_bloomdue/bloomdue-platform` |

## Run locally

```bash
cd bloomdue_baby
flutter pub get
dart run build_runner build    # after Drift schema changes
flutter test
flutter run
```

## Build beta

```bash
./scripts/build_beta.sh
```