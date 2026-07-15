# Feature status — what's built

> Snapshot of the codebase as of **2026-07-08**. Source of truth is the code; update this when shipping major modules.

## App shell

| Tab | Screen | Status |
|---|---|---|
| Today | Quick log, summary, recent, growth/meds shortcuts | ✅ |
| Logs | Hub + per-type lists, filters, period bar | ✅ |
| Learn | 25 cards, search/filter, triage flow | ✅ |
| Pregnancy | Due date, week calc, kick counter, appointments | ✅ |
| Settings | Account, partner, profile, export, units, theme | ✅ |

**Onboarding:** first-run flow (pregnancy vs baby born) → `lib/features/onboarding/`

## Logging

| Type | Quick log | Detailed form | List + filter | Sync push |
|---|---|---|---|---|
| Feed | ✅ | ✅ breast/bottle details | ✅ | ✅ create |
| Diaper | ✅ | ✅ wet/dirty/consistency | ✅ | ✅ create |
| Sleep | ✅ | ✅ start/end/duration | ✅ | ✅ create |
| Medication | — | ✅ presets (vit D, etc.) | ✅ | ✅ create |
| Pumping | — | ✅ volume/side | ✅ | ✅ create |
| Tummy time | — | ✅ duration | ✅ | ✅ create (as `note`) |

**Also:** soft delete + restore (7-day retention), edit forms, imperial/metric display.

**Gap:** delete and edit do **not** sync to server yet → see [todos/SYNC_UPDATES.md](../todos/SYNC_UPDATES.md).

## Today screen extras

- Day summary cards (feeds, diapers, sleep minutes)
- Recent log list with attribution when partner linked
- Gentle partner nudge banner (dismissible per session)
- Auto-sync on open when signed in
- PDF export shortcut in app bar

## Learn

- **25 cards** in `content/cards/` (manifest v1)
- Card detail + medical disclaimer
- Triage decision trees (green / yellow / red)
- Search and category filter
- **Pending:** formal physician review sign-off → [todos/CONTENT_REVIEW.md](../todos/CONTENT_REVIEW.md)

## Growth

- Weight / length / head measurements
- WHO-style milestone checklist (achieved toggle)
- Growth screen + add measurement form
- Today shortcut card

## Partner & sync

| Capability | Status |
|---|---|
| Magic-link auth | ✅ |
| Family invite code + join | ✅ |
| Bidirectional care-event sync | ✅ create + pull |
| Last logged by (`· you` / partner name) | ✅ |
| Gentle in-app nudge | ✅ opt-in |
| Activity push (FCM) | 🟡 prepared, no Firebase yet |
| Real-time / websocket sync | 🔲 pull on actions + Today open |

## Settings modules

| Section | Status |
|---|---|
| Account (magic code sign-in/out) | ✅ |
| Partner sharing (invite/join) | ✅ |
| Partner notifications (2 toggles) | ✅ |
| Baby profile (name, birth date, preemie) | ✅ |
| 7-day PDF export | ✅ |
| Metric / imperial units | ✅ |
| Theme (system / light / dark) | ✅ |
| About (version, beta badge) | ✅ |

## Local database (Drift v8)

| Table | Purpose |
|---|---|
| `babies` | Local baby + `serverChildId` |
| `care_events` | Unified log mirror of VPS `care_events` |
| `pregnancy_profiles` | Due date, kick count |
| `pregnancy_appointments` | Appointment notes |
| `app_settings` | Onboarding, units, partner notification toggles |
| `growth_measurements` | Weight/length/head |
| `milestone_achievements` | Milestone done dates |

## API client (`https://api.bloomdue.baby`)

| Endpoint | Used by app |
|---|---|
| `POST /v1/auth/magic-code/*` | Sign in |
| `GET /v1/auth/me` | Profile |
| `GET/POST /v1/children` | Baby sync |
| `GET/POST /v1/care-events` | Log sync |
| `GET /v1/families/me` | Partner info |
| `POST /v1/families/invites` | Create invite |
| `POST /v1/families/join` | Join family |
| `POST /v1/devices` | FCM token (when available) |

**VPS deploy packages:** `deploy/api-email/`, `deploy/api-partner/`

## Push (prepared)

- `FcmTokenSource` → `NoOpFcmTokenSource` (returns null)
- `pushBootstrapProvider` registers on sign-in when toggle on
- Backend `notify_family_partners()` — no-op until Firebase creds on VPS

## Tests

| Suite | Count |
|---|---|
| Unit + widget | 34 files |
| Integration | `integration_test/app_test.dart` |
| **Total** | **84 passing** |

## Infra

| Asset | Status |
|---|---|
| Landing `bloomdue.baby` | ✅ Live (`landing/`) |
| API `api.bloomdue.baby` | ✅ Live (VPS Docker) |
| `due.bloomdue.baby` | ✅ Live — do not touch |