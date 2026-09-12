# Enfold — feature docs hub

> **Last updated:** 2026-09-10 · **App version:** `1.0.0+20` · **Drift schema:** v13  
> **Prod:** landing + API live · support page live · FCM sender live · SES mail live

Central index for what's built, what's next, and how to resume work.

| Doc | Purpose |
|---|---|
| [SESSION.md](./SESSION.md) | **Where we left off** — read first every new session |
| [PICKUP.md](./PICKUP.md) | Copy-paste prompts by topic |
| [MAINTAIN.md](./MAINTAIN.md) | How to keep docs current (end-of-session checklist) |
| [features/STATUS.md](./features/STATUS.md) | Implemented modules, screens, API, infra |
| [roadmaps/VERSION.md](./roadmaps/VERSION.md) | Version roadmap (0.1 → 1.0) |
| [todos/README.md](./todos/README.md) | Pending work queue (prioritized) |

## Also read

| Doc | Location |
|---|---|
| Project kickoff & mission | [`START_HERE.md`](../START_HERE.md) |
| Brand, colors, build phases | [`BRANDING.md`](../BRANDING.md) |
| Learn card content | [`content/manifest.json`](../content/manifest.json) (25 cards) |
| Root README | [`README.md`](../README.md) |

## Quick status

| Area | Status |
|---|---|
| App shell | ✅ 4 tabs (Today / Logs / Learn / Settings) + docked Add FAB |
| Time format | ✅ Settings: 12-hour (AM/PM) or 24-hour |
| Core logging (feed / diaper / sleep) | ✅ Still-sleeping + backdated start + date bounds |
| Extended logs (meds / pump / tummy) | ✅ Daily vitamin reminder (one time of day) |
| Growth + milestones | ✅ History trend charts (not WHO percentiles) |
| Pregnancy | ✅ Full-screen route (not a tab) |
| Learn + triage (25 cards) | ✅ Physician review pending |
| Partner sharing + sync (create/edit/delete) | ✅ Leave family + caregiver profile |
| Last logged by + gentle nudge | ✅ |
| FCM activity push | ✅ Wired (Android client + VPS sender). iOS needs APNs key |
| Magic-code email | ✅ SES live from `noreply@enfold.baby`; Graph fallback |
| Landing + legal + launch-notify form | ✅ Google Play soon, iOS shortly after |
| Help / support / credits | ✅ https://enfold.baby/support/ — Stripe links pending |
| Play upload path | ✅ Upload keystore + AAB. Screenshots / listing still needed |
| Romanian i18n | 🔲 Plan locked, not started |
| Store listing live | 🔲 Play next · iOS TestFlight later |

## Continue work

Open [SESSION.md](./SESSION.md) → [todos/README.md](./todos/README.md). **Update markdown whenever we ship** ([MAINTAIN.md](./MAINTAIN.md)).
