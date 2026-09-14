# Enfold Roadmap

Enfold is a free, no-ads baby and pregnancy companion for parents. The first release starts after birth with practical daily tracking, then expands into medical records, guided doctor-reviewed education, and pregnancy workflows.

**Now (2026-09-14):** Google Play: `1.0.0+22` in production review since 2026-09-12 (managed publishing off); `1.0.1+24` is on internal testing, promote it to production once 22 is live (a new production release would restart that review). App Store: "Enfold: Baby Tracker" (app id 6811765288; plain "Enfold" is taken) `1.0.1 (24)` submitted for review 2026-09-14, automatic release on approval; TestFlight internal group "Raul's devices" (Raul, Oana) has builds 23 to 25. iOS release: `./ios/release.sh [--upload]` (cloud signing via the App Store Connect API key; iOS minimum 15.0 since build 25). 1.0.1 adds time awake on Today, full history on a reinstall sign-in, the child profile sync fix, the onboarding layout fix and quiet background sync. Stripe: 4 live + 4 sandbox payment links, supporters wall on `/support/` and `/galaxy/` fed by a signature-verified webhook (`ops/README.md`); the end-to-end sandbox test is still to do (prompt in `feature/PICKUP.md`). Store listing text and answers: `assets/brand/store/app-store-listing.md`. Pickup file for launch work: `~/Desktop/LAUNCH-CHECKLIST.md`. Next: the Stripe sandbox test, wait for both store reviews, then the Play and App Store badges on the site and the launch posts (checklist section 8). Romanian is planned, not started (`feature/todos/I18N_RO.md`).

## Phase 0: Foundation

- Create the Docker-only FastAPI backend with Postgres, Redis, Alembic migrations, Caddy, and dev/prod Compose files.
- Replace the generated Flutter counter app with a real app shell using Riverpod, GoRouter, and local SQLite/Drift storage.
- Define privacy, safety, and medical-content boundaries: the app records, organizes, reminds, and educates; it does not diagnose or prescribe.

## Phase 1: Daily Care Log

- Parent account with email magic-code auth.
- Family and child profile setup.
- Offline-first care event timeline for feeding, diaper, sleep, pumping, medication/vitamin, and notes.
- Background sync queue with server timestamps and conflict rules.
- Push/local reminders for routines without health-data targeting or ads.

## Phase 2: Medical Record Hub

- Growth records, vaccines, appointments, doctor notes, and document attachments.
- Export/share summary for pediatric visits.
- Doctor-reviewed templates for common newborn follow-up topics.

## Phase 3: Guided Care Program

- Age-based educational cards and checklists in English first; Romanian later (`feature/todos/I18N_RO.md`).
- Red-flag educational content with clear escalation wording.
- Content review workflow for neonatology, gynecology, and pediatrics contributors.

## Phase 4: Pregnancy Tracker

- Due date, appointment planning, pregnancy timeline, preparation checklists, and postpartum transition into the baby tracker.
- UX: while still **expecting**, date pickers (due date, appointments) should not allow past calendar dates → see `feature/todos/DATE_PICKER_NO_PAST.md`.

## Launch Criteria

- Parents can log in, create a baby profile, log care events offline, reconnect, and sync safely. *(sync create/edit/delete live in private beta)*
- Every medical or safety-related text is reviewed and versioned. *(learn cards: formal sign-off pending)*
- Privacy policy, terms, data deletion, export, and support paths are ready before public launch. *(privacy + terms + `/support/` live; in-app account delete live; Play upload keystore ready; listing screenshots still needed)*
