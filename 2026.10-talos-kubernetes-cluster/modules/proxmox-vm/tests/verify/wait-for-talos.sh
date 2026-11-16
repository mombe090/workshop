#!/usr/bin/env bash
set -euo pipefail

node="$1"

for _ in {1..30}; do
  if talosctl version -n "$node" --insecure >/dev/null 2>&1; then
    printf '{"reachable":"true"}'
    exit 0
  fi
  sleep 10
done

talosctl version -n "$node" --insecure || true
printf '{"reachable":"false"}'
