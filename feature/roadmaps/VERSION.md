# Version roadmap

> Aligns with [`BRANDING.md`](../../BRANDING.md) mission. Updated **2026-09-10**.

## Shipped — v1.0.0 (Play live)

Current: **`1.0.0+20`**

v0.1.x was the private-beta trail. **1.0.0** is the Play Store version name (build **20**). iOS TestFlight, physician sign-off, and Stripe links can still follow.

## Earlier — v0.1.x

| Milestone | Focus | Status |
|---|---|---|
| 0.1.0 core | Theme, router, 3am log, Drift, Learn, auth, sync | ✅ |
| 0.1.1 content | 25 learn cards + triage | ✅ |
| 0.1.2 logs+ | Meds, pumping, tummy, growth, soft delete | ✅ |
| 0.1.3 partner | Family invite, sync, last-logged-by, gentle nudge | ✅ |
| 0.1.4 push | FCM Android + VPS sender (`enfold-28c4e`) | ✅ |
| 0.1.x polish | Dark contrast, still-sleeping, Play upload key, SES mail, 4-tab + FAB, growth charts | ✅ |
| Landing | Legal, launch-notify, `/open`, `/roadmap`, `/support` (`/help` redirects) | ✅ |

### v0.1 exit criteria (before public beta)

- [ ] Physician review on learn cards  
- [x] Sync delete + edit to server  
- [x] FCM partner activity push (Android live; iOS APNs pending)  
- [x] Signed Android **upload** keystore + AAB path  
- [ ] Play listing (screenshots, Data safety, first upload)  
- [ ] iOS TestFlight build  
- [ ] 2+ families dogfooding for 1 week without data loss  
- [x] Privacy policy + terms + in-app account delete  
- [x] Help / support page (`/support/`) — Stripe links pending  
- [x] SES from `noreply@enfold.baby` (Graph remains fallback)

---

## v0.2 — polish + locale

| Item | Notes |
|---|---|
| No past dates while expecting | Due / appointment pickers ✅ [todos/DATE_PICKER_NO_PAST.md](../todos/DATE_PICKER_NO_PAST.md) |
| Care-log date bounds | 3 years back … tomorrow ✅ `LogDateBounds` |
| In-app Android APK update | Built, then **removed** for Play policy — [todos/APP_VERSION_UPDATE.md](../todos/APP_VERSION_UPDATE.md) |
| Pull-to-refresh sync | Today, Logs, Growth, Settings ✅ |
| Open startup + public roadmap | Landing `/open` + `/roadmap` |
| Background sync | Periodic pull ~45s while signed in and app open ✅ |
| Account switching | Upload-or-fresh on different login ✅ [todos/ACCOUNT_SWITCHING.md](../todos/ACCOUNT_SWITCHING.md) |
| 4-tab shell + Add FAB | Pregnancy off the tab bar ✅ |
| Growth charts | Measurement history trends ✅ (not WHO percentiles) |
| Romanian i18n | Plan locked, not started — [todos/I18N_RO.md](../todos/I18N_RO.md) |
| Dark theme polish | Persist theme + contrast ✅ shipped 0.1.0+7 |
| 12h / 24h clock | Settings → Time ✅ Drift v12 |
| Daily vitamin reminder | One time of day, local ping, Today Given ✅ Drift v13 |

---

## v0.3 — depth

| Item | Notes |
|---|---|
| NICU / preemie module | Corrected age throughout UI |
| Fever log | Optional temperature log + local reminder |
| 2×/day + short med courses | Morning+evening clocks; “for 7 days” / until date. Daily vitamin reminder already shipped |
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
| Play Store version | **`1.0.0+20`** — this build. Listing upload (screenshots, Data safety, AAB) still needed |
| App Store | TestFlight later |
| `enfold.baby` marketing refresh | Screenshots, store copy (demo SS tooling exists) |
| Analytics opt-in | Privacy-respecting only (SA already cookieless) |
| Content CMS | Remote card updates without app release |

---

## Explicitly out of scope (for now)

- AI sleep predictions  
- Community forums  
- Wearable integrations  
- Ads or paywalled safety content  
- In-app ads or sponsor inventory (website `/support/` tips only)
