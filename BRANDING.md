# Enfold.baby — Brand & Product Decisions

> Rebranded 2026-09 · Domain: [enfold.baby](https://enfold.baby)

## Identity

| Field | Value |
|---|---|
| **Product name** | Enfold |
| **Domain** | enfold.baby |
| **Tagline** | Grow with confidence. |
| **Subtitle** | Calm baby care, from bump to toddler |
| **Bundle ID** | `baby.enfold.app` |
| **Dart package** | `enfold` (folder name; internal) |
| **Store listing** | Enfold |
| **MVP language** | English now. Later: device RO → RO, else EN, Settings can force RO |
| **Auth** | Anonymous first → optional account for sync |
| **Test device** | Pixel 8 emulator (Android Studio) |

## Subdomains (do not mix)

| URL | Purpose | Status |
|---|---|---|
| `enfold.baby` | App marketing landing | Live — static nginx |
| `due.enfold.baby` | Shareable due-date countdown | Live |

## Color palette

Aligned with `due.enfold.baby` for family brand consistency.

| Token | Hex | Use |
|---|---|---|
| `cream` | `#FAF7F2` | Backgrounds |
| `creamDeep` | `#F3EDE4` | Cards, elevated surfaces |
| `bark` | `#3D3229` | Primary text (light) |
| `barkSoft` | `#6B5E54` | Secondary text (light only) |
| `sage` | `#5C7F71` | Primary actions, trust (light) |
| `sageDeep` | `#4A675C` | Pressed / links (light) |
| `bloom` | `#C96B7E` | Accent, warmth, highlights |
| `bloomDeep` | `#A85568` | Accent pressed |
| `sleepBlue` | `#7A8FA8` | Sleep log category |
| `night` | `#141A17` | Dark background |
| `nightElevated` | `#1E2723` | Dark cards / nav |
| `nightCard` | `#28322E` | Dark inset surfaces |
| `nightMuted` | `#DCE6E1` | Secondary text (dark) |
| `nightAccent` | `#9ECBB5` | Sage ink on dark (labels, icons) |

Use `AppColors.mutedText(brightness)` and `AppColors.accent(brightness)` — never `barkSoft` or `sage` as dark-mode text. WCAG AA is 4.5:1 for body/secondary copy (parents log at 3am).

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
| **API** | VPS FastAPI (single OVH VPS) | `/v1/care-events`, auth, children |
| **Database** | PostgreSQL on VPS | `care_events`, `children`, `families`, `users` |
| **Email** | SES live · Graph fallback | Codes send from `Enfold <noreply@enfold.baby>` via AWS SES (`eu-central-1`). Graph remains fallback. SMTP still 535s (`feature/todos/SES_MAIL.md`) |
| **API base** | `https://api.enfold.baby` | Auth, children, care-events sync |
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
21. **Phase 20** — FCM partner push (Android + VPS sender live) ✅
22. **Phase 21** — Landing v3 + legal pages + launch-notify form ✅
23. **Phase 22** — Sync edit/delete, theme persist, Play upload keystore ✅
24. **Phase 23** — Dark-mode secondary contrast (WCAG AA) ✅
25. **Phase 24** — Sleep still-sleeping + Today banner ✅
26. **Phase 25** — Support page `/support/` (share, plant-a-moon, credits) ✅
27. **Phase 26** — Graph mail fallback; SES from `noreply@enfold.baby` live ✅
28. **Phase 27** — Public site: launch-notify (Play soon, iOS shortly after) ✅
29. **Phase 28** — 4-tab shell + docked Add FAB; Pregnancy off the tab bar ✅
30. **Phase 29** — Growth measurement history trend charts ✅
31. **Phase 30** — Care-log date picker bounds (3 years back … tomorrow) ✅
32. **Phase 31** — 12-hour vs 24-hour clock in Settings (Drift v12) ✅
33. **Phase 32** — Daily vitamin reminder (one time of day, no streak) ✅
34. **Phase 33** — Open source: `enfold-baby/enfold` public under AGPL-3.0, site and /open updated (2026-09-17) ✅
35. **Phase 34** — Learn card citations ("Sources" on every card); App Store 1.0.1 approved and live ✅
36. **Phase 35** — Today sleep total clipped to the calendar day ✅
37. **Phase 36** — Launch: Product Hunt, X and dev.to (2026-09-21/23) ✅
38. **Phase 37** — Romanian UI: gen-l10n, 603 ARB keys, Settings > Language, Android 15 edge-to-edge, build 1.0.2+28 (Drift v16) ✅

**Docs hub:** [`feature/README.md`](./feature/README.md)

## First public release (v1.0.0)

| Field | Value |
|---|---|
| **Marketing version** | `1.0.0` |
| **Build number** | `20` — increment `+N` in `pubspec.yaml` before each store upload |
| **Bundle ID** | `baby.enfold.app` |
| **API** | `https://api.enfold.baby` |
| **Legal** | https://enfold.baby/privacy/ · https://enfold.baby/terms/ |

### Build commands

```bash
./scripts/build_beta.sh          # test + Android AAB + APK
flutter build ipa --release      # iOS TestFlight (macOS + signing)
```

| Artifact | Path |
|---|---|
| Play AAB | `build/app/outputs/bundle/release/app-release.aab` |
| Sideload APK | `build/app/outputs/flutter-apk/app-release.apk` |

**Signing notes:** Android **upload** keystore is `android/upload-keystore.jks` + gitignored `android/key.properties`. Play App Signing holds the distribution key. iOS still needs Apple Developer / TestFlight.

Sideload APKs: `~/Desktop/enfold-1.0.0-N.apk` (latest **+20**). In-app APK installer was removed for Play policy.

## Landing page

Source: `landing/public/` in this repo.  
Deployed to the VPS landing container.  
Redeploy: `SSHPASS='…' ./landing/deploy.sh` (host and user from the private ops env).  
Analytics: SimpleAnalytics — no cookie banner.  
Launch notify: `#notify` form (`#join-beta` still works) → `POST https://api.enfold.baby/v1/beta-requests`. Copy is **Google Play soon, iOS shortly after** — no store URLs, no sideload/download CTAs.  
Help / support: [https://enfold.baby/support/](https://enfold.baby/support/) — share, plant a moon (Stripe pending), credits. No ads in the app.