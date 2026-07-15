# Todo — sync delete + edit to server

> **Priority:** P1 · **Status:** ✅ Shipped 2026-07-08

## Problem

Create sync works: new logs push via `SyncService.syncPending()` → `POST /v1/care-events`.

**Gaps:**

| Action | Local | Server |
|---|---|---|
| Create log | ✅ | ✅ pushed when signed in |
| Edit log | ✅ marks `pendingSync` | 🔲 no `PATCH` call in sync service |
| Soft delete | ✅ sets `deletedAt` | 🔲 no `DELETE` call in sync service |
| Restore | ✅ clears `deletedAt` | 🔲 N/A |

Partners can see stale entries if one parent edits or deletes locally.

## API already exists (VPS)

- `PATCH /v1/care-events/{event_id}`
- `DELETE /v1/care-events/{event_id}`

## Implementation plan

### Flutter

1. Add `updateCareEvent()` and `deleteCareEvent()` to `BloomdueApiClient`
2. Extend `SyncService.syncPending()` to handle:
   - rows with `pendingSync` + existing server id (updates)
   - rows with `deletedAt` set + were previously synced (deletes)
3. Trigger sync after edit/delete in `CareLogActions`
4. Tests: `sync_update_test.dart`, `sync_delete_test.dart`

### Backend

- Verify delete is soft or hard (currently hard delete on VPS)
- Consider tombstone / `deleted_at` on server if we want restore across devices

## Verify

1. Parent A logs feed → syncs
2. Parent B pulls → sees feed
3. Parent A edits note → syncs
4. Parent B pulls → sees updated note
5. Parent A deletes → syncs
6. Parent B pulls → entry gone

## Key files

- `lib/services/sync/sync_service.dart`
- `lib/services/api/bloomdue_api_client.dart`
- `lib/features/today/providers/today_log_provider.dart`
- `lib/services/database/care_log_dao.dart`