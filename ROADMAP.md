# Bloomdue Roadmap

Bloomdue is a free, no-ads baby and pregnancy companion for parents. The first release starts after birth with practical daily tracking, then expands into medical records, guided doctor-reviewed education, and pregnancy workflows.

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

- Age-based educational cards and checklists in English and Romanian.
- Red-flag educational content with clear escalation wording.
- Content review workflow for neonatology, gynecology, and pediatrics contributors.

## Phase 4: Pregnancy Tracker

- Due date, appointment planning, pregnancy timeline, preparation checklists, and postpartum transition into the baby tracker.
- UX: while still **expecting**, date pickers (due date, appointments) should not allow past calendar dates → see `feature/todos/DATE_PICKER_NO_PAST.md`.

## Launch Criteria

- Parents can log in, create a baby profile, log care events offline, reconnect, and sync safely.
- Every medical or safety-related text is reviewed and versioned.
- Privacy policy, terms, data deletion, export, and support paths are ready before public launch.
