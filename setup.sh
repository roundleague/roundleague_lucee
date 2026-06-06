#!/usr/bin/env bash
# Run once after cloning: bash setup.sh
set -e

GREEN='\033[0;32m' YELLOW='\033[1;33m' RED='\033[0;31m' CYAN='\033[0;36m' NC='\033[0m'
log()  { echo -e "${CYAN}$1${NC}"; }
ok()   { echo -e "${GREEN}$1${NC}"; }
warn() { echo -e "${YELLOW}$1${NC}"; }
err()  { echo -e "${RED}$1${NC}"; }

echo ""
log "=== Round League — local dev setup ==="
echo ""

# ── 1. API keys ───────────────────────────────────────────────────────────────
if [ -f api-keys.cfm ]; then
    warn "[1/3] api-keys.cfm already exists — skipping."
else
    cp api-keys.example.cfm api-keys.cfm
    warn "[1/3] api-keys.cfm created."
    echo ""
    warn "      Open api-keys.cfm and fill in the real API keys, then press Enter to continue."
    read -r
fi

# ── 2. .env ───────────────────────────────────────────────────────────────────
if [ -f .env ]; then
    warn "[2/3] .env already exists — skipping."
else
    cp .env.example .env
    ok "[2/3] .env created with default dev credentials."
fi

# ── 3. Docker ─────────────────────────────────────────────────────────────────
log "[3/3] Starting Docker containers (first run downloads images — may take a few minutes)..."
docker compose up -d

log "      Waiting for MySQL to be ready..."
MAX=120
ELAPSED=0
until docker compose ps mysql | grep -q "healthy" || [ $ELAPSED -ge $MAX ]; do
    sleep 4
    ELAPSED=$((ELAPSED + 4))
done

if [ $ELAPSED -ge $MAX ]; then
    err "ERROR: MySQL did not become healthy. Check logs: docker compose logs mysql"
    exit 1
fi
ok "      MySQL is ready."

# ── Optional: import SQL dump ─────────────────────────────────────────────────
echo ""
warn "Do you have a SQL dump to import? Enter the path (or press Enter to skip):"
read -r DUMP_PATH

if [ -n "$DUMP_PATH" ]; then
    DUMP_PATH="${DUMP_PATH//\"/}"
    if [ ! -f "$DUMP_PATH" ]; then
        warn "File not found — skipping. You can import manually later."
    else
        PW=$(grep "^MYSQL_PASSWORD=" .env | cut -d= -f2)
        log "Importing database..."
        docker compose exec -T mysql mysql -u roundleague -p"$PW" roundleague < "$DUMP_PATH"
        ok "Database imported."
    fi
else
    warn "Skipping database import."
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
ok "=== Setup complete! ==="
echo ""
echo "  App:         http://localhost:8080"
echo "  Lucee admin: http://localhost:8080/lucee/admin/web.cfm"
echo "  DB:          127.0.0.1:3306  user=roundleague"
echo ""
