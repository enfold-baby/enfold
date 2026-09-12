# Privacy And Safety

Enfold handles sensitive family and child health-adjacent data. The product should be built as a trust-first service.

## Defaults

- No ads and no ad SDKs.
- No third-party health-data targeting.
- Minimal analytics until a self-hosted privacy-preserving option is explicitly chosen.
- Clear data export and deletion workflows before public launch. **In-app account deletion** is live (Settings → Delete my account → `DELETE /v1/auth/me`). PDF export is live.
- Encrypt transport with HTTPS in production (`https://api.enfold.baby`).
- Store secrets only in environment files or deployment secret stores, never in source (`google-services.json`, Firebase SA, SES keys, Stripe secrets are gitignored).
- No ads in the app. Optional website tips on `/support/` (Stripe, not an in-app ad SDK).
- Landing analytics: Simple Analytics only (no cookie banner).

## Medical Scope

Enfold v1 is a tracking and education app. It does not diagnose, prescribe, triage, or replace clinical care.
