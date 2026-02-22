#!/usr/bin/env bash
# dns_check.sh
# Safe/read-only DNS check for troubleshooting (v1)
# Usage:
#   ./dns_check.sh [domain] [resolver]
# Examples:
#   ./dns_check.sh
#   ./dns_check.sh example.com
#   ./dns_check.sh example.com 1.1.1.1

set -u

DOMAIN="${1:-example.com}"
RESOLVER="${2:-}"   # optional, e.g. 1.1.1.1

START_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

echo "=== DNS CHECK START ==="
echo "timestamp_utc=${START_TS}"
echo "domain=${DOMAIN}"

if [[ -n "${RESOLVER}" ]]; then
  echo "resolver=${RESOLVER}"
  echo "tool=nslookup"
  echo "mode=specified-resolver"
  NSLOOKUP_OUTPUT="$(nslookup "${DOMAIN}" "${RESOLVER}" 2>&1)"
else
  echo "resolver=system-default"
  echo "tool=nslookup"
  echo "mode=default-resolver"
  NSLOOKUP_OUTPUT="$(nslookup "${DOMAIN}" 2>&1)"
fi

NSLOOKUP_EXIT_CODE=$?

echo "${NSLOOKUP_OUTPUT}"
echo "nslookup_exit_code=${NSLOOKUP_EXIT_CODE}"

END_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "timestamp_utc_end=${END_TS}"
echo "=== DNS CHECK END ==="