# Todo — account switching & local data isolation

> **Priority:** P2 (before public beta) · **Status:** 🔲 Not started

## Problem

The app uses **one local SQLite database per install**, not per account.

| Scenario | Current behavior | Risk |
|---|---|---|
| Offline use → first sign-in | Local logs upload to that account | ✅ Intended |
| Sign out | Token cleared; **all local data stays** | ⚠️ |
| Sign in to different account | Same local baby + logs still on device | 🔴 Data mix / wrong sync target |
| Sign back to first account | No wipe; `serverChildId` may be stale | 🔴 Sync errors, mixed UI |

Fine for **one family / one account per phone** (current beta). Not safe for account hopping on the same device.

## Target behavior (industry practice)

On sign-in when `userId` ≠ last signed-in user, show a dialog:

1. **Upload local logs to this account** — keep device data, push pending rows
2. **Start fresh** — clear local care data, full pull from server

On sign-out (optional, off by default):

- **Sign out** — keep local data for offline use
- **Sign out and clear device data** — wipe local DB cache (with confirmation)

Also:

- Persist `lastSignedInUserId` in `app_settings`
- Reset `serverChildId` when account changes
- Full pull on “start fresh” (not just 2-day lookback)

## Implementation sketch

1. `app_settings.last_signed_in_user_id` (schema v10)
2. `AccountSwitchService` on `verifyMagicCode` + `signOut`
3. Dialog in `account_section.dart`
4. `CareLogDao.clearLocalCareData()` / scoped wipe helper
5. Tests: offline → acc1 → sign out → acc2 prompt paths

## Key files

- `lib/services/auth/auth_providers.dart`
- `lib/features/settings/widgets/account_section.dart`
- `lib/services/sync/sync_service.dart`
- `lib/services/database/care_log_dao.dart`

## Until shipped

Document for testers: **one account per device** for partner testing.