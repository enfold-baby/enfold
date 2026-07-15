# BloomDue Baby

Calm baby care from bump to toddler — Flutter app for [bloomdue.baby](https://bloomdue.baby).

| | |
|---|---|
| **Version** | `0.1.0+4` (private beta) |
| **Bundle ID** | `baby.bloomdue.app` |
| **API** | `https://api.bloomdue.baby` |
| **Tests** | 84 passing |

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

## Deploy

| Target | Script |
|---|---|
| Landing page | `landing/deploy.sh` |
| API email (SMTP) | `deploy/api-email/deploy_smtp.sh` |
| API partner (FCM attrs) | `deploy/api-partner/deploy_partner.sh` |