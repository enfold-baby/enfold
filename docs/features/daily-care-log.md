# Daily Care Log

## Goal

Give tired parents the fastest possible way to record what happened and see the baby's recent pattern without needing perfect data entry.

## MVP Events

- Feeding: breast, bottle, formula, expressed milk, amount when known, side when relevant, note.
- Diaper: wet, dirty, mixed, note.
- Sleep: start/end or quick duration.
- Pumping: amount, side, note.
- Medication/vitamin: name, dose text, note.
- Note: free-form observation.

## Behavior

- Events are saved locally first and marked `pending_sync`.
- The backend stores canonical synced records and returns server timestamps.
- Parents can edit/delete their own family records; deletes should become tombstones once sync is implemented.
- Timeline defaults to newest first and groups by day.

## Safety Boundary

The app can display educational context, but v1 must not label a baby as sick, diagnose a condition, or prescribe treatment.
