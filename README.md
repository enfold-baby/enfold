# Enfold.baby

Calm baby care from bump to toddler — Flutter app for [enfold.baby](https://enfold.baby).

| | |
|---|---|
| **Version** | `1.0.0+20` |
| **Bundle ID** | `baby.enfold.app` |
| **API** | `https://api.enfold.baby` |
| **Landing** | `https://enfold.baby` (legal, launch-notify, `/support/`) |
| **Drift** | schema v13 |

## Docs

| Start here | |
|---|---|
| New to the project | [`START_HERE.md`](./START_HERE.md) |
| **Resume (where we left off)** | [`feature/SESSION.md`](./feature/SESSION.md) |
| Session prompts | [`feature/PICKUP.md`](./feature/PICKUP.md) |
| Keep docs current | [`feature/MAINTAIN.md`](./feature/MAINTAIN.md) |
| What's built | [`feature/features/STATUS.md`](./feature/features/STATUS.md) |
| What to do next | [`feature/todos/README.md`](./feature/todos/README.md) |
| Version roadmap | [`feature/roadmaps/VERSION.md`](./feature/roadmaps/VERSION.md) |
| Brand & build | [`BRANDING.md`](./BRANDING.md) |

## Develop

```bash
flutter pub get
dart run build_runner build   # after Drift schema changes
flutter test
flutter run
```

## Build beta

```bash
./scripts/build_beta.sh
```

## Repo layout

| Path | What |
|---|---|
| `lib/`, `android/`, `ios/` | Flutter mobile app (this is the app) |
| `landing/` | Marketing site for https://enfold.baby (prod snapshot) |
| `backend/` | FastAPI for https://api.enfold.baby (prod snapshot) |
| `docker-compose.prod.yml` | VPS stack: landing + API + Postgres + Redis |
| `docs/PLATFORM_README.md` | Platform deploy notes from the VPS repo |

## Deploy

| Target | Script |
|---|---|
| Landing page | `landing/deploy.sh` as `u_bloomdue@135.125.226.37` |
| API email | SES live from `noreply@enfold.baby`; Graph fallback → `feature/todos/SES_MAIL.md` |
| API partner / FCM | Wired; see `feature/todos/FCM_PARTNER_PUSH.md` |

Never commit `.env`, `google-services.json`, `GoogleService-Info.plist`, or `backend/secrets/*.json`. Use `.env.example` / `.env.prod.example` only.

**Where we left off:** [`feature/SESSION.md`](./feature/SESSION.md). **Keep docs current as we ship.**