# Enfold Roadmap

Enfold is a free, no-ads baby and pregnancy companion for parents. The first release starts after birth with practical daily tracking, then expands into medical records, guided doctor-reviewed education, and pregnancy workflows.

**Now (2026-09-13):** `1.0.0+22` submitted to Google Play on 2026-09-12 and in review (managed publishing off, goes live on approval). Site copy says "in review". Stripe: 4 live + 4 sandbox payment links collecting name, optional company, billing address and a tax ID custom field; supporters wall on `/support/` and `/galaxy/` fed by a signature-verified Stripe webhook (`ops/README.md`). Pickup file for launch work: `~/Desktop/LAUNCH-CHECKLIST.md`. Next: wait for the review, then the Play badge on the site and the launch posts (checklist section 8). Romanian is planned, not started (`feature/todos/I18N_RO.md`). Built for the next update (1.0.1+23, after 1.0.0+22 is live): "Time awake" on Today with a Settings switch, on branch `feature/awake-time`. iOS: App ID, APNs key (in Firebase) and signing are set up; `ios/release.sh` builds a distribution-signed IPA with push (add `--upload` once the App Store Connect record exists). App Store: "Enfold: Baby Tracker" (app id 6811765288) 1.0.1 (24) submitted for review 2026-09-14; Android update 1.0.1+24 to follow once 1.0.0+22 is live.

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
