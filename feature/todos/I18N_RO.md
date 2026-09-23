# Todo: Romanian

> **Priority:** P2 · **Status:** UI done, native check pending  
> **Shipped in:** `1.0.2+28` (built locally 2026-09-22, not uploaded)  
> **Files:** `l10n.yaml`, `lib/l10n/app_en.arb`, `lib/l10n/app_ro.arb` (603 keys each)

## What is done

- `flutter gen-l10n` set up. `generate: true` in `pubspec.yaml`, output class `AppL10n` in
  `lib/l10n/generated/` (gitignored, rebuilt by `flutter pub get`).
- Every UI string extracted: shell, Today, Logs hub and the six log forms and lists,
  Growth and milestones, Pregnancy, Onboarding, all of Settings, the Learn chrome,
  local notifications and the visit PDF.
- Romanian draft for all 603 keys, with diacritics and ICU plurals (`few` / `other` for
  Romanian's 2-to-19 rule).
- Device language decides: Romanian device → Romanian, anything else → English.
- **Settings → Language**: Device / English / Romanian, per device, stored in
  `app_settings.language_tag` (Drift **v16**, null means follow the device).
- Strings outside the widget tree (notifications, sync errors) go through
  `appL10nProvider`, which resolves the override first and the device language second.

## UX (locked, unchanged)

- Per **device**, not per family
- **RO only** as the first locale besides English
- No mandatory first-launch language wall

## Stays English on purpose

- **Learn card content** (25 cards): needs a clinician to review a medical translation.
  Only the Learn tab's own chrome is translated.
- **Stored or transmitted values**: caregiver roles (`Mom`, `Dad`, …) inside the server
  `display_name`, medication category values, medication preset ids, milestone keys.
  Their labels are translated; the values never move.
- HTTP headers, debug log lines, the brand name.

## Screenshot pass, 2026-09-22

Run on two Android 16 (API 36) emulators, `enfold_phone_api36` (medium phone, 1080x2400)
and `enfold_tablet_api36` (medium tablet, 2560x1600), with the app locale forced by
`adb shell cmd locale set-app-locales baby.enfold.app --locales ro`. 24 screenshots in
`~/Desktop/enfold-ro-screenshots/`.

Verified working: device-language default, the Settings override switching language live
both ways, diacritics, ICU plurals ("1 masă" vs "scutece"), the bottom tabs, the Settings
segmented buttons, the log forms, Growth and milestones, the Learn chrome with English
card content, phone and tablet, light and dark. Edge-to-edge also confirmed: content draws
behind both system bars and the bar icons flip with the theme.

Three bugs found and fixed (commit "three fixes the emulator screenshots caught"):

1. **Dates were English.** `ClockFormat` defaulted its `locale` to `en_US`, so a Romanian
   UI still read "Tue, Sep 22 · 3:18 PM". The default is null now, `DateFormat` reads
   `Intl.defaultLocale`, and the app sets that from the resolved locale.
2. **Quick action tiles truncated.** "Vezi notările · ține apăs…" in a one-line label on a
   half-width tile. Shortened to "Vezi · ține apăsat".
3. **The log tile sync state was never translated** ("on device").

**Lesson for the next language:** a one-line `Text` with `maxLines: 1` truncates with an
ellipsis rather than raising a RenderFlex overflow, so the 320px overflow test cannot see
it. One-line labels on narrow tiles need an eye on a real screen.

## Phone round 1, Raul, 23 September

Sideloaded release APK on his phone. Language, edge-to-edge, the overnight sleep fix,
notifications and the PDF all passed. Two bugs found, both fixed:

- Pagination behaved as if it did not exist (see `paginated_column.dart`); not an i18n bug
- "Greutate" wrapped inside the growth chart's segmented button, fixed with `SegmentLabel`

Wording feedback is coming as he and the family use it in Romanian.

## Still to do

- [ ] **Native check by Raul and Oana.** Read the Romanian on a phone, fix what sounds
      stiff. The draft is one pass by Claude, not a native edit.
- [ ] **Decide the clock default for Romanian.** Romania uses the 24-hour clock almost
      everywhere, but the app defaults to 12-hour, so the screenshots read "3:20 p.m.".
      Settings already offers both; the question is whether the default should follow the
      locale. Raul's call, since it would move for existing users too.
- [ ] Milestone names: worth Oana's eye alongside the learn cards.
- [ ] Learn cards in Romanian, once a clinician can review them.
- [ ] Website `enfold.baby/ro/` + `hreflang` (marketing + legal, not mobile onboarding).
- [ ] Weblate Libre or POEditor application, now that ARB files exist in a public repo.

## How to add a string

1. Add the key to `lib/l10n/app_en.arb` (with an `@key` block if it takes placeholders).
2. Add the same key to `lib/l10n/app_ro.arb`.
3. `flutter gen-l10n` (or just `flutter pub get`), then use `AppL10n.of(context).myKey`.
4. `flutter test`.

Both files must have the same keys: gen-l10n warns about untranslated messages, and
`flutter analyze` fails on a key that only exists in one of them.
