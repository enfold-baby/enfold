# Todos — what to work on next

> Prioritized pending work. For implemented features see [features/STATUS.md](../features/STATUS.md).  
> **Focus now:** Play listing leftovers, Stripe help-page links. Keep docs current as we ship.

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
| 🟠 P1 | **Play listing leftovers** | [STORE_RELEASE.md](./STORE_RELEASE.md) | Screenshots, Data safety, AAB upload |
| 🟠 P2 | **Stripe plant-a-moon links** | [STRIPE_SUPPORT.md](./STRIPE_SUPPORT.md) | Payment Link URLs |
| 🟠 P2 | **Multiple children per family** | [MULTI_CHILD.md](./MULTI_CHILD.md) | Active child switcher |
| 🟡 P3 | **Learn card physician review** | [CONTENT_REVIEW.md](./CONTENT_REVIEW.md) | Human in the loop |
| 🟡 P3 | **Real-time partner sync** | — | Websocket or denser pull |
| 🟢 P4 | **Romanian i18n** | [I18N_RO.md](./I18N_RO.md) | Plan locked; sleep on it |
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
