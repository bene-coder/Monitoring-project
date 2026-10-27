#!/usr/bin/env bash

URL="http://localhost:5000/health"

TIMEOUT=5

STATUSCODE=$(curl --write-out "%{http_code}" -s -o /dev/null --max-time $TIMEOUT $URL)

if [ "$STATUSCODE" -eq "200" ]; then
  echo "[SUCCESS] Endpoint is healthy. Status: $STATUSCODE"
  exit 0
else
  echo "[ERROR] Endpoint is not healthy. Status: $STATUSCODE"
  exit 1
fi