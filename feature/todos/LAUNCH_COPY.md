# Launch copy, per platform

> Prepared 2026-09-21. Facts checked against App Store Connect and the Play Console the same day.
> App Store: live, 1.0.1. Google Play: production release still in review (submitted 2026-09-12), so every post says "coming to Google Play".
> Images: `~/Documents/enfold/launch/ph-01-hero.jpg` to `ph-05-open.jpg` (1270x760), plus `landing/public/og-image.jpg` (1200x630) and the three phone shots in `~/Documents/enfold/review/`.
> Times below are Romania (EEST, UTC+3).

## Facts every post may use

- Free, no ads, no trackers, no analytics SDKs, no data selling, no subscriptions, no in-app purchases.
- Offline first. Optional free account for sync and partner sharing.
- Feeds, sleep, diapers, medicine, pumping, tummy time, growth, milestones, pregnancy (due date, kicks, appointments).
- Time awake since last sleep. Shared care with attribution. 7-day PDF summary for the doctor.
- 25 learn cards, each with a Sources section (AAP, NHS, WHO, CDC). Written with a neonatologist; per-card physician sign-off is in progress and cards say so.
- Open source since 2026-09-17: github.com/enfold-baby/enfold, AGPL-3.0 with an app store covenant, cards CC BY-NC-ND, brand not licensed.
- Stack: Flutter, Riverpod, Drift SQLite; FastAPI, Postgres, Redis; static site; Docker behind Caddy. Self-hostable backend.
- Team: Raul (developer) and Oana (neonatologist), Romania, parents. Mention the family only as Raul chooses.
- Links: https://enfold.baby, https://github.com/enfold-baby/enfold, https://apps.apple.com/us/app/enfold-baby-tracker/id6811765288, https://enfold.baby/support/

Do not say: "physician-reviewed" as a finished fact, any user or download number, "live on Google Play".

---

## 1. Hacker News, Show HN

**When:** Tuesday 2026-09-22, 15:30 Romania (08:30 ET). Stay in the thread until ~21:30 Romania. Fallback: Wednesday or Thursday same time.
**URL field:** https://github.com/enfold-baby/enfold

**Title (78 chars, limit 80):**
Show HN: Enfold, an open-source baby tracker built with my neonatologist wife

**First comment (post it right after submitting):**

Hi HN, Raul here. Enfold is a free, ad-free, offline-first baby care app. My wife is a neonatologist and we built it for the newborn weeks: log a feed, a nap or a diaper in two taps at 3am with one hand, see how long the baby has been awake, share the day with a partner, and read short "is this normal?" cards before reaching for a search engine at night.

Why open source: a baby app holds health data about a child. The only honest way to say "no ads, no trackers, no data selling" is to let you read the code. So the whole thing is public: the Flutter app, the FastAPI backend, the website and the learn cards.

Some things that might interest you:

- Offline first with Drift (SQLite). An account is optional and only exists for sync and partner sharing. Sign-in is a magic code by email, no passwords.
- The learn cards live as JSON in content/, each with a sources list (AAP, NHS, WHO, CDC). A test fails the build if a card ships without one. Apple rejected us on guideline 1.4.1 until every card cited its sources, which turned out to be a good rule.
- Backend is FastAPI + Postgres + Redis, self-hostable with docker compose.
- License is AGPL-3.0 with a covenant that forks must rename and re-skin before shipping to an app store. Cards are CC BY-NC-ND because medical content should not be remixed casually. Name and illustrations are not licensed.

It is on the App Store now and coming to Google Play (in review). Free forever, donations on the website unlock nothing.

Honest gaps: physician sign-off per card is still in progress and the cards say so; only English for now (Romanian is next); one child per device (server already supports more).

Happy to answer anything about the medical content process, the license carve-outs, or Flutter offline sync.

---

## 2. Product Hunt

**When:** Scheduled 2026-09-21 for Wednesday 2026-09-23, 00:01 PT (10:01 Romania). Be in the comments from 10:00 Romania.
**Hunter:** Raul, from his own account.
**Gallery (in order):** ph-01-hero.jpg, ph-02-today.jpg, ph-03-learn.jpg, ph-04-fever.jpg, ph-05-open.jpg. Thumbnail: the app icon (`assets/brand/store/play-icon-512.png`).
**Topics:** Parenting, Health & Fitness, Open Source (add "Android" or "iOS" if a fourth is allowed).
**Links:** Website https://enfold.baby, App Store link, GitHub link.
**Pricing:** Free.

