# Todo — Stripe “plant a moon” on /support

> **Priority:** P2 · **Status:** UI live, waiting on Stripe plugin OAuth + Payment Link URLs  
> **Page:** https://enfold.baby/support/#support  
> **Account:** Enfold Stripe account submitted (separate Dashboard from globinary.io). Statement **ENFOLD.BABY**. Radar Lite, tax off.

## What’s live

Nests on `/support/`: €5, €12, €30, plus **choose an amount**.  
Until links exist, taps ask people to email `support@enfold.baby`.

This is a **voluntary tip to the project**, not a charity donation and **not in-app ads**.

**Climate:** the Enfold Stripe account sends **1% of every payment** to [Stripe Climate](https://stripe.com/climate) from the first tip (no volume cap). Copy on `/support/` must not claim carbon-neutral or a ton count.

Moons marketplace later: paid stars in the sky. **Now:** checkout first (presets + custom amount).

## Connect the Stripe plugin (Grok TUI)

The Stripe plugin is already **installed and enabled**. The MCP server is `https://mcp.stripe.com`. This session shows it as **auth required** — tokens are not in `~/.grok/mcp_credentials.json` yet.

1. In this Grok TUI, type **`/mcps`** (or `/plugins` then Tab to **MCP Servers**).
2. Select **stripe**.
3. Press **`i`** to authenticate (OAuth). A browser window opens.
4. Sign in to the **Enfold** Stripe account and approve access.
5. Back in the TUI, press **`r`** to refresh. Or send a new message: “Stripe is connected.”
6. Tokens land in `~/.grok/mcp_credentials.json` (owner-only). Do not paste API keys into chat.

Then Grok can create products / Payment Links and hang them on the page.

## What to send (if creating links by hand)

Stripe Dashboard → Payment Links:

1. One **customer-chosen amount** link, **or** three fixed links (€5 / €12 / €30)
2. Product name e.g. **Enfold night-light**
3. Success URL: `https://enfold.baby/support/`
4. Paste the URL(s) here — **no secret API key** needed for Payment Links

Then set `STRIPE_LINKS` in `landing/public/support/index.html` and redeploy landing.

## Out of scope

- Ads or checkout inside the Flutter app
- Recurring subscriptions (unless we decide later)
