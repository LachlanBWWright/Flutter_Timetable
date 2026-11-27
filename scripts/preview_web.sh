#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"

PORT="${PORT:-8000}"
"$SCRIPT_DIR/build_web.sh" "$@"
require_command python3
echo "Serving the production web build at http://localhost:$PORT"
exec python3 -m http.server "$PORT" --directory build/web

