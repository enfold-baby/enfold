# Enfold

Enfold is a free, no-ads parent app for tracking baby care after birth, with pregnancy tracking planned later.

## Structure

- `mobile/`: Flutter app for iOS and Android.
- `backend/`: FastAPI API with Postgres, Redis, and Alembic migrations.
- `docs/`: Product, feature, privacy, and safety planning notes.
- `docker-compose.yml`: Development stack.
- `docker-compose.prod.yml`: Production stack for an OVHcloud-style VPS deployment.

## Development

Create a local environment file:

```sh
cp .env.example .env
```

Run the backend stack:

```sh
docker compose up --build
```

Run Flutter checks from the repo root (`lib/` lives here, not under `mobile/`):

```sh
flutter analyze
flutter test
```

Regenerate Drift code after database changes:

```sh
dart run build_runner build
```

## Layout (this repo)

Flutter app lives at the repo root (`lib/`, `android/`, `ios/`), not under `mobile/`. Backend is `backend/`. Landing is `landing/`.

## Current Scope (2026-09)

**1.0.0+20**. 4-tab shell + Add FAB, magic-code auth (SES from `noreply@enfold.baby`; Graph fallback), family/child records, care-event APIs with edit/delete sync, FCM partner push on Android, landing + `/support/`. Product name **Enfold**. VPS linux user, compose container names, and Postgres role stay **bloomdue**.
