# Date pickers: no past dates while expecting

> **Priority:** P3 · **Status:** ✅ Shipped 2026-08-10  
> **Source:** User feedback 2026-07-20 (mobile dogfood)

## Shipped

- Due date pickers (onboarding expecting + Pregnancy screen): `firstDate` = local today  
- Appointment date picker: today or future only  
- Helpers + unit tests: `lib/features/pregnancy/expecting_date_bounds.dart`  
- Care-log date pickers still allow past backfill, later bounded by `LogDateBounds` (3 years back … tomorrow)

## Intent

When the family is still in the **expecting / pregnancy** stage, date pickers should not allow selecting **past calendar dates** where that would be nonsensical (e.g. due date, future appointments). Keep the flow calm: block or clamp, don’t error-shout.

## Likely surfaces

- Pregnancy **due date** entry / edit  
- Pregnancy **appointment** date  
- Any onboarding “expecting” path that sets dates  
- (Review) other “scheduled for” fields that only make sense as today-or-future while expecting  

**Out of scope for first pass:** care logs that legitimately happen in the past (feeds, sleep backfill) — those should still allow past times within a sensible window. Shipped later as `LogDateBounds` (3 years back, last date tomorrow).

## Acceptance sketch

- [x] While profile/mode is **expecting**, due-date picker: `firstDate` ≥ today (or allow only future relative to “today” in local TZ).  
- [x] Appointment dates: no past days (or only “today” if we want same-day visits).  
- [x] Existing saved past due dates (edge case / late setup) still display; editing re-applies the constraint.  
- [x] Unit/widget tests for date bounds.  
- [x] No change to historical care-event logging (later: `LogDateBounds` on care-log pickers).

## Notes

- Timezone: use device local date, consistent with rest of app.  
- Optional later: soft “are you sure?” for same-day edge cases instead of hard block.
