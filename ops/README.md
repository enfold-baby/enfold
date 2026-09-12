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
