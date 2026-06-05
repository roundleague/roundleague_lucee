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

This project runs on **Lucee (CFML)** with a **MySQL** database. The easiest way to run it locally is with **Docker**, which handles everything automatically — no manual server installs needed.

### Prerequisites

| Tool | Purpose | Download |
|------|---------|----------|
| [Git](https://git-scm.com/) | Clone the repo | https://git-scm.com/ |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Runs Lucee + MySQL | https://www.docker.com/products/docker-desktop/ |
| [Node.js](https://nodejs.org/) (LTS) | Frontend assets (Gulp/SCSS) — optional unless editing styles | https://nodejs.org/ |

> **Windows users:** Make sure Docker Desktop is set to use the WSL 2 backend (the default for new installs).

---

### Step 1 — Clone the repository

```bash
git clone https://github.com/roundleague/roundleague_lucee.git
cd roundleague_lucee
```

---

### Step 2 — Set up your API keys

The app requires two private API keys that are **not** committed to the repo. Copy the example file and fill in the values (contact the lead developer to get the actual keys):

```bash
cp api-keys.example.cfm api-keys.cfm
```

Then open `api-keys.cfm` and replace the placeholder values with the real keys.

---

### Step 3 — Start the application

```bash
docker compose up -d
```

This command starts two containers in the background:
- **lucee** — the CFML application server (CommandBox + Lucee 5)
- **mysql** — MySQL 8 database

The first run downloads the Docker images and takes a few minutes. Subsequent starts are fast.

**Check that containers are running:**

```bash
docker compose ps
```

Both services should show `running` (or `Up`).

---

### Step 4 — Import the database schema

The MySQL container starts empty. You need to import the database once to create all the tables.

Get the SQL dump file from the lead developer and run one of the following:

**Option A — Command line:**
```bash
docker compose exec -T mysql mysql -u roundleague -proundleague_dev roundleague < path/to/dump.sql
```

**Option B — HeidiSQL or TablePlus (GUI):**
Connect to the local MySQL instance with these credentials:
| Field | Value |
|-------|-------|
| Host | `127.0.0.1` |
| Port | `3306` |
| Username | `roundleague` |
| Password | `roundleague_dev` |
| Database | `roundleague` |

Then run the SQL dump file through the query editor.

---

### Step 5 — Open the app

| URL | What it is |
|-----|-----------|
| http://localhost:8080 | The Round League website |
| http://localhost:8080/lucee/admin/web.cfm | Lucee admin panel (for debugging) |

> **Lucee admin password:** By default, no password is set on the local dev admin panel. If prompted, check with the lead developer.

---

### Frontend Assets (optional)

Only needed if you are editing SCSS stylesheets.

**Root project styles:**
```bash
npm install
npx gulp watch
```

**Admin dashboard styles:**
```bash
cd admin-dashboard
npm install
npx gulp watch
```

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
# Drop and recreate the database, then re-import
docker compose exec mysql mysql -u root -proot_dev_password -e "DROP DATABASE roundleague; CREATE DATABASE roundleague;"
docker compose exec -T mysql mysql -u roundleague -proundleague_dev roundleague < path/to/new_dump.sql
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

