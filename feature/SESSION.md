# Last session

**Date:** 2026-09-22 (app dev session, after the launch sessions on 21 and 22)  
**Version:** `1.0.2+28` · Drift schema **v16** · 220 tests passing  
**API:** `https://api.enfold.baby` · local `http://127.0.0.1:8282` (emulator `http://10.0.2.2:8282`)  
**Contact:** `support@enfold.baby`  
**Display:** Enfold (App Store name "Enfold: Baby Tracker") · bundle `baby.enfold.app`  
**Code:** public, https://github.com/enfold-baby/enfold (AGPL-3.0, see `LICENSE-NOTES.md`)

## Done this session

- **Build 1.0.2+28 prepared for both stores.** pubspec bumped from 1.0.1+27; it carries the
  overnight sleep fix that has been on main since 18 Sep. **Nothing uploaded or submitted.**
  `flutter build appbundle --release` succeeds and the bundle reads 1.0.2.
- **Android 15 edge-to-edge** (`lib/core/theme/system_ui.dart`): the app opts in explicitly
  with `SystemUiMode.edgeToEdge`, keeps both system bars transparent and flips their icons
  with the theme. Contrast enforcement stays on so 3-button navigation is readable over
  content. No `windowOptOutEdgeToEdgeEnforcement` anywhere. Bar insets were already covered:
  pushed screens wrap their body in `SafeArea` and the shell's `BottomAppBar` pads itself.
- **Romanian UI, whole pass.** `flutter gen-l10n` with `lib/l10n/app_en.arb` and `app_ro.arb`,
  **603 keys each, all translated**. Every screen converted: shell, Today, Logs hub, the six
  log forms and lists, Growth and milestones, Pregnancy, Onboarding, all of Settings, the
  Learn chrome, local notifications and the visit PDF.
  - Device language decides; **Settings → Language** forces Device / English / Romanian, per
    device, stored in `app_settings.language_tag` (**Drift v16**).
  - Strings outside the widget tree (notifications, sync errors) resolve through a new
    `appL10nProvider`.
  - Stored values stay English on purpose: caregiver roles inside `display_name`, medication
    category values and preset ids, milestone keys. Only their labels are translated.
  - **Learn card content stays English** until a clinician reviews a medical translation.
- Tests: 208 → 220. New: edge-to-edge overlay style, locale override parsing, the
  `language_tag` column, and a Romanian rendering test. Widget tests now pump through a
  `localizedApp` helper that carries the delegates.

## Where things stand

- **App Store: LIVE** on 1.0.1 (27), https://apps.apple.com/us/app/enfold-baby-tracker/id6811765288
- **Google Play: still in review.** Production 1.0.0+22 submitted 2026-09-12, no rejection,
  no policy flag. Support ticket filed 2026-09-22 (reply by email within 15 days). When 22
  goes live, promote **1.0.2+28 from main**, not internal 24.
- **Launch is done for now:** Product Hunt Wed 2026-09-23, X, dev.to. Reddit skipped;
  Peerlist, HN, Indie Hackers, LinkedIn parked with copy in `feature/todos/LAUNCH_COPY.md`.
- **FormKiosk iOS 1.0** (separate app, same Apple account) resubmitted 2026-09-22.

## Next up

1. **Native check on the Romanian.** Raul and Oana read it on a phone and fix what sounds
   stiff; it is one pass by Claude, not a native edit. Details in `feature/todos/I18N_RO.md`.
2. **Screenshot the Romanian UI** on a phone and a tablet, light and dark. Romanian runs
   longer than English, so check the bottom tabs, the Settings segmented buttons and the log
   form buttons for overflow. No emulator was available this session.
3. **Google Play:** wait for the ticket reply or approval, then upload 1.0.2+28 and put the
   Play badge on the site.
4. Oana's learn card sign-offs into the JSON as they arrive; the 13 milestone names are
   worth the same look.
5. Later: `enfold.baby/ro/`, Weblate or POEditor now that ARB files are public, original art
   for the two Adobe-derived illustrations, Riverpod 3 / go_router 18.

## Blockers / waiting on

- Google Play review (1.0.0+22), support ticket filed 2026-09-22
- FormKiosk iOS review (resubmitted 2026-09-22)
- Oana's card review
- A device or emulator for the Romanian screenshots
- Raul: rotate the VPS password (pasted in a chat on 2026-09-17; key auth already works)

## Quick resume

```
Read feature/SESSION.md, feature/PICKUP.md, feature/todos/README.md and ~/Desktop/LAUNCH-CHECKLIST.md (pickup at the top).
Enfold 1.0.2+28, Drift v16, 220 tests. App Store live on 1.0.1; Play still in review (ticket filed 2026-09-22); 28 is built but not uploaded.
Romanian UI is in (603 ARB keys, Settings > Language, learn cards stay English). Next: native check and screenshots for overflow.
Keep markdown current as we ship (feature/MAINTAIN.md). No em dashes. Public posts, logins and payments are Raul's keyboard.
```
