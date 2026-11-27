#!/usr/bin/env bash
# Deployment credentials are public client assets, even when sourced from secrets.
set -Eeuo pipefail

bundle_public_key="${BUNDLE_PUBLIC_TFNSW_KEY:-false}"
case "$bundle_public_key" in
  false|'')
    # Overwrite any local asset; never inherit a developer's provider credentials.
    printf '# No provider credentials bundled. Configure a key in Settings.\nAPI_KEY=\n' > .env
    ;;
  true)
    public_key="${PUBLIC_TFNSW_API_KEY:-}"
    if [[ -z "$public_key" ]]; then
      echo 'BUNDLE_PUBLIC_TFNSW_KEY=true requires the dedicated PUBLIC_TFNSW_API_KEY secret.' >&2
      exit 1
    fi
    # Keep dotenv parsing literal: reject multiline values, comments, and expansion.
    if [[ ! "$public_key" =~ ^[a-zA-Z0-9._~+/=-]+$ ]]; then
      echo 'PUBLIC_TFNSW_API_KEY must be a single token containing only letters, digits, . _ ~ + / = or -.' >&2
      exit 1
    fi
    printf '# Public deployment credential; extractable from this application.\nAPI_KEY=%s\n' "$public_key" > .env
    ;;
  *)
    echo 'BUNDLE_PUBLIC_TFNSW_KEY must be true or false (unset defaults to false).' >&2
    exit 1
    ;;
esac
