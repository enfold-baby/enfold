# Todos — what to work on next

> Prioritized pending work. For implemented features see [features/STATUS.md](../features/STATUS.md).

## Queue

| Priority | Item | Doc | Effort |
|---|---|---|---|
| ✅ | ~~Sync delete + edit to server~~ | [SYNC_UPDATES.md](./SYNC_UPDATES.md) | Shipped 2026-07-08 |
| 🟠 P2 | **FCM partner activity push** *(deferred)* | [FCM_PARTNER_PUSH.md](./FCM_PARTNER_PUSH.md) | Medium — needs Firebase later |
| 🟠 P2 | **Account switching / local data isolation** | [ACCOUNT_SWITCHING.md](./ACCOUNT_SWITCHING.md) | Medium — before public beta |
| 🟠 P2 | **Store release (signed builds)** | [STORE_RELEASE.md](./STORE_RELEASE.md) | Medium |
| 🟡 P3 | **Learn card physician review** | [CONTENT_REVIEW.md](./CONTENT_REVIEW.md) | Ongoing — human in the loop |
| 🟡 P3 | **Real-time partner sync** | — | Medium — websocket or periodic pull |
| 🟡 P3 | **No past dates while expecting** *(idea)* | [DATE_PICKER_NO_PAST.md](./DATE_PICKER_NO_PAST.md) | Small — UX polish |
| 🟢 P4 | Romanian i18n | [roadmaps/VERSION.md](../roadmaps/VERSION.md) | Large |
| 🟢 P4 | Anonymous-first auth | [roadmaps/VERSION.md](../roadmaps/VERSION.md) | Medium |

## How to pick up any item

1. Read [SESSION.md](../SESSION.md) — where we left off
2. Open [PICKUP.md](../PICKUP.md) for copy-paste session prompts
3. Read the linked todo doc
4. Run `flutter test` before and after
5. On finish → [MAINTAIN.md](../MAINTAIN.md) checklist

## Recently completed ✅

- Sync delete + edit to server (PATCH/DELETE + pull reconciliation)
- Partner last-logged-by attribution (schema v8)
- Gentle partner nudge banner + settings toggles
- FCM scaffold (`NoOpFcmTokenSource`, `pushBootstrapProvider`)
- VPS `created_by_*` columns + partner push hook (deployed)
- Growth measurements + milestones
- Medication / pumping / tummy time logs
- 25 learn cards + search/filter
- Soft delete + restore for care logs