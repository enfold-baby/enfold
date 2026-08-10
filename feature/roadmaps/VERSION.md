# Version roadmap

> Aligns with [`BRANDING.md`](../../BRANDING.md) mission. Updated 2026-07-08.

## Shipped — v0.1.x (private beta)

Current: **`0.1.0+4`**

| Milestone | Focus | Status |
|---|---|---|
| 0.1.0 core | Theme, router, 3am log, Drift, Learn, auth, sync | ✅ |
| 0.1.1 content | 25 learn cards + triage | ✅ |
| 0.1.2 logs+ | Meds, pumping, tummy, growth, soft delete | ✅ |
| 0.1.3 partner | Family invite, sync, last-logged-by, gentle nudge | ✅ |
| 0.1.4 push prep | FCM scaffold (no Firebase project yet) | ✅ |

### v0.1 exit criteria (before public beta)

- [ ] Physician review on learn cards
- [ ] FCM partner activity push live
- [ ] Sync delete + edit to server
- [ ] Signed Android release build
- [ ] iOS TestFlight build
- [ ] 2+ families dogfooding for 1 week without data loss

---

## v0.2 — polish + locale

| Item | Notes |
|---|---|
| Romanian i18n | ARB files, `flutter_localizations` |
| Growth charts | Visual curves from measurement history |
| Pull-to-refresh sync | Explicit partner refresh on Today |
| Background sync | Periodic pull when signed in |
| Account switching | Upload-or-fresh prompt on different login → [todos/ACCOUNT_SWITCHING.md](../todos/ACCOUNT_SWITCHING.md) |
| Dark theme polish | Persist theme + contrast pass ✅ shipped 0.1.0+7 |
| No past dates while expecting | Due date / pregnancy appointment pickers clamp to today+ → [todos/DATE_PICKER_NO_PAST.md](../todos/DATE_PICKER_NO_PAST.md) |

---

## v0.3 — depth

| Item | Notes |
|---|---|
| NICU / preemie module | Corrected age throughout UI |
| Fever log + meds reminders | Optional local notifications |
| Expanded triage trees | Per-card depth |
| Anonymous → account upgrade | Use app without email first |

---

## v0.4 — toddler phase

| Item | Notes |
|---|---|
| Solids / allergens log | New care_event types |
| Potty, behavior notes | Toddler tab or phase shift |
| Words / milestones expansion | Beyond newborn catalog |

---

## v1.0 — public launch

| Item | Notes |
|---|---|
| Play Store + App Store | Signed, reviewed, privacy policy |
| `bloomdue.baby` marketing refresh | Screenshots, store copy |
| Analytics opt-in | Privacy-respecting only |
| Content CMS | Remote card updates without app release |

---

## Explicitly out of scope (for now)

- AI sleep predictions
- Community forums
- Wearable integrations
- Ads or paywalled safety content