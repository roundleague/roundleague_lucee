# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

The Round League's main site: a CFML (Lucee) monolith serving the public site, the admin dashboard, and live in-game tooling (StatsApp for stat-keepers, the public scoreboard). It shares a MySQL database with a separate sibling service, **`round-league-api`** (Node/Express, deployed on Render), which handles anything needing real-time push, JWT-authed mobile/player-app endpoints, Socket.IO, and Stripe. When working on live-score/clock sync, playoffs, or the player-facing API, check whether the matching change also needs to happen in that repo.

## Commands

Local dev runs on Docker (Lucee + MySQL), no build step:

```bash
bash setup.sh          # first-time setup: copies api-keys.cfm/.env, starts containers, imports schema+seed
docker compose up -d   # start containers
docker compose stop    # stop, keep DB data
docker compose logs mysql   # debug a container that won't come up healthy
docker compose restart lucee   # if .cfm changes aren't reflected after a hard refresh
```

- App: http://localhost:8080 — Lucee admin: http://localhost:8080/lucee/admin/web.cfm
- MySQL is reachable on `127.0.0.1:3307` (HeidiSQL/TablePlus) with credentials from `.env`.
- The MySQL datasource named `roundleague` is auto-configured from `.cfconfig.json` — both this app and `round-league-api` point at the same database.
- `api-keys.cfm` (gitignored, copy from `api-keys.example.cfm`) holds `application.stripeSecretKey` and `application.adminApiKey`, loaded into application scope in `Application.cfc`.
- No automated test suite and no lint command exist in this repo.

**Deployment**: every push to `main` triggers `.github/workflows/deploy.yml`, which FTP-deploys the repo directly to Hostek production — no build step, no staging environment, no CI checks gating it. Compiled CSS is committed to git, not generated in CI. Treat a push to `main` as an immediate production deploy.

## Architecture

### Layout
- `pages/` — public site (schedule, standings, boxscores, team/player profiles, StatsApp, the public scoreboard).
- `admin-dashboard/` — admin panel (Paper Dashboard 2 Bootstrap theme), gated by `admin-dashboard/admin_header.cfm`/`admin_footer.cfm`.
- `library/` — shared CFCs (`playoffs.cfc`, `playoffsDoubleElim.cfc`, `teams.cfc`) invoked via `createObject("component", "library.X")`.
- `api/` — a separate, older REST layer (`restEnabled` in `Application.cfc`, CFCs with `rest="true"`) — distinct from the `round-league-api` Node service; don't confuse the two when a task mentions "the API."
- `scripts/schema.sql` — hand-maintained documentation dump of the full schema (not an executable migration). There is no migration runner in this repo; DDL changes are applied by hand against the live DB, then mirrored into this file for documentation. (`round-league-api/src/migrations/*.sql` files serve as that side's changelog, same manual-apply convention.)

### Regular season vs. playoffs: parallel, not shared
This is the most important structural thing to know before touching stats/scoring code — regular season and playoffs are two **parallel, independently-maintained systems**, not one system with a flag:

| Concern | Regular season | Playoffs |
|---|---|---|
| Schedule table | `schedule` | `playoffs_schedule` |
| Score-save page | `pages/StatsApp/StatsApp-Save.cfm` | `pages/StatsApp/StatsApp-Save-Playoffs.cfm` |
| Player box score | `PlayerGameLog` | `Playoffs_PlayerGameLog` |
| Boxscore page | `pages/boxscore/boxscore.cfm` | `pages/boxscore/playoffs_boxscore.cfm` |
| round-league-api routes | `src/routes/schedule.js` | `src/routes/playoffs.js` |
| Live socket room | `game:{scheduleID}` | `playoff-game:{scheduleID}` |

`schedule.ScheduleID` and `playoffs_schedule.Playoffs_ScheduleID` are independent auto-increment sequences that can (and do) collide on the same numeric value — anything shared between the two systems (`game_plays`, socket rooms) must disambiguate explicitly (`game_plays.isPlayoff`, separate room prefixes) rather than trusting the ID alone. When adding a feature to one side, check whether the other side needs the equivalent change — several bugs this session came from the playoff side silently lacking something the regular-season side already had (live clock sync, a working "already saved" guard, per-bracket-scoped imports).

Playoffs additionally support a fixed 7-team, 12-game double-elimination bracket (`playoffs_bracket.BracketFormat = 'double_elim_7'`, topology defined once in `library/playoffsDoubleElim.cfc`, applied at import time onto `playoffs_schedule.WinnerAdvancesTo`/`LoserAdvancesTo`/`GameLabel`) alongside the older single-elimination format, which is still driven by a hardcoded seed-count lookup table in `StatsApp-Save-Playoffs.cfm`'s `getAdvanceToGameId()`.

### Live scoring/scoreboard sync
`StatsApp.cfm` (stat-keeper's live entry UI) and `pages/scoreboard/scoreboard.cfm` (public display board, manual `?game=id` or auto-detecting mode) sync in real time through `round-league-api`'s Socket.IO server, not through this Lucee app — this app only writes to MySQL and calls `round-league-api` over HTTP (`application.apiBase`, `x-admin-key` header) to trigger broadcasts. `application.apiBase` in `Application.cfc` points at `http://localhost:3001` when `CGI.SERVER_NAME` is localhost, otherwise the Render URL — so local StatsApp testing requires `round-league-api` running locally too, pointed at the same DB.

### CFML gotcha
Inside any `<cfoutput>` block, a literal `#` (CSS hex colors, anchors, etc.) must be escaped as `##`, or Lucee tries to parse it as an expression delimiter.
