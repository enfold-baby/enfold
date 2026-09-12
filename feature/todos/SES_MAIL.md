# Todo — SES mail from noreply@enfold.baby

> **Priority:** P1 · **Status:** Live (2026-09-07)  
> **Today:** AWS SES sends first as `Enfold <noreply@enfold.baby>`. Graph remains the fallback. SMTP still 535s.

## What’s true

- AWS SES identity **`noreply@enfold.baby` is verified** in the FormKiosk AWS account (`249896948742`, `eu-central-1`).
- IAM user `enfold-ses-send` can `ses:SendEmail` / `ses:SendRawEmail` on identity `enfold.baby`.
- Keys live in VPS `.env` (`SES_REGION=eu-central-1`). Do not print them.
- Probe send to `raulgldn@gmail.com` returned **SES_OK** (SES MessageId, not Graph).

## Fallback order

`backend/app/services/email.py`: **SES → Graph → SMTP**.

## Already in code

- `POST /v1/auth/magic-code/request` — 503 if every provider fails
- Launch-notify form mail uses the same sender
- From address: `Enfold <noreply@enfold.baby>` · Reply-To `support@enfold.baby`
