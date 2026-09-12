# Daily Care Log

## Goal

Give tired parents the fastest possible way to record what happened and see the baby's recent pattern without needing perfect data entry.

## MVP Events

- Feeding: breast, bottle, formula, expressed milk, amount when known, side when relevant, note.
- Diaper: wet, dirty, mixed, note.
- Sleep: start/end **or still sleeping** (backdated start allowed; Today shows an active banner).
- Pumping: amount, side, note.
- Medication/vitamin: name, dose text, note. Optional **daily reminder** (one clock time, local ping, Today Given). Not a repeating log row. 2×/day and short courses are later.
- Note: free-form observation.

## Behavior

- Events are saved locally first and marked `pending_sync`.
- The backend stores canonical synced records and returns server timestamps.
- Parents can edit/delete family records; sync pushes create/edit/delete. Soft delete + restore locally.
- Timeline defaults to newest first and groups by day.
- Care-log date pickers clamp to 3 years back … tomorrow (`LogDateBounds`).
- Add from the docked FAB (all types) or Today tiles (feed / diaper / sleep / meds).

## Safety Boundary

The app can display educational context, but v1 must not label a baby as sick, diagnose a condition, or prescribe treatment.
