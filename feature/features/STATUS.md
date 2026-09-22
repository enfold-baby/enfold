# Feature status — what's built

> Snapshot as of **2026-09-22**. Source of truth is the code; update this when shipping.  
> App: **`1.0.2+28`** (not uploaded) · Drift **v16** · App Store live on 1.0.1 · Play pending · API + landing + support live · code public (AGPL-3.0).

## App shell

| Tab | Screen | Status |
|---|---|---|
| Today | Quick log tiles, summary, recent, **active sleep banner**, growth/meds shortcuts, pregnancy shortcut while expecting | ✅ |
| Logs | Hub + per-type lists, filters, period bar, active sleep banner, 10-at-a-time Load more | ✅ |
| Learn | 25 cards, search/filter, triage flow, **Sources section with citations on every card** (App Review 1.4.1) | ✅ |
| Settings | Account, caregiver, partner, profile, pregnancy link, export, units, time, awake time, **language**, theme, legal, delete account | ✅ |

**Not a tab:** Pregnancy is a full-screen route (`/pregnancy`) from Settings, Today (while expecting), and the Add sheet.

**Add FAB:** Center-docked on Today / Logs / Learn / Settings (and Learn articles). Nested log lists and Growth keep their own add button. Sheet: feed, diaper, sleep, meds, pumping, tummy, growth, + pregnancy when expecting.

**Onboarding:** first-run flow (pregnancy vs baby born) → `lib/features/onboarding/`

## Logging

| Type | Quick log | Detailed form | List + filter | Sync |
|---|---|---|---|---|
| Feed | ✅ | ✅ breast / pumped bottle / formula | ✅ | ✅ create + edit + delete |
| Diaper | ✅ | ✅ wet/dirty/consistency | ✅ | ✅ create + edit + delete |
| Sleep | ✅ | ✅ start / end **or still sleeping** (backdated start OK) | ✅ | ✅ create + edit + delete |
| Medication | ✅ Today tile + FAB + daily reminder | ✅ presets (vit D, etc.) + optional daily ping | ✅ | ✅ create + edit + delete |
| Pumping | — FAB | ✅ volume/side | ✅ | ✅ create + edit + delete |
| Tummy time | — FAB | ✅ duration | ✅ | ✅ create + edit + delete (as `note`) |

**Also:** soft delete + restore (30-day copy on UI; check `log_retention.dart`), imperial/metric display.

**Date pickers:** care logs clamp to **3 years back** … **tomorrow** (`LogDateBounds`). Pregnancy due/appointments stay today-or-future while expecting.

**Sync:** create / edit / delete push when signed in; pull reconciles partner changes.

## Today screen extras

- Day summary cards (feeds, diapers, sleep minutes: clipped to the calendar day, includes in-progress sleep even if it began yesterday)
- **Sleeping now** banner with elapsed time + Wake up
- Recent log list with attribution when partner linked
- Gentle partner nudge banner (dismissible per session)
- Auto-sync on open when signed in
- PDF export shortcut in app bar (confirm, then share)
- Pull-to-refresh sync
- Pregnancy week shortcut while expecting
- Daily vitamin reminder on the meds card (“not logged yet” / time + Given)

## Learn

- **25 cards** in `content/cards/` (manifest v1)
- Card detail + medical disclaimer
- Triage decision trees (green / yellow / red)
- Search and category filter
- **Pending:** formal physician review → [todos/CONTENT_REVIEW.md](../todos/CONTENT_REVIEW.md)

## Growth

- Weight / length / head measurements
- **Trend chart** of measurement history (toggle metrics; imperial/metric). Not WHO percentile curves.
- WHO-style milestone checklist (achieved toggle + pick/change date)
- Growth screen + add measurement form
- Today shortcut card

## Partner & sync

| Capability | Status |
|---|---|
| Magic-code auth | ✅ SES first (`noreply@enfold.baby`); Graph fallback |
| Family invite code + join | ✅ |
| Leave family | ✅ confirm, then clear local partner data |
| Bidirectional care-event sync | ✅ create + edit + delete + pull |
| Last logged by (`· you` / partner name) | ✅ |
| Caregiver profile (role · name) | ✅ Settings → `PATCH /v1/auth/me` |
| Account switching isolation | ✅ upload local vs start fresh + clear on sign-out |
| In-app account deletion | ✅ Settings + `DELETE /v1/auth/me` |
| Gentle in-app nudge | ✅ opt-in |
| Activity push (FCM) | ✅ Android + API. iOS needs APNs `.p8` |
| Real-time / websocket sync | 🔲 pull on actions + Today open + ~45s periodic + pull-to-refresh |

## Settings modules

| Section | Status |
|---|---|
| Account (magic code, switch dialog, sign-out, delete) | ✅ |
| Caregiver profile (Mom/Dad/name for attribution) | ✅ |
| Partner sharing (invite/join/leave) | ✅ |
| Partner notifications (When partner logs) | ✅ FCM |
| Evening check-in (no logs today) | ✅ local, off by default |
| Daily vitamin reminder | ✅ one time of day, local ping, no streak. 2×/day later |
| Baby profile (name, birth date, preemie) | ✅ |
| Pregnancy (due, kicks, appointments) | ✅ link to full-screen route |
| 7-day PDF export | ✅ confirm dialog, then share |
| Metric / imperial units | ✅ |
| Time (12-hour AM/PM / 24-hour) | ✅ default 12-hour |
| Theme (system / light / dark, persisted) | ✅ dark secondary AA |
| About + legal (privacy / terms URLs) | ✅ |
| Language (Device / English / Romanian) | ✅ gen-l10n, 603 strings, per device. See [I18N_RO.md](../todos/I18N_RO.md) |

