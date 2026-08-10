# Last session

**Date:** 2026-08-10  
**Version:** `0.1.0+9` · Drift schema **v9**  
**API prod:** `https://api.bloomdue.baby` · **API local:** `http://127.0.0.1:8282` (emulator `http://10.0.2.2:8282`)  
**Contact:** `contact@globinary.io` (hello@bloomdue.baby retired)

## Done this session

- Contact email switched to **contact@globinary.io** (landing, legal, API, docs) + prod deploy
- **Local docker** stack: `docker compose up -d` (postgres, redis, backend :8282, **landing :8283**, caddy :8280 → landing + `/api`)
- **Debug API routing:** `ApiConfig` → Android emulator `10.0.2.2:8282`, release stays prod
- Android **debug cleartext** HTTP for local API
- **No past dates while expecting** — due date + appointment pickers; unit tests
- Magic codes: `DEV_MAGIC_CODE_LOG=true` prints to backend logs locally

## Next up (mobile)

1. Pull-to-refresh sync on Today  
2. Account switching isolation → `todos/ACCOUNT_SWITCHING.md`  
3. Dogfood partner invite on emulator + local API  
4. Store path when DUNS ready  

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
