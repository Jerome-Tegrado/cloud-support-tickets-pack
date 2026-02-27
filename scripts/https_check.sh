#!/usr/bin/env bash

# Simple HTTPS check (safe/read-only) using curl
# Usage: ./https_check.sh https://example.com

URL="${1:-https://example.com}"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

echo "[$TIMESTAMP] Starting HTTPS check"
echo "Target: $URL"

# Capture curl output (metrics) while still getting the curl exit code
CURL_OUTPUT="$(curl -I -s -L -o /dev/null \
  --connect-timeout 5 \
  --max-time 15 \
  -w "HTTP_CODE=%{http_code} DNS=%{time_namelookup}s CONNECT=%{time_connect}s TLS=%{time_appconnect}s TTFB=%{time_starttransfer}s TOTAL=%{time_total}s" \
  "$URL")"

EXIT_CODE=$?

echo "$CURL_OUTPUT"

# Decide PASS/FAIL (simple rule for Week 1)
# PASS = curl command succeeded AND HTTP code is 2xx or 3xx
HTTP_CODE="$(echo "$CURL_OUTPUT" | grep -o 'HTTP_CODE=[0-9]\{3\}' | cut -d= -f2)"

STATUS="FAIL"
if [ "$EXIT_CODE" -eq 0 ] && [ -n "$HTTP_CODE" ]; then
  case "$HTTP_CODE" in
    2*|3*)
      STATUS="PASS"
      ;;
  esac
fi

echo "STATUS=$STATUS"

TIMESTAMP_END="$(date '+%Y-%m-%d %H:%M:%S')"
echo "[$TIMESTAMP_END] Check finished (curl_exit_code=$EXIT_CODE)"