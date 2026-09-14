# Enfold.baby — Project Kickoff

> **Pickup 2026-09-14.** Google Play: 1.0.0+22 in review, 1.0.1+24 on internal testing. App Store: "Enfold: Baby Tracker" 1.0.1 (24)
> waiting for review; TestFlight group "Raul's devices". Launch plan and evidence: `~/Desktop/LAUNCH-CHECKLIST.md` (outside the repo).
> Prod deploy facts and the supporters wall: `ops/README.md`. Store listing: `assets/brand/store/app-store-listing.md`.
> Reviewer account: `~/Documents/enfold/play-reviewer-account.md`. Next: Stripe galaxy sandbox test (`feature/PICKUP.md`).


> **Read this first** when starting a fresh conversation in this repo.  
> **Domain:** [enfold.baby](https://enfold.baby)  
> **Folder:** this repo (`bloomdue_baby` on disk; product name **Enfold**)  
> **Stack:** Flutter + Dart · Android + iOS · free globally  
> **Current:** `1.0.1+25` · Drift schema v14 · 4-tab shell + Add FAB · VPS API live · FCM (Android + iOS APNs) + SES mail live

**Resuming work?** → [`feature/SESSION.md`](./feature/SESSION.md) · **What's next?** → [`feature/todos/README.md`](./feature/todos/README.md) · **Keep docs fresh:** [`feature/MAINTAIN.md`](./feature/MAINTAIN.md)

---

## Name: Enfold.baby

**Display name:** **Enfold**  
**Site:** [enfold.baby](https://enfold.baby)  
**Bundle ID:** `baby.enfold.app` (keep until a new Play listing is created)  
**Tagline:** *Grow with confidence.* / *From bump to toddler.*

`due.enfold.baby` is a separate countdown site — do not rename or redeploy it from this repo.

---

## Mission

A **free** Flutter app for parents — pregnancy through ~3 years — that helps families:

1. **Log** feeds, diapers, sleep, meds (2 taps at 3am)
2. **Learn** doctor-reviewed "is this normal?" content
3. **Reassure** before panic — when to watch vs when to call
4. **Share** with partner / caregivers in real time
5. **Export** a simple PDF for pediatric visits

**Not a diagnosis tool.** Educational companion reviewed by physicians.

### Why this exists

- Parents flood doctors with simple fears because they don't know what's normal
- Wife is a **neonatologist**; network of neonat + pediatricians will review content
- App will be **fully free** for parents worldwide
- Builders are also parents — dogfood the product

---

## Unfair advantages (moat)

| Advantage | Why it matters |
|---|---|
| Neonatology expertise | NICU, preemies, discharge teaching — underserved in consumer apps |
| Pediatrician review network | Trust + medically sound triage content |
| Free forever (core) | vs Nara/Huckleberry $5–12/mo |
| Reassurance-first UX | Most apps optimize logging; we optimize *calm* |
| `.baby` domain | Instant brand recognition |

---

## Competitive landscape (research summary, 2026)

| App | Strength | Weakness | Steal | Avoid |
|---|---|---|---|---|
| **Nara Baby** | Clean UI, pregnancy→baby, meds | Paywall, narrow | Visual simplicity | Locking basics |
| **Pebbi** | Multi-carer sync, offline, privacy | Less medical depth | 2-tap log, handover | — |
| **Huckleberry** | Sleep AI predictions | Expensive, anxiety-inducing | — | Prediction guilt |
| **Baby Connect** | Medical PDF export, exhaustive | Ugly, overwhelming | Doctor export | Complexity default |
| **Glow Baby** | Pregnancy continuity, community | Ads, data sharing | Week-by-week | Privacy trade-offs |
| **CDC Milestones** | Free evidence milestones | No daily logging | Milestone source | — |
| **MyPreemie** | NICU-specific | Narrow, dated | Preemie content shape | — |

**Market gap Enfold fills:**  
*Free + beautiful + doctor-backed reassurance + full journey (pregnancy → toddler) + neonat-informed.*

---

## UX principles (non-negotiable)

Research shows baby trackers can **increase postpartum anxiety** when they push obsessive logging (Parents.com, JMIR studies, parent forums).

Enfold must be **calm technology:**

1. **Simple by default** — 3 core logs visible; depth is optional
2. **No guilt** — missed logs get zero shame messages
3. **Reassure before charts** — "You're doing fine" before statistics
4. **Triage not diagnosis** — "Watch for X" / "Call if Y" / "This is common"
5. **2-tap logging at 3am** — one-handed, big targets
6. **Offline-first** — hospitals have bad signal
7. **Partner sync** — both parents see same baby (separate accounts)

---

## User journey phases (one app, shifting UI)

```
┌─────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│  PREGNANCY  │ → │ NEWBORN 0-3m │ → │ INFANT 3-12m │ → │ TODDLER 1-3y │
└─────────────┘   └──────────────┘   └──────────────┘   └──────────────┘
 Week / due date    Feed diaper sleep   Solids milestones   Words behavior
 Kicks symptoms     Warning signs       Growth vaccines     Potty naps
 Appointments       NICU / preemie      Allergies           Tantrums
 Hospital bag       "Is this normal?"   Doctor export       Milestones
```

---

## MVP scope (v0.1 — target 8–12 weeks)

### In scope

| Module | Features |
|---|---|
| **Auth** | Email or anonymous → upgrade; partner invite code |
| **Pregnancy** | Due date, current week, kick counter, appointment notes |
| **Baby profile** | Name, birth date, sex, preemie toggle (corrected age) |
| **Daily log** | Feed (breast L/R, bottle ml), diaper (wet/dirty), sleep (start/end) |
| **Learn** | 25–30 doctor-written cards ("Is this normal?") |
| **Triage** | Simple decision trees → green / yellow / red (call doctor) |
| **Sync** | Real-time partner view of today's log |
| **Export** | 7-day PDF summary for pediatric visit |
| **Settings** | Metric/imperial, language (English first) |

### Out of scope for MVP

- AI sleep predictions
- Community forums
- Wearable integrations
- Romanian localization (v0.2 unless prioritized)
- Monetization / ads

---

## Doctor content pipeline

Content is the product — not an afterthought.

1. **Topic list** — doctors propose 25 MVP topics
2. **Template per card:**
   - Title (parent language)
   - What's normal
   - Watch for (yellow flags)
   - Call doctor if (red flags)
   - Reviewed by [Name, MD] · [Specialty] · [Date]
3. **Review cycle** — quarterly refresh
4. **Storage** — JSON or CMS (Supabase tables / markdown in repo initially)
5. **Disclaimer** on every medical card

### MVP topic starters (neonat/peds)

- How many wet diapers day 1–7?
- Spit-up vs vomiting
- Jaundice — what yellow is OK?
- Cluster feeding — normal or starving?
- Fever in newborn — when is it emergency?
- Reflux vs GERD vs normal
- Umbilical cord care
- NICU discharge — home monitoring
- Preemie corrected milestones
- Breastfeeding vs formula — no guilt framing
- Sleep safety (AAP safe sleep)
- Rash — benign vs concerning
- Crying scales — purple crying period
- Vaccine reactions — expected vs call
- When to go to ER vs call pediatrician

---

## Technical architecture (current)

| Layer | Choice |
|---|---|
| **Framework** | Flutter 3.x · Dart 3.x |
| **Shell** | Today / Logs / Learn / Settings + docked Add FAB |
| **State** | Riverpod |
| **Local DB** | Drift (SQLite) — offline-first, schema v13 |
| **Backend** | VPS FastAPI + PostgreSQL (`api.enfold.baby`) |
| **Auth** | Magic-code email → JWT (SES live from `noreply@enfold.baby`; Graph fallback) |
| **Sync** | Push pending create/edit/delete + pull + periodic while open |
| **Content** | Bundled JSON (`content/cards/`, 25 cards) |
| **PDF export** | `pdf` + `printing` |
| **Push** | FCM live for Android — see `feature/todos/FCM_PARTNER_PUSH.md` |
| **i18n** | English now. RO later: device RO → RO, else EN, Settings override — `feature/todos/I18N_RO.md` |

Full inventory → [`feature/features/STATUS.md`](./feature/features/STATUS.md)

### Suggested project structure

```
enfold/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/           # theme, router, constants
│   ├── features/
│   │   ├── pregnancy/
│   │   ├── baby_log/   # feed, diaper, sleep
│   │   ├── learn/      # education cards
│   │   ├── triage/     # decision trees
│   │   ├── sync/       # partner sharing
│   │   └── export/     # PDF
│   ├── models/
│   ├── services/
│   └── widgets/
├── content/            # doctor-reviewed JSON (git-tracked)
├── assets/
├── android/
├── ios/
└── docs/
```

### Flutter packages (starter set — verify on pub.dev at implementation)

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `drift` + `sqlite3_flutter_libs` | Offline DB |
| `http` | VPS API client |
| `go_router` | Navigation |
| `intl` | Dates, formatting |
| `pdf` / `printing` | Visit export |
| `google_fonts` | Typography |
| `flutter_svg` | Icons/illustrations |

---

## Medical & legal guardrails

| ✅ Do | ❌ Don't |
|---|---|
| "Educational information reviewed by physicians" | Diagnose conditions |
| Named reviewers with credentials + date | Anonymous medical blog tone |
| "When to seek care" checklists | Replace emergency services |
| Prominent disclaimer on app + each card | AI-generated medical advice (v0.1) |
| Geo-aware emergency numbers (v0.2+) | One global "call 911" only |

**Footer disclaimer (draft):**  
*Enfold provides general educational information reviewed by qualified physicians. It does not replace professional medical advice, diagnosis, or treatment. If you think your child has a medical emergency, call your local emergency number immediately.*

---

## Design direction

| Attribute | Direction |
|---|---|
| **Feel** | Calm, warm, trustworthy — not clinical hospital white |
| **Colors** | Soft sage, cream, muted coral accents — avoid alarm-red default |
| **Typography** | Rounded sans (e.g. Nunito, DM Sans) — readable at 3am |
| **Iconography** | Simple line icons — feed, moon, droplet |
| **Dark mode** | Yes — parents log at night |
| **Accessibility** | Large tap targets (48dp+), screen reader labels |

---

## Monetization

**v0.1 → v1.0: free.** Mission-first.

Future options (only if needed for sustainability):
- Institutional partnerships (hospitals distribute app)
- Grants / NGO funding
- Optional “plant a moon” tip on the **website** (`/support/`) via Stripe — never ads in the app
- **Never:** ads, selling baby data, paywalling safety content

---

## Roadmap sketch

| Version | Focus |
|---|---|
| **0.1** | Core app — **mostly shipped** (see `feature/features/STATUS.md`) |
| **0.2** | Growth history charts (shipped), Romanian i18n, sync polish |
| **0.3** | NICU/preemie module, fever log |
| **0.4** | Toddler phase, potty, behavior |
| **1.0** | Play Store + App Store public listing (`enfold.baby` landing already live) |

Detailed roadmap → [`feature/roadmaps/VERSION.md`](./feature/roadmaps/VERSION.md)

---

## Open questions for founders (answer in fresh chat)

1. **Display name:** Enfold (locked)
2. **MVP languages:** English now; Romanian later per `feature/todos/I18N_RO.md` (locked plan, not built)
3. **Auth:** Require account day 1, or anonymous → optional account?
4. **First platform test device:** Android (S24) same as Please Don't?
5. **Doctor content:** Who writes first 25 cards? Timeline?
6. **Preemie/NICU in MVP?** Or v0.3? (Recommend v0.3 unless wife insists MVP)

---

## First implementation steps (historical — the app exists)

The Flutter app, API, and landing are already in this repo. Resume from `feature/SESSION.md`. The list below is the original kickoff order, kept for context.

## Original kickoff order

1. `flutter create` project in this folder (`enfold` package name)
2. Bundle ID: `baby.enfold.app`
3. Theme + router shell
4. Drift schema: `Baby`, `FeedLog`, `DiaperLog`, `SleepLog`
5. One 3am log screen (prove UX)
6. One learn card screen (prove content model)
7. Supabase project + partner invite spike
8. Doctor content JSON schema + 3 sample cards

---

## Related projects (same monorepo parent)

| Project | Path | Domain |
|---|---|---|
| Please Don't (game) | `../please_dont` | globinary.games |
| Enfold.baby | this folder | enfold.baby |

Separate repos within `globinary-games-grok` workspace — no code sharing required initially.

---

## Fresh conversation prompt (copy-paste)

```
I'm building Enfold.baby — read feature/SESSION.md, feature/PICKUP.md, feature/todos/README.md.
Domain: enfold.baby. Pick up where we left off.
Update feature/SESSION.md and related docs as we ship work (see feature/MAINTAIN.md).
```

---

*Created: 2026-06-30 · Author: Grok + founder session*