# Bloomdue

Bloomdue is a free, no-ads parent app for tracking baby care after birth, with pregnancy tracking planned later.

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

Run Flutter checks:

```sh
cd mobile
flutter analyze
flutter test
```

Regenerate Drift code after database changes:

```sh
cd mobile
dart run build_runner build
```

## Current Scope

The implemented foundation includes email magic-code auth scaffolding, family/child records, care-event APIs, local offline care logging in Flutter, and Firebase/Microsoft Graph service boundaries. Firebase and Microsoft Graph credentials still need to be provided before production notification/email delivery is complete.
