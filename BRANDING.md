# BloomDue — Brand & Product Decisions

> Locked 2026-07-01 · Domain: [bloomdue.baby](https://bloomdue.baby)

## Identity

| Field | Value |
|---|---|
| **Product name** | BloomDue |
| **Domain** | bloomdue.baby |
| **Tagline** | Grow with confidence. |
| **Subtitle** | Calm baby care, from bump to toddler |
| **Bundle ID** | `baby.bloomdue.app` |
| **Dart package** | `bloomdue_baby` (folder name; can rename later) |
| **Store listing** | BloomDue |
| **MVP language** | English only (i18n scaffold later) |
| **Auth** | Anonymous first → optional account for sync |
| **Test device** | Pixel 8 emulator (Android Studio) |

## Subdomains (do not mix)

| URL | Purpose | Status |
|---|---|---|
| `bloomdue.baby` | App marketing landing | Live — static nginx |
| `due.bloomdue.baby` | Shareable due-date countdown | Live — **do not touch** |

## Color palette

Aligned with `due.bloomdue.baby` for family brand consistency.

| Token | Hex | Use |
|---|---|---|
| `cream` | `#FAF7F2` | Backgrounds |
| `creamDeep` | `#F3EDE4` | Cards, elevated surfaces |
| `bark` | `#3D3229` | Primary text |
| `barkSoft` | `#6B5E54` | Secondary text |
| `sage` | `#5C7F71` | Primary actions, trust |
| `sageDeep` | `#4A675C` | Pressed / links |
| `bloom` | `#C96B7E` | Accent, warmth, highlights |
| `bloomDeep` | `#A85568` | Accent pressed |
| `sleepBlue` | `#7A8FA8` | Sleep log category |

## Typography

| Role | Font | Weight |
|---|---|---|
| Display | Fraunces | 600–700 |
| Body / UI | Nunito | 400–800 |

Flutter: `google_fonts` package.

## UX principles (non-negotiable)

1. Two taps at 3am — big targets (48dp+)
2. Reassure before charts
3. No guilt for missed logs
4. Offline-first
5. Triage language: watch / call / common — never diagnose
6. Dark mode from day one (parents log at night)

## Backend architecture (locked direction)

| Layer | Choice | Notes |
|---|---|---|
| **API** | VPS FastAPI (`bloomdue-platform` on 135.125.226.37) | Already has `/v1/care-events`, auth, children |
| **Database** | PostgreSQL on VPS | `care_events`, `children`, `families`, `users` |
| **Email** | AWS SES · `noreply@bloomdue.baby` | Magic-link codes live on API now; SES sender swap planned |
| **API base** | `https://api.bloomdue.baby` | Auth, children, care-events sync |
| **Mobile** | Offline-first Drift SQLite | `pending_sync` flag until API push |

App talks to **our VPS API**, not Supabase. Local Drift schema mirrors server `care_events.type` (`feeding`, `diaper`, `sleep`).

## App build phases

1. **Phase 0** — Theme, router shell, folder structure ✅
2. **Phase 1** — 3am log screen ✅
3. **Phase 2** — Drift DB + Riverpod ✅
4. **Phase 3** — Learn cards + triage (JSON content) ✅
5. **Phase 4** — VPS API sync + magic-link auth (AWS SES) ✅
6. **Phase 5** — PDF export + pregnancy basics ✅
7. **Phase 6** — Baby profile + optional log detail ✅
8. **Phase 7** — Partner invite UX + bidirectional sync ✅
9. **Phase 8** — First-run onboarding ✅
10. **Phase 9** — Learn content expansion (10 MVP cards, pending physician review) ✅
11. **Phase 10** — Complete MVP Learn library (15 cards + ER triage flow) ✅
12. **Phase 11** — Metric / imperial volume toggle (ml storage, fl oz display) ✅
13. **Phase 12** — Learn search / filter ✅
14. **Phase 13** — Learn beta library (25 cards, pending physician review) ✅
15. **Phase 14** — Beta version bump + build config (`0.1.0+1`, About screen) ✅
16. **Phase 15** — Extended logs (medication, pumping, tummy time) ✅
17. **Phase 16** — Growth measurements + milestones ✅
18. **Phase 17** — Soft delete / restore for care logs ✅
19. **Phase 18** — Partner sharing + bidirectional sync ✅
20. **Phase 19** — Last logged by + gentle partner nudge ✅
21. **Phase 20** — FCM push scaffold (no Firebase project yet) 🟡
22. **Phase 21** — Landing v3 + legal pages + join-beta form (SMTP) ✅
23. **Phase 22** — Sync edit/delete, theme persist, sideload APK `0.1.0+9` ✅

**Docs hub:** [`feature/README.md`](./feature/README.md)

## Beta release (v0.1.x)

| Field | Value |
|---|---|
| **Marketing version** | `0.1.0` (private beta — `0.x` shows beta badge in Settings) |
| **Build number** | `9` — increment `+N` in `pubspec.yaml` before each store upload |
| **Bundle ID** | `baby.bloomdue.app` |
| **API** | `https://api.bloomdue.baby` |
| **Legal** | https://bloomdue.baby/privacy/ · https://bloomdue.baby/terms/ |

### Build commands

```bash
./scripts/build_beta.sh          # test + Android AAB + APK
flutter build ipa --release      # iOS TestFlight (macOS + signing)
```

| Artifact | Path |
|---|---|
| Play AAB | `build/app/outputs/bundle/release/app-release.aab` |
| Sideload APK | `build/app/outputs/flutter-apk/app-release.apk` |

**Signing notes:** Android release currently uses debug keystore (fine for internal testing). Swap to release keystore before open beta. iOS requires Apple Developer signing for TestFlight.

## Landing page

Source: `landing/public/` in this repo.  
Deployed to VPS `bloomdue-platform-landing` container.  
Redeploy: `SSHPASS='…' ./landing/deploy.sh` (SSH as `u_bloomdue@135.125.226.37`).  
Analytics: SimpleAnalytics (`scripts.simpleanalyticscdn.com/latest.js`) — no cookie banner.  
Beta signup: `#join-beta` form → `POST https://api.bloomdue.baby/v1/beta-requests`.