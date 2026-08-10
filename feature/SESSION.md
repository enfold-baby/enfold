# Last session

**Date:** 2026-08-10  
**Version:** `0.1.0+9` · Drift schema **v9**  
**API prod:** `https://api.bloomdue.baby` · **API local:** `http://127.0.0.1:8282` (emulator `http://10.0.2.2:8282`)  
**Contact:** `contact@globinary.io` (hello@bloomdue.baby retired)
**Mail:** Microsoft Graph as `contact@globinary.io` (same app as globinary.io); beta → `contact@globinary.io`; no Sent folder  

## Done this session

- Contact email + Graph mail + local full stack (API + landing docker)
- **No past dates while expecting** shipped  
- Dev / GitHub / prod monorepo synced @ `02a48a3`  
- Todo logged: **AD-style in-app APK update** → `todos/APP_VERSION_UPDATE.md`

## Next up (mobile)

1. **Pull-to-refresh sync** on Today (quick win)  
2. **In-app APK version update** (AD pattern) → [`todos/APP_VERSION_UPDATE.md`](./todos/APP_VERSION_UPDATE.md)  
3. Account switching isolation → [`todos/ACCOUNT_SWITCHING.md`](./todos/ACCOUNT_SWITCHING.md)  
4. Dogfood on emulator + local API  
5. Store path when DUNS ready · FCM later

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
