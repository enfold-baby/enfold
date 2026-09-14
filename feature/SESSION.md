# Last session

**Date:** 2026-09-14  
**Version:** `1.0.1+25` · Drift schema **v14** · 192 tests passing  
**API:** `https://api.enfold.baby` · local `http://127.0.0.1:8282` (emulator `http://10.0.2.2:8282`); iOS simulator debug builds reach prod only with `--dart-define=API_BASE_URL=https://api.enfold.baby`  
**Contact:** `support@enfold.baby`  
**Display:** Enfold (App Store name "Enfold: Baby Tracker") · bundle `baby.enfold.app`

## Done recently (2026-09-13 and 14)

- **Time awake** on Today ("Awake for 1h 20m, since 14:05") with a Settings switch, on by default. Drift **v14**.
- **Sync:** first sign-in on an install pulls full history; a placeholder "Baby" takes the server child's name and birth date.
- **Fixes:** onboarding hero no longer a LayoutBuilder under IntrinsicHeight (blank screen in debug, clipped step on small phones); periodic sync failures stay quiet.
- **iOS:** App ID, APNs key in Firebase, signing team, `ios/release.sh` (see memory), App Store Connect record, privacy labels, age rating 13+, medical device declaration (No), screenshots in `assets/brand/store/screenshots/ios/`. **1.0.1 (24) submitted for review.** TestFlight internal group "Raul's devices" (Raul, Oana), builds 23 to 25. iOS minimum 15.0.
- **Android:** 1.0.1+24 on Play internal testing (production 1.0.0+22 still in review). Desktop sideload `enfold-1.0.1-25.apk`.

## Next up

1. Test the Stripe supporters galaxy end to end in sandbox (prompt in `feature/PICKUP.md`)
2. When Play approves 1.0.0+22, promote internal 1.0.1+24 to production
3. When the App Store approves 1.0.1 (24): Play and App Store badges on the site, launch posts (checklist section 8)
4. Optional: admin switch to hide a supporter; Romanian (`feature/todos/I18N_RO.md`)

## Blockers / waiting on

- Google Play review (1.0.0+22)
- App Store review (1.0.1 build 24)

## Quick resume

```
Read feature/SESSION.md, feature/PICKUP.md, and feature/todos/README.md.
Enfold 1.0.0+20, Drift v13, API https://api.enfold.baby.
Keep markdown current as we ship (feature/MAINTAIN.md).
```