**Name:** Enfold

**Tagline (58 chars, limit 60):**
Calm, open-source baby tracker. Free, no ads, offline first

**Description (257 chars, limit 260):**
Log feeds, sleep and diapers in two taps at 3am, see how long baby has been awake, share care with your partner, and read short "is this normal?" cards written with a neonatologist. Free, no ads, offline first, and fully open source (AGPL) on GitHub.

**First comment (maker story):**

Hi Product Hunt, I'm Raul, a developer. My wife Oana is a neonatologist. Enfold is the app we wanted in the newborn weeks: quiet at night, quick with one hand, and honest about what is normal.

What it does
- Feeds, sleep, diapers, meds, pumping, tummy time, growth and milestones, two taps each
- "Awake for 1h 6m": how long since the last sleep, always on the Today screen
- Share care with a partner or caregiver; every log shows who added it, no scorekeeping
- 25 learn cards ("Fever in a newborn: when is it urgent?") with a quick triage at the top and sources on every card
- A 7-day PDF summary to hand to the doctor

What it will not do
- No ads, no trackers, no analytics SDKs, no data selling
- No streaks, no guilt messages, no scores
- No paywall, ever. Free for every parent; donations on the website unlock nothing

It is open source (github.com/enfold-baby/enfold, AGPL-3.0) so you can check those promises in the code. Live on the App Store, coming to Google Play.

One honest note: the per-card physician sign-off is still in progress and the cards say so in the app.

I would love to hear what tired parents actually need at 3am. Thank you for looking.

---

## 3. Peerlist

**Step 1, project:** add Enfold as a project on Raul's profile (name, tagline, website, GitHub, App Store, category Health / Parenting, tech tags Flutter, FastAPI, Postgres, Open Source).
**Step 2, launch:** Peerlist Launch, any weekday, best Tuesday morning IST (07:00 to 09:00 Romania). Suggested Tuesday 2026-09-22 morning, before the HN post.

**Tagline:** Calm, open-source baby tracker. Free, no ads, offline first

**Description:**
Enfold is a free baby care app for the newborn weeks: feeds, sleep, diapers, medicine, pumping, growth and milestones in two taps, time awake on the Today screen, shared care with a partner, and short "is this normal?" cards written with a neonatologist, each with sources. No ads, no trackers, no subscriptions. Offline first, optional account for sync. The Flutter app, FastAPI backend and website are open source under AGPL-3.0. On the App Store now, coming to Google Play.

**Launch post text:**
We open-sourced our baby app. Enfold is free, ad-free and offline first; the "is this normal?" cards were written with my wife (a neonatologist) and I wrote the code. Flutter + FastAPI, AGPL-3.0. App Store now, Google Play in review. Feedback from parents and Flutter folks welcome.

---

## 4. Reddit

Read each subreddit's rules on the day. Post as a text post with the story first and links at the end; several subs remove link-only posts. One sub per day, do not cross-post the same hour.

### r/opensource (Tuesday 2026-09-22 or Wednesday, 16:00 Romania)
**Title:** We open-sourced our baby tracker app (Flutter + FastAPI, AGPL-3.0), built with my neonatologist wife
**Body:**
Enfold is a free, ad-free baby care app: feeds, sleep, diapers, meds, growth, shared care with a partner, and short "is this normal?" cards with sources on every card. It went public last week under AGPL-3.0.

Why open: it holds health data about a child, and "no ads, no trackers, no data selling" only means something if you can read the code. Everything is in one repo: Flutter app (offline first, Drift), FastAPI + Postgres backend (self-hostable), static site, and the learn cards as JSON.

License notes, because they were the hard part: AGPL-3.0 for code with a covenant that forks rename and re-skin before shipping to an app store; CC BY-NC-ND for the medical cards; the name and illustrations are not licensed. DCO sign-off, no CLA. Happy to discuss those choices.

Repo: https://github.com/enfold-baby/enfold
Site: https://enfold.baby
App Store now, Google Play in review.

### r/FlutterDev (Wednesday 2026-09-23, 16:00 Romania)
**Title:** Open-sourced a production Flutter app: offline-first baby tracker with Riverpod, go_router and Drift, plus a FastAPI backend
**Body:**
Enfold is on the App Store and in Play review, and the whole codebase is now public (AGPL-3.0): https://github.com/enfold-baby/enfold

