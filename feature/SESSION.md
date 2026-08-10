# Last session

**Date:** 2026-08-10  
**Version:** `0.1.0+9` · Drift schema **v10**  
**API prod:** `https://api.bloomdue.baby` · **API local:** `http://127.0.0.1:8282` (emulator `http://10.0.2.2:8282`)  
**Contact:** `contact@globinary.io` (hello@bloomdue.baby retired)
**Mail:** Microsoft Graph as `contact@globinary.io` (same app as globinary.io); beta → `contact@globinary.io`; no Sent folder  

## Done this session

- Contact email + Graph mail + local full stack (API + landing docker)
- **No past dates while expecting** shipped  
- Pull-to-refresh on Today · open startup `/open` + `/roadmap`  
- **AD-style in-app APK update** → `todos/APP_VERSION_UPDATE.md`  
- **Account switching isolation** (schema v10) → `todos/ACCOUNT_SWITCHING.md`  
  - Upload local vs start fresh dialog on different account  
  - Sign out & clear device data  
  - Full-history pull after start fresh  

## Next up (mobile)

1. Dogfood partner invite on emulator + local API  
2. Store path when DUNS ready  
3. FCM partner push later  

### Ship beta APK for update testing (local)

```bash
# bump pubspec build +N first (e.g. 0.1.0+10), then:
flutter build apk --release
APP_VERSION_ADMIN_TOKEN=dev-local-apk-admin \
  ./scripts/publish_beta_apk.sh build/app/outputs/flutter-apk/app-release.apk 0.1.0 10
# Install an older build on device; reopen → Update dialog
```

## Local dev workflow

```bash
# Full local stack
docker compose up -d --build
curl http://127.0.0.1:8282/health          # API direct
open http://127.0.0.1:8283/                # landing direct
open http://127.0.0.1:8280/                # landing via Caddy (+ /api)

# App (debug → local API automatically)
flutter run -d emulator-5554

# Force prod API even in debug:
# flutter run --dart-define=API_BASE_URL=https://api.bloomdue.baby
```

| Port | Service |
|------|---------|
| **8280** | Caddy → landing + `/api/*` → backend |
| **8282** | Backend (direct) |
| **8283** | Landing nginx (direct, live-mounted `landing/public`) |
| 8285 / 8286 | Postgres / Redis |

Sign-in magic codes: `docker compose logs -f backend`

## Quick resume prompt

```
Read feature/SESSION.md, feature/PICKUP.md, feature/todos/README.md in bloomdue_baby.
Local docker API is the default in debug (10.0.2.2:8282). Contact is contact@globinary.io.
Continue mobile features. Commit local no coauthor; user pushes to GitHub.
```
