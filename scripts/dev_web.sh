#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"

require_flutter
ensure_env_file
"${FLUTTER[@]}" pub get

PORT="${PORT:-8080}"
WEB_HOSTNAME="${WEB_HOSTNAME:-127.0.0.1}"

echo "Starting the Flutter development server at http://localhost:$PORT"
exec "${FLUTTER[@]}" run \
  -d web-server \
  --web-hostname "$WEB_HOSTNAME" \
  --web-port "$PORT" \
  "$@"
