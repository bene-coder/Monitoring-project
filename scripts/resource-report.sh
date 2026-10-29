#!/usr/bin/env bash
set -euo pipefail

REPORT_DIR="reports"
mkdir -p "$REPORT_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="$REPORT_DIR/resource_report_$TIMESTAMP.txt"

echo "-> Generating Docker resource usage report..."

if ! docker info > /dev/null 2>&1; then
    echo "[ERROR] Docker daemon is not running or accessible." >&2
    exit 1
fi

{
    echo "=================================================="
    echo " DOCKER CONTAINER RESOURCE USAGE REPORT"
    echo " Timestamp: $(date)"
    echo "=================================================="
    docker stats --no-stream
    echo "=================================================="
} | tee "$REPORT_FILE"

echo "[SUCCESS] Report successfully saved to '$REPORT_FILE'"
exit 0