## Local database (Drift v16)

| Table | Purpose |
|---|---|
| `babies` | Local baby + `serverChildId` |
| `care_events` | Unified log mirror of VPS `care_events` |
| `pregnancy_profiles` | Due date, kick count |
| `pregnancy_appointments` | Appointment notes |
| `app_settings` | Onboarding, units, 12/24-hour clock, partner toggles, theme_mode, last_signed_in_user_id, care_reminders_enabled, show_awake_time, language_tag |
| `growth_measurements` | Weight/length/head |
| `milestone_achievements` | Milestone done dates |
| `medication_routines` | Local daily vitamin reminder (name, clock time). Not a repeating log. |

Sleep in-progress is stored in `care_events.details_json` (`sleep_in_progress`, `sleep_start`).

## API (`https://api.enfold.baby`)

| Endpoint | Used by |
|---|---|
| `POST /v1/auth/magic-code/*` | App sign-in |
| `GET/PATCH/DELETE /v1/auth/me` | Profile + account deletion |
| `GET/POST /v1/children` | Baby sync |
| `GET/POST/PATCH/DELETE /v1/care-events` | Log sync |
| `GET /v1/families/me` | Partner info |
| `POST /v1/families/invites` | Create invite |
| `POST /v1/families/join` | Join family |
| `POST /v1/families/leave` | Leave family |
| `POST /v1/devices` | FCM token |
| `POST /v1/devices/unregister` | Toggle off |
| `POST /v1/beta-requests` | Landing launch-notify form |
| `GET /v1/app-version` | Sideload version check (install path unwired) |

**VPS:** host, user and directory in the private ops env (`~/Documents/enfold/ops/ops.env`)  
Containers / Postgres role stay **bloomdue** (do not rename).

**Mail:** SES live from `noreply@enfold.baby` · Graph fallback · SMTP broken (535) (`todos/SES_MAIL.md`)

**Client:** `lib/services/api/enfold_api_client.dart` (`EnfoldApiClient`).

## Landing (`https://enfold.baby`)

| Asset | Status |
|---|---|
| Marketing redesign | ✅ |
| Privacy `/privacy/` · Terms `/terms/` | ✅ |
| Launch-notify form `#notify` (`#join-beta` alias) | ✅ Google Play soon, iOS shortly after |
| Open startup `/open/` | ✅ |
| Product roadmap `/roadmap/` | ✅ |
| **Help / village** `/support/` | ✅ share, plant-a-moon, credits |
| `/help/` | ✅ redirect → `/support/` |
| `due.enfold.baby` | ✅ Live |
| Cookie banner | ❌ not needed (Simple Analytics) |

## Push

- `FirebaseFcmTokenSource` + `POST /v1/devices`
- Firebase project **enfold-28c4e** (gitignored client files)
- Backend FCM HTTP v1; service account at `/app/secrets/firebase-sa.json`
- Android notification icon `ic_stat_enfold`, channel `partner_activity`
- Sideload APK `1.0.0+20` on Desktop includes Android config + daily vitamin reminder
- iOS: plist in Xcode resources; **APNs auth key still needed** to actually deliver

## Languages

| Piece | Status |
|---|---|
| Setup | ✅ `flutter gen-l10n`, `l10n.yaml`, `lib/l10n/app_en.arb` + `app_ro.arb` (603 keys, generated output gitignored) |
| Device default | ✅ Romanian device → Romanian, anything else → English |
| Settings override | ✅ Device / English / Romanian, per device, stored in `app_settings.language_tag` |
| Notifications | ✅ through `appL10nProvider`; iOS categories follow the device language (registered once per launch) |
| Visit PDF | ✅ follows the app language |
| Learn cards | 🔲 English on purpose until a clinician reviews a medical translation |
| Native check | 🔲 Raul and Oana still to read the Romanian draft |
| Website `/ro/` | 🔲 not started |

**Stays English because it is stored or sent:** caregiver role values (`Mom`, `Dad`, …) inside `display_name`, medication category values, milestone keys, medication preset ids.

## Tests & tooling

| Suite | Notes |
|---|---|
| Unit + widget | `test/`, 220 tests, including contrast, sleep-in-progress, FAB, date bounds, 12/24-hour clock, daily vitamin reminder, edge-to-edge system bars, Romanian UI |
| Integration | `integration_test/` — app, account-switch e2e, demo screenshots |
| Demo / store goldens | `scripts/capture_demo_screenshots.sh` + `test/widget/store_screenshots_test.dart` — Play listing still needs a **real phone** |

## Infra

| Asset | Status |
|---|---|
| Landing container | ✅ prod |
| API container | ✅ prod |
| Postgres / Redis | ✅ prod |
| FCM service account volume | ✅ `./backend/secrets:/app/secrets:ro` |
| GitHub | public since 2026-09-17; ARB files exist, so translation PRs are possible |
