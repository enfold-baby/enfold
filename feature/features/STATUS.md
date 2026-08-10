# Feature status — what's built

> Snapshot as of **2026-08-10**. Source of truth is the code; update this when shipping major modules.  
> App: **`0.1.0+9`** · Drift **v9** · API + landing live on prod.

## App shell

| Tab | Screen | Status |
|---|---|---|
| Today | Quick log, summary, recent, growth/meds shortcuts | ✅ |
| Logs | Hub + per-type lists, filters, period bar | ✅ |
| Learn | 25 cards, search/filter, triage flow | ✅ |
| Pregnancy | Due date, week calc, kick counter, appointments | ✅ |
| Pregnancy UX | No past dates while expecting (due/appointments) | ✅ |
| Settings | Account, partner, profile, export, units, theme | ✅ |

**Onboarding:** first-run flow (pregnancy vs baby born) → `lib/features/onboarding/`

## Logging

| Type | Quick log | Detailed form | List + filter | Sync |
|---|---|---|---|---|
| Feed | ✅ | ✅ breast / pumped bottle / formula | ✅ | ✅ create + edit + delete |
| Diaper | ✅ | ✅ wet/dirty/consistency | ✅ | ✅ create + edit + delete |
| Sleep | ✅ | ✅ start/end/duration | ✅ | ✅ create + edit + delete |
| Medication | — | ✅ presets (vit D, etc.) | ✅ | ✅ create + edit + delete |
| Pumping | — | ✅ volume/side | ✅ | ✅ create + edit + delete |
| Tummy time | — | ✅ duration | ✅ | ✅ create + edit + delete (as `note`) |

**Also:** soft delete + restore (7-day retention), imperial/metric display.

**Sync:** create / edit / delete all push when signed in; pull reconciles partner changes → [todos/SYNC_UPDATES.md](../todos/SYNC_UPDATES.md) ✅ shipped.

## Today screen extras

- Day summary cards (feeds, diapers, sleep minutes)
- Recent log list with attribution when partner linked
- Gentle partner nudge banner (dismissible per session)
- Auto-sync on open when signed in
- PDF export shortcut in app bar
- 🔲 Pull-to-refresh sync (nice next polish)

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
| Magic-code auth | ✅ |
| Family invite code + join | ✅ |
| Bidirectional care-event sync | ✅ create + edit + delete + pull |
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
| Theme (system / light / dark, **persisted**) | ✅ |
| About (version, beta badge) | ✅ |

## Local database (Drift v9)

| Table | Purpose |
|---|---|
| `babies` | Local baby + `serverChildId` |
| `care_events` | Unified log mirror of VPS `care_events` |
| `pregnancy_profiles` | Due date, kick count |
| `pregnancy_appointments` | Appointment notes |
| `app_settings` | Onboarding, units, partner toggles, **theme_mode** |
| `growth_measurements` | Weight/length/head |
| `milestone_achievements` | Milestone done dates |

## API (`https://api.bloomdue.baby`)

| Endpoint | Used by |
|---|---|
| `POST /v1/auth/magic-code/*` | App sign-in |
| `GET /v1/auth/me` | Profile |
| `GET/POST /v1/children` | Baby sync |
| `GET/POST/PATCH/DELETE /v1/care-events` | Log sync |
| `GET /v1/families/me` | Partner info |
| `POST /v1/families/invites` | Create invite |
| `POST /v1/families/join` | Join family |
| `POST /v1/devices` | FCM token (when available) |
| `POST /v1/beta-requests` | **Landing** beta form → SMTP |

**VPS deploy:** `landing/deploy.sh`, `deploy/api-email/`, `deploy/api-partner/`

## Landing (`https://bloomdue.baby`)

| Asset | Status |
|---|---|
| Marketing redesign (v3 / mobile-aligned) | ✅ |
| Mobile care story carousel | ✅ |
| Privacy Policy `/privacy/` | ✅ |
| Terms of Use `/terms/` | ✅ |
| Join-beta form `#join-beta` | ✅ → API + `contact@globinary.io` |
| Cookie consent banner | ❌ not needed (Simple Analytics only) |
| `due.bloomdue.baby` | ✅ Live — do not touch |

## Push (prepared)

- `FcmTokenSource` → `NoOpFcmTokenSource` (returns null)
- `pushBootstrapProvider` registers on sign-in when toggle on
- Backend `notify_family_partners()` — no-op until Firebase creds on VPS

## Tests & tooling

| Suite | Notes |
|---|---|
| Unit + widget | `test/` (~33 files) |
| Integration | `integration_test/app_test.dart` |
| Demo screenshots | `integration_test/demo_screenshots_test.dart` + `scripts/capture_demo_screenshots.sh` |

## Infra

| Asset | Status |
|---|---|
| Landing container | ✅ prod |
| API container | ✅ prod |
| Postgres / Redis | ✅ prod |
| GitHub `Gl0deanR/bloomdue-baby` | ✅ `main` synced |
