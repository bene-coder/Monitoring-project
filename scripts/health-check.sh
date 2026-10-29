#!/usr/bin/env bash
set -euo pipefail

# Accept URL from: 1) First argument, 2) HEALTH_URL env var, 3) Default fallback
URL="${1:-${HEALTH_URL:-http://localhost:5000/health}}"
MAX_RETRIES="${MAX_RETRIES:-5}"
RETRY_INTERVAL="${RETRY_INTERVAL:-3}"
TEMP_FILE="/tmp/health_response.json"

echo "-> Pinging health endpoint at '$URL' (Max retries: $MAX_RETRIES)..."

attempt=1
while [ "$attempt" -le "$MAX_RETRIES" ]; do
    # Capture HTTP status code while saving body to a temp file, with strict variable quoting
    HTTP_STATUS=$(curl -s -o "$TEMP_FILE" -w "%{http_code}" "$URL" || echo "000")

    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "[SUCCESS] Health check passed! HTTP Status: 200"
        echo "Response payload:"
        cat "$TEMP_FILE"
        rm -f "$TEMP_FILE"
        exit 0
    fi

    echo "[WARNING] Attempt $attempt/$MAX_RETRIES failed (HTTP Status: $HTTP_STATUS). Retrying in ${RETRY_INTERVAL}s..." >&2
    sleep "$RETRY_INTERVAL"
    attempt=$((attempt + 1))
done

echo "[ERROR] Health check failed after $MAX_RETRIES attempts!" >&2
if [ -f "$TEMP_FILE" ]; then
    echo "Last response payload:"
    cat "$TEMP_FILE"
    rm -f "$TEMP_FILE"
fi
exit 1