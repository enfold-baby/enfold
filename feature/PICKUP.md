# Pickup points: resume a session

**Every new session:** read [`SESSION.md`](./SESSION.md) first (latest handoff).  
**Every end of session:** update markdown per [`MAINTAIN.md`](./MAINTAIN.md). Keep docs in lockstep as we ship.

Copy one of these into a fresh chat:

---

## General resume (default)

```
Read feature/SESSION.md, feature/PICKUP.md, feature/todos/README.md and ~/Desktop/LAUNCH-CHECKLIST.md (pickup at the top).
Enfold 1.0.1+25, Drift schema v14. Play: 1.0.0+22 in review, 1.0.1+24 on internal testing. App Store: 1.0.1 (24) in review.
Debug API → http://10.0.2.2:8282 (Android emulator); release → https://api.enfold.baby.
Local docker: docker compose up -d. Contact: support@enfold.baby. Prod VPS is updated by copying files (private ops notes, ~/Documents/enfold/ops/).
Keep markdown current as we ship. No em dashes. Logins, legal agreements, payments and public posts are Raul's keyboard.
```

---

## Stripe supporters galaxy: sandbox end-to-end test

```
Enfold: test the Stripe supporters galaxy end to end in sandbox mode, then fix what breaks.
Read first: docs/supporters-wall.md, ~/Desktop/LAUNCH-CHECKLIST.md pickup, landing/public/support/index.html, landing/public/galaxy/, backend/app/routers/support.py and the Stripe webhook route.
Facts: ?stripe=test on https://enfold.baby/support/ or /galaxy/ switches to 4 sandbox Payment Links (donate.stripe.com/test_..., tiers tea, nest, moon, wish). Webhook checkout.session.completed -> POST https://api.enfold.baby/v1/stripe/webhook (sandbox secret STRIPE_WEBHOOK_SECRET_TEST in the VPS .env). Wall: GET https://api.enfold.baby/v1/support/wall?mode=test (1 test supporter so far: GLOBINARY, nest, 12 EUR, 2026-09-12). Icons: /v1/support/icon/<id>.
Test: pay each tier with 4242 4242 4242 4242 (type keystrokes; card fields reject programmatic fill). Cover: show my moon Yes with a link, Yes without a link, No (must not appear on the wall), with company and tax ID. Then check the Stripe sandbox webhook deliveries are 2xx, the wall JSON count, total and tiers update, /support/?stripe=test and /galaxy/?stripe=test show the new moons (desktop and 390px, light and dark), ?mode=live stays empty, and the payment's Checkout summary shows name, company, address and tax ID.
Rules: sandbox only, never live links or real cards. Stripe dashboard login is Raul's keyboard. No em dashes. The prod VPS is updated by copying files, not git pull (private ops notes in ~/Documents/enfold/ops/, landing/deploy.sh needs SSHPASS). Write findings back to the checklist and docs/supporters-wall.md; commit and push fixes.
```

---

## SES mail

```
Read feature/todos/SES_MAIL.md.
SES is live from noreply@enfold.baby (eu-central-1). Graph is the fallback. SMTP 535s.
Do not print secrets. VPS user/paths stay bloomdue.
```

---

## Stripe help-page moons

```
Read feature/todos/STRIPE_SUPPORT.md.
Hang Stripe Payment Link URLs on https://enfold.baby/support/ plant-a-moon buttons.
No ads in the app.
```

---

## Play listing

```
Read feature/todos/STORE_RELEASE.md.
Upload keystore + AAB path is ready. Feature graphic exists. Need phone screenshots, Data safety, Play Console upload.
Do not invent Play/App Store URLs.
```

---

## Romanian i18n (later)

```
Read feature/todos/I18N_RO.md.
Device RO → RO; else EN; Settings can force RO. Repo stays private. Do not start extracting strings unless asked.
```

---

## FCM / partner push

```
Read feature/todos/FCM_PARTNER_PUSH.md.
Android + API are live. iOS needs an APNs auth key in Firebase. Dogfood: two parents, toggle When partner logs.
```

---

## Multi-child

```
Read feature/todos/MULTI_CHILD.md.
Server already allows many children; the app still assumes one local baby.
```

---

## Content / medical review

```
Read feature/todos/CONTENT_REVIEW.md.
25 learn cards in content/cards/: physician review still pending.
```

---

## Landing / API

```
Landing: landing/public/. Deploy with landing/deploy.sh (host from the private ops env).
Help page: /support/ (`/help/` redirects). Backend: backend/app/ on VPS docker compose.
Due countdown: due.enfold.baby. Do not rename VPS linux user or Postgres role bloomdue.
```

---

## Current stack (for agents)

| Layer | Detail |
|---|---|
| **Flutter** | Riverpod, go_router, Drift SQLite, offline-first |
| **Version** | `1.0.0+20` · Drift **v13** |
| **Shell** | Today / Logs / Learn / Settings + docked Add FAB |
| **API** | debug local docker / release `https://api.enfold.baby` |
| **Client** | `EnfoldApiClient` (`lib/services/api/enfold_api_client.dart`) |
| **Sync** | create + edit + delete + pull + ~45s periodic while open |
| **Auth** | Magic code → JWT; mail via SES (Graph fallback) |
| **Partner** | Invite/join/leave, attribution, nudge, FCM when toggle on |
| **Landing** | Legal, launch-notify `#notify`, `/open`, `/roadmap`, `/support/` |
| **VPS** | host, user and directory in `~/Documents/enfold/ops/ops.env` (private) |

## Run locally

```bash
docker compose up -d --build   # API :8282 · landing :8283 · Caddy :8280
flutter pub get
dart run build_runner build    # after Drift schema changes
flutter test
flutter run -d emulator-5554   # debug → 10.0.2.2:8282
# force prod API in debug: --dart-define=API_BASE_URL=https://api.enfold.baby
```

## Build beta / Play

```bash
./scripts/build_beta.sh
# APK: build/app/outputs/flutter-apk/app-release.apk
# AAB: build/app/outputs/bundle/release/app-release.aab
# Sideload copies often go to Desktop as enfold-1.0.0-N.apk
```
