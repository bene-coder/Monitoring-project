#!/usr/bin/env bash

# Load environment variables from .env if present
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

DB_USER="${POSTGRES_USER:-postgres}"
DB_NAME="${POSTGRES_DB:-devops_db}"
BACKUP_DIR="backups"
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/db_backup_$TIMESTAMP.sql"

echo "-> Initiating backup for database '$DB_NAME'..."

# Run pg_dump inside the running db container via docker compose
if docker compose exec -T db pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE" 2>/dev/null; then
    echo "[SUCCESS] Database backup successfully created at: $BACKUP_FILE"
    exit 0
else
    echo "[ERROR] Database backup failed! Ensure your containers are running." >&2
    exit 1
fi