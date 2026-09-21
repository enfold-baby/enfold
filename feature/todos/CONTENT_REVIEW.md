# Todo — learn card physician review

> **Priority:** P2 · **Status:** review pack sent to Raul for Oana on 2026-09-17 (`~/Documents/enfold/review/learn-cards-review-pack-2026-09-17.docx`, urgent cards first). Every card already carries a `sources` list (public citations). Cards are public on GitHub, so sign-offs land in public.

## Content inventory

- **25 cards** listed in [`content/manifest.json`](../../content/manifest.json)
- JSON per card in `content/cards/*.json`
- Each card should include: what's normal, watch for, call doctor if, reviewer metadata

## Review workflow (proposed)

1. Export card list for reviewers (title + slug)
2. Neonatologist / pediatrician reviews each card
3. Update JSON with:
   ```json
   "reviewed_by": "Dr. Name",
   "credentials": "MD, Neonatology",
   "reviewed_at": "2026-MM-DD"
   ```
4. Quarterly refresh cycle noted in app disclaimer

## App integration

- `MedicalDisclaimer` widget already on card screens
- Filter/search in Learn tab works
- No CMS yet — cards ship in app bundle

## Verify

- [ ] Every card has reviewer name + date in JSON
- [ ] Triage trees reviewed for red-flag accuracy
- [ ] Disclaimer matches [`BRANDING.md`](../../BRANDING.md) legal guardrails

## Not blocking

App is usable for private beta while review is in progress. Block **public** v1.0 launch until complete.