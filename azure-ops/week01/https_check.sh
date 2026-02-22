#!/usr/bin/env bash

# Simple HTTPS check (safe/read-only) using curl
# Usage: ./https_check.sh https://example.com

URL="${1:-https://example.com}"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

echo "[$TIMESTAMP] Starting HTTPS check"
echo "Target: $URL"

curl -I -s -L -o /dev/null \
  -w "HTTP_CODE=%{http_code} DNS=%{time_namelookup}s CONNECT=%{time_connect}s TLS=%{time_appconnect}s TTFB=%{time_starttransfer}s TOTAL=%{time_total}s\n" \
  "$URL"

EXIT_CODE=$?

TIMESTAMP_END="$(date '+%Y-%m-%d %H:%M:%S')"
echo "[$TIMESTAMP_END] Check finished (curl_exit_code=$EXIT_CODE)"