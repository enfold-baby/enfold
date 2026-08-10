# Version roadmap

> Aligns with [`BRANDING.md`](../../BRANDING.md) mission. Updated **2026-08-10**.

## Shipped — v0.1.x (private beta)

Current: **`0.1.0+9`**

| Milestone | Focus | Status |
|---|---|---|
| 0.1.0 core | Theme, router, 3am log, Drift, Learn, auth, sync | ✅ |
| 0.1.1 content | 25 learn cards + triage | ✅ |
| 0.1.2 logs+ | Meds, pumping, tummy, growth, soft delete | ✅ |
| 0.1.3 partner | Family invite, sync, last-logged-by, gentle nudge | ✅ |
| 0.1.4 push prep | FCM scaffold (no Firebase project yet) | ✅ |
| 0.1.x polish | Theme persist, brand icon, APK sideload, sync edit/delete | ✅ |
| Landing | v3 redesign, carousel, legal pages, beta form + API | ✅ |

### v0.1 exit criteria (before public beta)

- [ ] Physician review on learn cards  
- [x] Sync delete + edit to server  
- [ ] FCM partner activity push live *(deferred OK for soft launch)*  
- [ ] Signed Android release build  
- [ ] iOS TestFlight build  
- [ ] 2+ families dogfooding for 1 week without data loss  
- [x] Privacy policy + terms URLs on landing  
- [ ] DUNS / store org ready  

---

## v0.2 — polish + locale

| Item | Notes |
|---|---|
| No past dates while expecting | Due / appointment pickers ✅ [todos/DATE_PICKER_NO_PAST.md](../todos/DATE_PICKER_NO_PAST.md) |
| In-app Android APK update | AD-style check / download / install ✅ |
| Pull-to-refresh sync | Explicit partner refresh on Today ✅ |
| Open startup + public roadmap | Landing `/open` + `/roadmap` |
| Background sync | Periodic pull when signed in |
| Account switching | Upload-or-fresh on different login → [todos/ACCOUNT_SWITCHING.md](../todos/ACCOUNT_SWITCHING.md) |
| Romanian i18n | ARB files, `flutter_localizations` |
| Growth charts | Visual curves from measurement history |
| Dark theme polish | Persist theme + contrast ✅ shipped 0.1.0+7 |

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
| Play Store + App Store | Signed, reviewed; legal URLs already live |
| `bloomdue.baby` marketing refresh | Screenshots, store copy (demo SS tooling exists) |
| Analytics opt-in | Privacy-respecting only (SA already cookieless) |
| Content CMS | Remote card updates without app release |

---

## Explicitly out of scope (for now)

- AI sleep predictions  
- Community forums  
- Wearable integrations  
- Ads or paywalled safety content  
