# Contributing to Enfold

Thanks for helping parents get calmer nights. Enfold is built by a very small team (a
developer and a neonatologist) in the hours between our own kids' feeds, so we value
focused, well-described changes over big rewrites.

## What helps most

- **Translations.** English and Romanian ship today, as ARB files in `lib/l10n/`. A native
  fix to the Romanian, or a new language, is very welcome; see "Translating" in the
  [README](./README.md#translating).
- **Bugs with steps.** Device, OS version, app version (Settings shows it), what you tapped,
  what happened.
- **Accessibility and one-handed 3am use.** Big targets, high contrast, dark mode.
- **Backend hardening and tests.**

## What we will say no to

- Ads, trackers, analytics SDKs, or any data sharing. Read `docs/privacy-and-safety.md`.
- Features that add guilt: streaks, missed-log nudges, prediction scores.
- Medical content changes without clinician review. Open an issue instead; the review
  workflow is in `feature/todos/CONTENT_REVIEW.md`.
- Anything that diagnoses. Enfold says "watch for", "call if", "this is common". Never
  "you have".

## Development setup

```bash
cp .env.example .env
docker compose up --build          # API on :8282, landing on :8283
flutter pub get
dart run build_runner build        # after Drift schema changes
flutter test
flutter run                        # debug builds talk to the local API
```

Push notifications need your own Firebase project: drop `google-services.json` into
`android/app/` and `GoogleService-Info.plist` into `ios/Runner/`. Both are gitignored and
the app builds and runs without them; only partner push is disabled.

Backend tests need Python 3.12:

```bash
cd backend
python3.12 -m venv .venv && .venv/bin/pip install -r requirements.txt pytest pytest-asyncio
.venv/bin/python -m pytest
```

## Pull requests

- One change per PR, with a sentence on why.
- `flutter analyze`, `flutter test` and `pytest` pass. CI runs them too.
- Sign off every commit with `git commit -s`. This adds a `Signed-off-by` line and means
  you agree to the [Developer Certificate of Origin](https://developercertificate.org/):
  you wrote the change or have the right to submit it under this project's license.
- By contributing you also agree to the app store covenant in `LICENSE-NOTES.md`, so the
  project can keep shipping to Google Play and the App Store.
- No CLA. You keep your copyright.

## Code style

Dart follows `analysis_options.yaml`. Python follows the existing modules: type hints,
`async` everywhere the framework is async, small routers, services for anything that talks
to Redis, mail or Stripe. Comments say why, not what.

## Security issues

Do not open a public issue. See `SECURITY.md`.
