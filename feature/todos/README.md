# Todos — what to work on next

> Prioritized pending work. For implemented features see [features/STATUS.md](../features/STATUS.md).  
> **Focus now:** launch posts on every platform (`LAUNCH_POSTS.md`), Google Play promotion, Romanian UI. Keep docs current as we ship.

## Queue

| Priority | Item | Doc | Effort |
|---|---|---|---|
| ✅ | ~~No past dates while expecting~~ | [DATE_PICKER_NO_PAST.md](./DATE_PICKER_NO_PAST.md) | 2026-08-10 |
| ✅ | ~~Pull-to-refresh sync on Today~~ | — | 2026-08-10 |
| ✅ | ~~Account switching / local data isolation~~ | [ACCOUNT_SWITCHING.md](./ACCOUNT_SWITCHING.md) | schema v10 |
| ✅ | ~~Sync delete + edit to server~~ | [SYNC_UPDATES.md](./SYNC_UPDATES.md) | 2026-07-08 |
| ✅ | ~~FCM partner activity push (client + API)~~ | [FCM_PARTNER_PUSH.md](./FCM_PARTNER_PUSH.md) | Live 2026-09 |
| ✅ | ~~SES from noreply@enfold.baby~~ | [SES_MAIL.md](./SES_MAIL.md) | Live 2026-09-07 |
| ✅ | ~~4-tab shell + docked Add FAB~~ | — | 2026-09 |
| ✅ | ~~Growth history trend charts~~ | — | 2026-09 |
| 🟠 P1 | **Launch posts everywhere** | [LAUNCH_POSTS.md](./LAUNCH_POSTS.md) | Copy + assets prepared, Raul posts |
| 🟠 P1 | **Google Play: promote from main once 22 is live** | [STORE_RELEASE.md](./STORE_RELEASE.md) | Then Play badge on the site |
| 🟠 P2 | **Romanian UI** | [I18N_RO.md](./I18N_RO.md) | gen-l10n + ARB, ~280 strings, 2 to 3 sessions |
| 🟠 P2 | **Learn card physician review** | [CONTENT_REVIEW.md](./CONTENT_REVIEW.md) | Pack sent to Oana 2026-09-17 |
| 🟠 P2 | **Multiple children per family** | [MULTI_CHILD.md](./MULTI_CHILD.md) | Active child switcher |
| 🟡 P3 | **Real-time partner sync** | — | Websocket or denser pull |
| 🟡 P3 | Replace Adobe-derived illustrations with original art | — | Then drop the carve-out in LICENSE-NOTES.md |
| 🟡 P3 | Riverpod 3 / go_router 18 / notifications 22 migration | — | Dependabot ignores majors on purpose |
| 🟢 P4 | Anonymous-first auth | [roadmaps/VERSION.md](../roadmaps/VERSION.md) | Medium |
| 🟢 P4 | iOS TestFlight + APNs key | [FCM_PARTNER_PUSH.md](./FCM_PARTNER_PUSH.md) | Apple Developer |
| 🟢 P4 | 2×/day + short med courses | [roadmaps/VERSION.md](../roadmaps/VERSION.md) | After daily vitamin reminder |

Sideload APK installer was **removed** for Play policy (see [APP_VERSION_UPDATE.md](./APP_VERSION_UPDATE.md)). Store updates will replace it.

## How to pick up any item

1. Read [SESSION.md](../SESSION.md)  
2. Open [PICKUP.md](../PICKUP.md) if you want a copy-paste prompt  
3. Read the linked todo doc  
4. Run `flutter test` before and after  
5. On finish → [MAINTAIN.md](../MAINTAIN.md) — **always update markdown**

## Recently completed ✅

- Today sleep total clipped to the calendar day; overnight in-progress sleep stays on Today (2026-09-18, not yet in a store build)
- Learn card citations ("Sources" section, 53 verified links) after Apple's 1.4.1 rejection; build 27 approved, App Store live (2026-09-17)
- Open source: repo public under `enfold-baby/enfold`, AGPL-3.0, community files, CI, security features, org profile, site updated (2026-09-17)
- Backend auth abuse limits, JWT secret guard, Dependabot bumps deployed (2026-09-17)
- Stripe plant-a-moon links: 4 live + 4 sandbox Payment Links, supporters wall and galaxy live (2026-09-12)
- Daily vitamin reminder (one time of day, Today Given, local ping, no streak) — Drift v13, 2026-09-10
- 12-hour (AM/PM) vs 24-hour clock in Settings (Drift v12, 2026-09-09)
- Docs catch-up for working-tree UX (2026-09-09)
- 4-tab shell (Today / Logs / Learn / Settings) + center-docked Add FAB + quick-add sheet
- Growth measurement history trend charts
- Care-log date picker bounds (3 years back … tomorrow)
- Pull-to-refresh on Logs / Growth / Settings (not only Today)
- Leave family + caregiver profile (Mom/Dad/name)
- Today dark illustration (no multiply overlay), PDF confirm dialog, sleep start–end times, milestone date, evening check-in toggle (2026-09-08)
- SES from `noreply@enfold.baby` (eu-central-1) — Graph remains fallback (2026-09-07)
- Public site copy: no get-beta / download CTAs; launch-notify for Play then iOS (2026-09-07)
- Support page `/support/` — share, plant-a-moon, credits (2026-09-07)
- Sleep still-sleeping + backdated start; Today active-sleep banner
- Dark-mode secondary text contrast (WCAG AA)
- Magic-code Graph fallback (SMTP 535)
- FCM Android + iOS client files + VPS HTTP v1 sender (`enfold-28c4e`)
- Play blockers: upload JKS, no `REQUEST_INSTALL_PACKAGES`, in-app account delete, legal URLs
- Enfold rebrand (product-facing BloomDue gone; VPS user/paths stay bloomdue)
- Account switching isolation (Drift v10)
- Pull-to-refresh · open startup `/open` + `/roadmap`
- Landing legal pages + launch-notify form (Play soon, iOS shortly after)
- Sync delete + edit, partner attribution + nudge
- Growth, meds, pumping, tummy, 25 learn cards, soft delete
