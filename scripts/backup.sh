#!/usr/bin/env bash
set -euo pipefail

# Load environment variables from .env if present
if [ -f .env ]; then
    # shellcheck source=.env
    set -a
    source .env
    set +a
fi

DB_USER="${POSTGRES_USER:-postgres}"
DB_NAME="${POSTGRES_DB:-devops_db}"
BACKUP_DIR="backups"
MAX_BACKUPS="${MAX_BACKUPS:-5}"

mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/db_backup_$TIMESTAMP.sql.gz"

echo "-> Initiating compressed backup for database '$DB_NAME'..."

cleanup_on_failure() {
    if [ -f "$BACKUP_FILE" ]; then
        rm -f "$BACKUP_FILE"
    fi
}
trap cleanup_on_failure ERR

if docker compose exec -T db pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_FILE"; then
    echo "[SUCCESS] Backup successfully created and compressed at: '$BACKUP_FILE'"
    
    echo "-> Enforcing retention policy (retaining last $MAX_BACKUPS backups)..."
    # ShellCheck compliant file purging using find and sort (avoids ls parsing)
    find "$BACKUP_DIR" -maxdepth 1 -name "db_backup_*.sql.gz" -type f | sort -r | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm -f
    
    exit 0
else
    echo "[ERROR] Database backup failed!" >&2
    cleanup_on_failure
    exit 1
fi