Things Flutter people may find useful in the repo:
- Offline first with Drift (SQLite), schema at v14 with migrations, and a sync layer that pushes creates, edits and deletes and pulls every ~45s while open
- Riverpod + go_router with a four-tab shell and a docked add button
- Magic-code sign-in (no passwords) against a FastAPI backend
- Partner push via FCM, only when the user turns it on
- Content as JSON in content/ with a test that fails the build if a learn card has no sources (Apple's 1.4.1 taught us that)
- 208 tests, CI on GitHub Actions

Questions about any of it are welcome, and so are PRs (translations first).

### r/selfhosted (Thursday 2026-09-24, 16:00 Romania)
**Title:** Enfold: open-source baby tracker with a self-hostable sync backend (FastAPI, Postgres, Redis, docker compose)
**Body:**
The app works fully offline on the phone. If you want sync between two parents' phones, the backend is a small FastAPI service with Postgres and Redis, one docker compose up. Magic-code email sign-in, family invites, partner push. AGPL-3.0.

Repo and compose file: https://github.com/enfold-baby/enfold
Note: the store builds point at our hosted API; pointing the app at your own server needs a build with a different API base URL (a dart-define) for now. Making it configurable in Settings is a fair ask.

### r/NewParents and r/beyondthebump
Check the rules first; both restrict self-promotion. If allowed, post only on the weekly self-promo or app thread, from a parent's voice:
**Title:** We made a free, ad-free baby tracker with my neonatologist wife, and open-sourced it
**Body:** Two taps for feeds, sleep and diapers at 3am, "awake for" on the home screen, shared with your partner, and short "is this normal?" cards with sources. No ads, no subscription, no data selling, and the code is public so you can check. App Store now, Google Play soon. https://enfold.baby

---

## 5. Indie Hackers

**When:** any weekday, 17:00 Romania (10:00 ET). Suggested Wednesday 2026-09-23.
**Product page:** name Enfold, tagline "Calm, open-source baby tracker. Free, no ads, offline first", revenue: $0 / donations, website enfold.baby.

**Post title:** We open-sourced our free baby app. Here is why and what the license carve-outs are

**Post body:**
Enfold is a baby care app my wife (a neonatologist) and I built for the newborn weeks. It is free, has no ads, and last week we made the code public under AGPL-3.0.

The business model is not a business model: donations on the website that unlock nothing. That is deliberate. Safety guidance for a newborn should never sit behind a paywall, and a health app that sells data is the thing we did not want to use ourselves.

What open source gives us that a privacy policy cannot: anyone can read the code and confirm there are no ad or analytics SDKs. Clinicians can check the learn cards, each of which cites its sources. Parents in other languages can help translate.

The parts that took real thought:
- AGPL plus an app store covenant: fork freely, but rename and re-skin before you ship to a store
- Cards under CC BY-NC-ND, because medical text should not be remixed casually
- Name, logo and illustrations not licensed at all
- DCO sign-off instead of a CLA

Status: App Store live, Google Play in review, X thread from launch day pinned on my profile. Repo: github.com/enfold-baby/enfold. Site: enfold.baby.

If you have shipped a donation-only product, I would like to hear how it went after month three.

---

## 6. dev.to (long form)

**When:** Thursday 2026-09-24, 15:00 Romania. Tags: opensource, flutter, healthtech, showdev. Cover image: ph-05-open.jpg. Canonical URL: none (or enfold.baby/open/ if you prefer).

**Title:** Why we open-sourced a baby health app, and what the license carve-outs are

**Body:**

My wife Oana is a neonatologist. I write software. When we became parents we wanted an app that was quiet at night, quick with one hand, and honest about what is normal. We could not find one without ads, streaks or a subscription wall in front of the safety content, so we built Enfold. Last week we made all of it public: https://github.com/enfold-baby/enfold

### Why open source for a health app

A baby tracker holds health data about a child. Every app in the category says "we take your privacy seriously". We wanted a claim that can be checked instead of trusted:

- No ad SDKs, no analytics SDKs, no trackers. Read pubspec.yaml and the iOS and Android manifests.
- Without an account the data never leaves the phone. Read the sync layer; it does nothing until you sign in.
- With an account, data syncs over HTTPS to a small FastAPI backend you can run yourself.

Open source also lets clinicians check the content. Each learn card is a JSON file with a sources list. A unit test fails the build if a card ships without sources. Apple rejected one of our submissions under guideline 1.4.1 (medical content needs citations) and, honestly, that rule made the product better.

### The stack

- Flutter, Riverpod, go_router, Drift (SQLite) for offline first storage, schema v14
- FastAPI, Postgres, Redis for sync, magic-code sign-in, partner invites and push
- A static site behind Caddy, docker compose for the lot
- 208 tests, GitHub Actions, Dependabot on minor and patch only

### The license, and the carve-outs

This was the hard part, and I want to be plain about it.

- **Code: AGPL-3.0-or-later.** Copyleft, network clause included, so a hosted fork must publish its changes.
- **App store covenant.** A short addition in LICENSE-NOTES: if you ship a fork to an app store, rename it and replace the brand and illustrations first. We want forks, we do not want confused parents installing the wrong "Enfold".
- **Learn cards: CC BY-NC-ND 4.0.** Medical guidance should be quoted with attribution, not remixed. If you want to translate them, open an issue and we will do it with a clinician in the loop.
- **Brand: not licensed.** Name, logo, icons and two illustrations (which we will replace with original art).
- **DCO, no CLA.** Sign your commits, keep your copyright.

### What is still not finished

- Per-card physician sign-off is in progress. Cards that have not been signed off say "Pending physician review" in the app.
- English only. Romanian is next, then whatever contributors bring.
- One child per device in the UI; the server already supports more.
- Google Play is still in review; the App Store version is live.

### If you want to help

Translations first, then bugs, then features. CONTRIBUTING.md has the build steps; the backend and the app both run locally with one docker compose and one flutter run.

Site: https://enfold.baby. Repo: https://github.com/enfold-baby/enfold. If you are a parent, the App Store link is on the site. It is free and will stay free.

---

## 7. LinkedIn (Raul's personal post)

**When:** Tuesday 2026-09-22, 09:00 Romania, or Wednesday same time. Attach ph-01-hero.jpg (LinkedIn crops to 1.91:1, the hero survives it) or the three phone shots as a carousel.

**Post:**
Enfold is live on the App Store, coming to Google Play, and as of last week fully open source.

It is a baby care app my wife Oana (a neonatologist) and I built for the newborn weeks: two taps to log a feed, a nap or a diaper at 3am, "awake for" on the home screen, care shared with a partner, and short "is this normal?" cards with sources on every card.

Three decisions I am proud of:
1. Free for every parent. No ads, no subscription, no data selling. Donations on the website unlock nothing.
2. Open source under AGPL-3.0, so "no trackers" is something you can verify, not something you have to believe.
3. Reassure before charts. No streaks, no guilt, no scores.

Built with Flutter and FastAPI, from Romania.

Site: https://enfold.baby
Code: https://github.com/enfold-baby/enfold

If you know a new parent, a midwife, a lactation consultant or a paediatric ward, I would be grateful if you passed it on.

#opensource #flutter #parenting #healthtech

(Tag Oana only if she agrees.)

---

## 8. X follow-ups (reply to or quote the pinned thread)

Thread: https://x.com/Gl0deanR/status/2100594197900181840

- **After Show HN goes up:** "Enfold is on Hacker News today. If you have questions about the license carve-outs or how we handle medical content, I am in the thread: [HN link]"
- **Product Hunt day (schedule on x.com as a standalone post for Wed 2026-09-23 10:05 Romania; X cannot schedule replies, so add a short reply in the pinned thread by hand later):** "Enfold is on Product Hunt today. A calm baby tracker built with my neonatologist wife: free, no ads, offline first, open source under AGPL. If it could help a tired parent you know, pass it on. Questions welcome, I am in the comments all day. https://www.producthunt.com/products/enfold" (attach ph-01-hero.jpg)
- **When Play approves:** "Enfold is now on Google Play too: [Play link]. Same app, same promise: free, no ads, open source."
- **dev.to article (post after 15:00 Bucharest on 2026-09-21, as a reply to the pinned thread):** "Wrote up why we open-sourced a baby health app, and what the AGPL carve-outs are: no ad SDKs you can verify, cards with sources, an app store covenant for forks, and what is still unfinished. https://dev.to/gl0deanr/why-we-open-sourced-a-baby-health-app-and-what-the-license-carve-outs-are-o07"

---

## 9. Directories (after PH)

AlternativeTo (category: baby tracker, open source, free), Uneed, Microlaunch, SaaSHub, BetaList. awesome-flutter PR ("Enfold, open-source offline-first baby tracker"). F-Droid later, needs a reproducible build.
