# Last session

**Date:** 2026-09-22 (launch session 2026-09-21 and 22; last app code change 2026-09-18)  
**Version:** `1.0.1+27` · Drift schema **v14** · 208 tests passing  
**API:** `https://api.enfold.baby` · local `http://127.0.0.1:8282` (emulator `http://10.0.2.2:8282`)  
**Contact:** `support@enfold.baby`  
**Display:** Enfold (App Store name "Enfold: Baby Tracker") · bundle `baby.enfold.app`  
**Code:** public, https://github.com/enfold-baby/enfold (AGPL-3.0, see `LICENSE-NOTES.md`)

## Where things stand

- **App Store: LIVE.** 1.0.1 (27) approved after the 1.4.1 citations fix; listing at https://apps.apple.com/us/app/enfold-baby-tracker/id6811765288 (App Store Connect state READY_FOR_DISTRIBUTION, checked 2026-09-21).
- **Google Play: not public yet.** Production 1.0.0+22 submitted 2026-09-12, still "In review" on 2026-09-22 with no rejection, no policy flag, listing 404. Support ticket filed 2026-09-22 (App publishing, reply by email within 15 days to contact@ mailbox). When 22 goes live, promote a build from current `main` (build 28: citations, sleep fix, add the edge-to-edge tweak Play recommends for Android 15), not 24.
- **Open source since 2026-09-17.** Org `enfold-baby`, repo `enfold`, AGPL-3.0 + app store covenant, learn cards CC BY-NC-ND, brand and illustrations reserved (`TRADEMARK.md`). CI, Dependabot (minor/patch only), secret scanning, branch ruleset on `main`, org profile, verified domain, Sponsor button. Launch thread on X: https://x.com/Gl0deanR/status/2100594197900181840.
- **Launch (2026-09-21/22):** Product Hunt scheduled by Raul for Wed 2026-09-23 00:01 PT (10:01 Romania), profile @raulglodean, page producthunt.com/products/enfold; X post for PH day scheduled 10:05 Romania. dev.to article live since 2026-09-21 15:00 (dev.to/gl0deanr), X follow-up posted 2026-09-22 and a reply in the pinned thread. Reddit skipped (r/opensource auto-removed the post for low karma). TrustMRR page live at trustmrr.com/startup/enfold with a read-only Stripe key. Raul's call: only PH, X, dev.to; Peerlist, HN, Indie Hackers, LinkedIn parked with copy kept in `feature/todos/LAUNCH_COPY.md`.
- **FormKiosk iOS 1.0** (separate app, same Apple account): had sat Rejected since 2026-09-13 because a reply to an Information Needed request does not requeue; resubmitted 2026-09-22, Waiting for Review.
- **Site** says open source everywhere and links the App Store; Play badge waits for Play approval.

## Done recently

- **Learn sources (build 27):** every card has a `sources` list (53 verified AAP / NHS / WHO / CDC links) rendered as a tappable "Sources" section; `test/features/learn/learn_sources_test.dart` fails the build if a card ships without one. This was Apple's Guideline 1.4.1 rejection.
- **Today sleep total:** an overnight sleep is clipped to the calendar day (22:00 to 02:00 counts 2h on the second day); a sleep still running since last night stays on Today and counts from midnight (`entriesForToday`, `TodaySummary.sleepInterval`). Not yet in a store build.
- **Backend:** magic-code brute-force cap and per-email / per-IP request limits (`app/services/rate_limit.py`); production refuses the default JWT secret; PyJWT, python-multipart, requests bumped (14 Dependabot alerts closed). Deployed.
- **Repo hygiene:** VPS host, ssh user, personal inboxes and account ids removed from tracked files; ops notes and deploy snapshots live in the private repo `~/Documents/enfold/ops/` (`ops.env`, `deploy-backend.sh`). `landing/deploy.sh` uses ssh key auth.
- **Physician review pack** for Oana: `~/Documents/enfold/review/learn-cards-review-pack-2026-09-17.docx` (25 cards, urgent first). Raul forwards; answers go into each card's `reviewer` block.
- **Applications:** OpenAI Codex for OSS submitted 2026-09-17 (reply by email). Sentry and Weblate wait for a Sentry SDK and i18n files.

## Next up

1. **Product Hunt day, Wed 2026-09-23:** Raul in the comments from 10:01 Romania; short reply in the pinned X thread by hand. Afterwards: directories (AlternativeTo, awesome-flutter PR) if wanted.
2. **Google Play:** wait for the ticket reply or approval; then promote build 28 from `main` (bump to 1.0.2+28, include the Android 15 edge-to-edge fix), then Play badge on the site.
3. Romanian UI (moved up, `feature/todos/I18N_RO.md`): gen-l10n + ARB, ~280 strings, 2 to 3 sessions.
4. Oana's card sign-offs into the JSON as they arrive.
5. Later: replace the two Adobe-derived illustrations with original art; Riverpod 3 / go_router 18 migration (Dependabot majors are ignored on purpose).

## Blockers / waiting on

- Google Play review (1.0.0+22), support ticket filed 2026-09-22
- FormKiosk iOS review (resubmitted 2026-09-22)
- Product Hunt launch Wed 2026-09-23
- Oana's card review
- Raul: rotate the VPS password (pasted in a chat on 2026-09-17; key auth already works)

## Quick resume

```
Read feature/SESSION.md, feature/PICKUP.md, feature/todos/README.md and ~/Desktop/LAUNCH-CHECKLIST.md (pickup at the top).
Enfold 1.0.1+27, Drift v14, 208 tests. App Store live; Play in review (ticket filed 2026-09-22). Code public at github.com/enfold-baby/enfold.
Launch done on PH (Wed 23 Sep), X, dev.to. Next dev work: Romanian UI (feature/todos/I18N_RO.md) or build 28 for both stores.
Keep markdown current as we ship (feature/MAINTAIN.md). No em dashes. Public posts, logins and payments are Raul's keyboard.
```
