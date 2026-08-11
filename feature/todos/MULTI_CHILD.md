# Todo — multiple children per family

> **Priority:** P2 · **Status:** 🔲 Not started · **Depends on:** solid partner sync (partially shipped)

## Why

Families often have twins, a newborn + toddler, or nanny care for more than one child.  
Server already allows **many `children` rows per family**; the Flutter app still assumes **one active local baby**.

## Today

| Layer | Behavior |
|---|---|
| API | `list/create children` — multi OK |
| Local Drift | One default baby (`ensureDefaultBaby`) |
| Sync | Pulls **all** family children’s care events into one local baby (workaround) |
| UX | Baby profile = single name / birth date |

## Target UX

1. **Children list** in Settings (or Today header picker)
2. **Active child** switcher — logs, Today, growth scoped to active child
3. **Add child** (name, birth date, preemie) → server + local row
4. Sync maps `serverChildId` **per local baby** (not one global link)
5. Partner devices see the same child list after join

## Implementation sketch

1. Local `babies` already multi-row capable — stop `limit(1)` defaults  
2. `active_baby_id` in `app_settings` (schema bump)  
3. DAOs filter care/growth by active baby  
4. Sync: push/pull per baby’s `serverChildId`; create child only when missing for that baby  
5. UI: child switcher chip on Today + Settings list  

## Until shipped

Treat the app as **one child per install**, even if the server has multiple orphan children from earlier partner join bugs. Prefer one parent creates the baby, then partner joins.

### Partner hygiene (2026-08-11)

- Join rebinds to the **host family’s oldest child** — never creates a second child when the family already has one.
- Periodic foreground sync (~45s) while the app is open keeps partners fresher without multi-child UI.
- Full multi-child switcher still required for twins/siblings.
