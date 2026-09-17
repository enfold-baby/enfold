# Supporters wall

How the "plant a moon" donations on https://enfold.baby/support/ and the galaxy on
https://enfold.baby/galaxy/ work. Donations keep the app free; they unlock nothing in the app.

Donations are Stripe Payment Links (`landing/public/support/index.html`, live and `?stripe=test` sandbox
links). Each link collects name, optional business name, billing address and three custom fields: tax ID
or CUI (for invoices), "show my moon on the supporters wall" (Yes/No) and an optional link. Stripe posts
`checkout.session.completed` to `POST /v1/stripe/webhook` (live and sandbox endpoints, secrets in
`STRIPE_WEBHOOK_SECRET` / `STRIPE_WEBHOOK_SECRET_TEST` on the VPS). The API stores every donation in
`supporters` (private fields stay private) and serves `GET /v1/support/wall?mode=live|test` plus
`/v1/support/icon/<id>` (favicon fetched server-side, so visitors never call a third party). The support
page and `/galaxy/` read the wall. Invoice details for each payment are visible in the Stripe dashboard
under the payment's Checkout summary (name, company, address, tax ID custom field).

Found in the end-to-end sandbox test (2026-09-14):

- **Where the sandbox is.** The `donate.stripe.com/test_...` links live in the account's **Test mode**
  (dashboard URL contains `/test/`, banner "You are testing in a sandbox"), not in
  the separate "Enfold sandbox" entry of the switcher. A dashboard URL without `/test/` is live.
- **Tiers come from the Payment Link id.** Checkout webhooks carry no line items, so the wish link
  (1 EUR x quantity) cannot be told apart by amount: a 5 EUR wish used to be stored as a tea.
  `TIER_BY_PAYMENT_LINK` in `backend/app/services/stripe_webhook.py` holds the 8 ids (live and sandbox);
  amount is only the fallback. **A new or replaced Payment Link must be added there.**
- **Favicons.** The icon fetch reads the site's `<link rel="icon">` tags first, then `/favicon.ico`,
  https only, and refuses private or loopback hosts (the link is supporter input). Rows stored before a
  deploy keep `has_icon=false` until backfilled.
- **Webhook endpoint** also receives `payment_intent.*` / `charge.*` events; they return 200 and are
  ignored. Deliveries are under Workbench, Events, the event, "Deliveries to webhook endpoints".
- **Post-payment invoice PDF** is a per-link setting (Payment link, Edit, After payment, "Create an
  invoice PDF"). Stripe charges 0.4% per invoice, capped at 2 USD, in live. Turned on for the sandbox
  moon link only, to produce an example for the accountant; live
  links unchanged. A Stripe invoice is not a Romanian e-Factura.
  The sample PDF (XTDRXNKD-0001) shows gaps to fix before real use: it reads "due" and "Pay online"
  although paid, the seller block lacks the company name, CUI and address (Stripe invoice template
  settings), the buyer CUI custom field is not printed, and the account phone number is.
- **Galaxy (`landing/public/galaxy/`).** Stars come from seeded 1024-unit tiles in three depths, so the
  sky never ends and looks the same every visit. Moons sit on a golden-angle spiral in planting order
  (`planted_at` from the wall API): a moon never moves, new ones land outside, and the elastic edge
  grows with the outermost moon. Pinch or scroll zooms around the fingers or cursor; "First moon",
  double tap and `Home` fly back. Falling stars every 4 to 13 seconds, none with reduced motion.
  Local performance check: `http://127.0.0.1:8283/galaxy/?demo=500` (fake moons, localhost only);
  500 and 2000 moons held 60 fps in headless Chrome on 2026-09-14.
  The engine lives in `landing/public/galaxy/galaxy.js` (`EnfoldGalaxy.mount`) and is shared: `/galaxy/`
  mounts it interactive, and the `/support/` hero mounts it as a drifting preview of the first 40
  moons (no dragging inside the page, paused while scrolled away, still with reduced motion). Bump the
  `?v=` on both script tags when the engine changes.
