# The Round League

![Round League Logo](https://static.wixstatic.com/media/b16829_f3a215a62a9f485990b0e43a0a993d3d~mv2.png/v1/fill/w_909,h_335,al_c,q_85,usm_0.66_1.00_0.01/4_edited.webp)

All Code belongs to The Round League.  
Please contact huynt553@gmail.com for any inquiries or interest in contribution.

## Licensing

- Copyright 2023 The Round League (https://www.theroundleague.com)

### Social Media

Facebook: <https://www.facebook.com/theroundleague/>  
YouTube: <https://www.youtube.com/channel/UCOlYUrGXE-S_dxK1mjCW8Gw>  
Instagram: <https://www.instagram.com/theroundleague>

---

## Local Development Setup

This project runs on **Lucee (CFML)** with a **MySQL** database, containerized with Docker.

### Prerequisites

| Tool | Purpose | Download |
|------|---------|----------|
| [Git](https://git-scm.com/) | Clone the repo | https://git-scm.com/ |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Runs Lucee + MySQL | https://www.docker.com/products/docker-desktop/ |
| [HeidiSQL](https://www.heidisql.com/) | GUI client to browse/query your local MySQL database | https://www.heidisql.com/ |
| [Jira account](https://roundleague.atlassian.net/jira/software/projects/RL/boards/2) | Track and pick up tickets from the RL project board | Request access from the lead developer |

> **Windows users:** Make sure Docker Desktop is running before proceeding.

---

### Quickstart

```bash
git clone https://github.com/roundleague/roundleague_lucee.git
cd roundleague_lucee
bash setup.sh
```

That's it. The script will:
1. Copy `api-keys.example.cfm` → `api-keys.cfm` and pause so you can fill in the real keys (get them from the lead developer)
2. Copy `.env.example` → `.env` with default dev credentials
3. Start both Docker containers (`lucee` + `mysql`) and wait for MySQL to be healthy
4. Optionally import a SQL dump if you have one (get the dump from the lead developer)

The first run downloads Docker images and takes a few minutes. Re-running `setup.sh` is safe — it skips steps already done.

---

### Open the app

| URL | What it is |
|-----|-----------|
| http://localhost:8080 | The Round League website |
| http://localhost:8080/lucee/admin/web.cfm | Lucee admin panel (for debugging) |

> **Lucee admin password:** By default, no password is set on the local dev admin panel. If prompted, check with the lead developer.

---

### Import real data to test real life scenarios

Get the SQL dump from the lead developer, then run:

```bash
docker compose exec -T mysql mysql -u roundleague -proundleague_dev roundleague < path/to/dump.sql
```

Or connect via **HeidiSQL / TablePlus** with these credentials:

| Field | Value |
|-------|-------|
| Host | `127.0.0.1` |
| Port | `3307` |
| Username | `roundleague` |
| Password | `roundleague_dev` (or whatever `MYSQL_PASSWORD` is set to in your `.env`) |
| Database | `roundleague` |

---

### Stopping and Restarting

| Command | What it does |
|---------|-------------|
| `docker compose stop` | Stops containers, keeps DB data |
| `docker compose start` | Restarts stopped containers |
| `docker compose down` | Stops and removes containers (DB data is kept in Docker volume) |
| `docker compose down -v` | ⚠️ Stops containers AND wipes the DB volume — use only to start fresh |

---

### Refreshing the Database

The lead developer periodically exports a fresh snapshot from production and shares the dump file. To overlay your local DB with a fresh copy:

```bash
# Drop and recreate the database (you will be prompted for the root password from your .env)
docker compose exec mysql mysql -u root -p -e "DROP DATABASE IF EXISTS roundleague; CREATE DATABASE IF NOT EXISTS roundleague;"

# Re-import the new dump (you will be prompted for the roundleague user password)
docker compose exec -T mysql mysql -u roundleague -p roundleague < path/to/new_dump.sql
```

---

### Troubleshooting

**Containers won't start**
- Make sure Docker Desktop is running before running `docker compose up`.

**Port already in use (8080 or 3306)**
- Another process is using that port. Either stop it, or edit `docker-compose.yml` to change the host port (left side of `:`). For example, change `"8080:8080"` to `"8081:8080"` and access the app at http://localhost:8081.

**App loads but database queries fail / datasource error**
- The `roundleague` datasource is auto-configured via `.cfconfig.json`. If you see a datasource error, check that the MySQL container is healthy: `docker compose ps`. If it shows `starting`, wait 30 seconds and reload.
- You can verify the datasource in the Lucee admin panel at http://localhost:8080/lucee/admin/web.cfm → **Services → Datasources**.

**`api-keys.cfm` not found error**
- Make sure you completed Step 2 and that `api-keys.cfm` exists in the repo root.

**Changes to `.cfm` files aren't reflected**
- The repo folder is mounted directly into the container, so file changes are live. Try a hard refresh (Ctrl+Shift+R / Cmd+Shift+R). If the issue persists, restart the Lucee container: `docker compose restart lucee`.

