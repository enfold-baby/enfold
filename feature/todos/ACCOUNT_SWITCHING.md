# Todo — account switching & local data isolation

> **Priority:** P2 (before public beta) · **Status:** ✅ Shipped 2026-08-10 (local)  
> **Schema:** Drift **v10** (`last_signed_in_user_id`)

## Problem

The app uses **one local SQLite database per install**, not per account.

| Scenario | Current behavior | Risk |
|---|---|---|
| Offline use → first sign-in | Local logs upload to that account | ✅ Intended |
| Sign out | Token cleared; **all local data stays** | ⚠️ OK for offline |
| Sign in to different account | Prompt: upload local **or** start fresh | ✅ Isolated |
| Sign back to first account | Same prompt if last user differed | ✅ |

## Shipped behavior

On sign-in when `userId` ≠ `lastSignedInUserId`, dialog:

1. **Upload local logs** — keep device data, unlink `serverChildId`, push pending rows
2. **Start fresh** — clear care/growth/pregnancy local data, full-history pull
3. **Cancel** — sign-out again (no last-user update)

Also:

- Persist `lastSignedInUserId` in `app_settings` after successful sign-in + sync attempt
- **Sign out** keeps local data
- **Sign out and clear device data** — wipe local care cache + clear last user (confirm dialog)
- Full pull when starting fresh (`SyncService.pullRemote(fullHistory: true)`)

## Implementation

| Piece | Location |
|---|---|
| Schema v10 | `lib/services/database/tables.dart`, `app_database.dart` |
| Settings accessors | `lib/services/database/settings_dao.dart` |
| Clear / unlink helpers | `CareLogDao` + `AccountSwitchService` |
| Switch service | `lib/services/auth/account_switch_service.dart` |
| Dialog + sign-out clear | `lib/features/settings/widgets/account_section.dart` |
| Full history pull | `lib/services/sync/sync_service.dart` |
| Tests | `test/services/account_switch_service_test.dart`, sync_pull, settings_dao |

## Tester notes

- One phone can now hop accounts safely when the dialog is answered deliberately.
- “Upload local logs” attaches offline rows to the **new** account — use “Start fresh” if the phone had another family’s data.
