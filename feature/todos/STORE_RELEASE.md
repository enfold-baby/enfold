# Store release — Play

> **Status (2026-09-10):** App created in Play Console (id 4975658902210008908), all App content declarations done except the IARC content rating (Raul starts it), store listing saved with icon, feature graphic and 4 screenshots, release `1.0.0+20` published to internal testing. Reviewer account: `~/Documents/enfold/play-reviewer-account.md`. Next: Raul installs from the internal test link, content rating, then production. See `~/Desktop/LAUNCH-CHECKLIST.md`.

## Android Play checklist

| Item | Status |
|---|---|
| Application id | `baby.enfold.app` |
| Privacy policy | https://enfold.baby/privacy/ |
| Terms | https://enfold.baby/terms/ |
| In-app Privacy / Terms | Settings → Legal |
| In-app account deletion | Settings → Delete my account |
| Sideload installer permission | Removed |
| Upload keystore | `android/upload-keystore.jks` (gitignored) + `android/key.properties` |
| Play App Signing | Enable in Play Console — let Google generate the **app signing** key. Our JKS is the **upload** key only. |
| Feature graphic | `assets/brand/store/play-feature-graphic.jpg` (1024×500) |
| Phone screenshots | `assets/brand/store/screenshots/` (4 × 1080×1920, Pixel 8 emulator, reviewer family data), uploaded 2026-09-10. Regenerate after UI changes. |

## Build the Play AAB

```bash
flutter build appbundle --release
# output: build/app/outputs/bundle/release/app-release.aab
```

First Play Console upload:

1. Create the app with package `baby.enfold.app`.
2. Turn on **Play App Signing** and let Google generate the app signing key.
3. Upload the AAB signed with the local **upload** keystore.
4. Fill Data safety, content rating, privacy URL, screenshots.

Back up `android/upload-keystore.jks` and `android/key.properties`. Losing the upload key blocks later updates.

## iOS App Store

Done. 1.0.1 (27) approved and live on 2026-09-2x at https://apps.apple.com/us/app/enfold-baby-tracker/id6811765288 after two rounds: Guideline 2.1 information request (screen recording, answered 2026-09-15) and Guideline 1.4.1 (medical content needs citations; fixed with a Sources section on every learn card, build 27, 2026-09-17). Release flow: `./ios/release.sh --upload`, then swap the build on the version page and Resubmit; details in the iOS memory note and `~/Desktop/LAUNCH-CHECKLIST.md` 9b.
