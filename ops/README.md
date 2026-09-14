# Ops notes (production VPS)

Host `135.125.226.37`, user `u_bloomdue`, compose project in `~/bloomdue-platform`
(containers `bloomdue-postgres`, `bloomdue-redis`, `bloomdue-backend`, `bloomdue-landing`).

## Database backups

`ops/backup-db.sh` runs nightly at 03:15 UTC from the `u_bloomdue` crontab and writes
`~/backups/db/enfold-db-<utc stamp>.sql.gz`, keeping 14 days. Status: `~/backups/db/backup.log`;
a `~/backups/db/FAILED` file means the last run failed.

Install or update on the server:

```bash
scp ops/backup-db.sh u_bloomdue@135.125.226.37:~/bin/backup-db.sh
ssh u_bloomdue@135.125.226.37 'chmod +x ~/bin/backup-db.sh && (crontab -l 2>/dev/null | grep -v backup-db.sh; echo "15 3 * * * $HOME/bin/backup-db.sh >> $HOME/backups/db/cron.log 2>&1") | crontab -'
```

Failure alerts: the script pings the healthchecks.io check `enfold-db-backup` (project under
raul@globinary.io, period 1 day, grace 3 h, email alert). The ping URL lives in `~/.backup-env`
on the server as `export HEALTHCHECK_URL=...` and the crontab sources it before the script.
The `export` matters: without it the variable stays in cron's shell and the script never pings
(that is why the check alerted on 11 Sep 2026 although the dump itself succeeded). Copies live only on the VPS; pull a dump off-site
(`scp` to the Mac) before risky work.

Restore:

```bash
gunzip -c enfold-db-<stamp>.sql.gz | docker exec -i bloomdue-postgres psql -U bloomdue bloomdue
```

## Supporters wall (Stripe)

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
  (`dashboard.stripe.com/acct_1UDMHdE71DM0rnaD/test/...`, banner "You are testing in a sandbox"), not in
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
  moon link only (`plink_1UEmrfE71DM0rnaDI7pZg9jj`) to produce an example for the accountant; live
  links unchanged. A Stripe invoice is not a Romanian e-Factura.
