#!/bin/bash
set -euo pipefail

URL="${1:-http://localhost:8000/health}"
MAX_RETRIES=30
RETRY_INTERVAL=2

echo "Checking health at $URL ..."

for i in $(seq 1 $MAX_RETRIES); do
  if curl -sf "$URL" > /dev/null; then
    echo "✅ Application is healthy"
    exit 0
  fi
  echo "Attempt $i/$MAX_RETRIES failed, retrying in ${RETRY_INTERVAL}s..."
  sleep $RETRY_INTERVAL
done

echo "❌ Health check failed after $MAX_RETRIES attempts"
exit 1
