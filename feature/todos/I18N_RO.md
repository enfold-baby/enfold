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

## Still to do

- [ ] **Native check by Raul and Oana.** Read the Romanian on a phone, fix what sounds
      stiff. The draft is one pass by Claude, not a native edit.
- [ ] Screenshot the Romanian UI on a phone and a tablet, light and dark. Romanian is
      longer than English, so check the bottom tabs, the segmented buttons in Settings
      and the log form buttons for overflow. No emulator was available in the session
      that wrote this.
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
