# Enfold

**Calm baby care, from bump to toddler.** A free, no-ads, open-source app for parents:
log feeds, diapers and sleep in two taps at 3am, share with your partner in real time,
read clinician-reviewed "is this normal?" cards, and export a summary for the pediatrician.

Website: [enfold.baby](https://enfold.baby) · Support: [enfold.baby/support](https://enfold.baby/support/) · Contact: support@enfold.baby

Enfold is built by a developer and a neonatologist who are also parents. It is free for
everyone, forever, with no ads and no data selling. The code is public so you can check
that for yourself. Donations on the support page keep the servers running and unlock
nothing in the app.

## Why open source

- **You can verify the privacy promise.** No ad SDKs, no trackers, no health-data sharing.
  Read `docs/privacy-and-safety.md`, then read the code.
- **Clinicians can check the content.** Every learn card carries its reviewer and date.
  Cards still marked "Pending physician review" say so in the app too.
- **Parents everywhere can help.** Translations first, then bugs, then features.

## What is in this repository

| Path | What |
|---|---|
| `lib/`, `android/`, `ios/` | The Flutter app for iOS and Android (offline-first, Drift SQLite, Riverpod, go_router) |
| `backend/` | The FastAPI + Postgres + Redis API behind `api.enfold.baby` (magic-code sign-in, family sync, partner push, Stripe supporters wall) |
| `landing/` | The static website at `enfold.baby` |
| `content/` | The learn cards, licensed separately (see below) |
| `docs/` | Product, privacy and platform notes |
| `feature/` | Working notes: status, roadmap, todos. Written for the team and for AI assistants; useful to see where things stand |

## Build it

```bash
cp .env.example .env
docker compose up --build          # API on :8282, landing on :8283, Postgres, Redis
flutter pub get
dart run build_runner build        # only after Drift schema changes
flutter test
flutter run                        # debug builds use the local API
```

Push notifications need your own Firebase project (`google-services.json`,
`GoogleService-Info.plist`); the app builds and runs without them. Details, backend tests
and the pull request rules are in [`CONTRIBUTING.md`](./CONTRIBUTING.md).

## Principles we will not trade

1. Simple by default. Three logs visible, depth optional.
2. No guilt. Missed logs get zero shame messages.
3. Reassure before charts. "You're doing fine" before statistics.
4. Triage, not diagnosis. "Watch for", "call if", "this is common". Never "you have".
5. Two taps at 3am, one hand, big targets, dark mode.
6. Offline first. Hospitals have bad signal.

Full reasoning: [`START_HERE.md`](./START_HERE.md) and [`ROADMAP.md`](./ROADMAP.md).

## License

- Code: [AGPL-3.0-or-later](./LICENSE), with an [app store covenant](./LICENSE-NOTES.md).
- Learn cards (`content/`): [CC BY-NC-ND 4.0](./content/LICENSE.md).
- Name, logo, icons and illustrations: not licensed, see [`TRADEMARK.md`](./TRADEMARK.md).
  You are welcome to fork; please rename and re-skin before you ship.

## Security

Found something? Email support@enfold.baby instead of opening an issue. See
[`SECURITY.md`](./SECURITY.md).

## Status

Version `1.0.1+27`. Live on the [App Store](https://apps.apple.com/us/app/enfold-baby-tracker/id6811765288); the Google Play release is in review as of September 2026.
Where we left off: [`feature/SESSION.md`](./feature/SESSION.md).
