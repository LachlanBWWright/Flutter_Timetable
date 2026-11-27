#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"

require_flutter
ensure_env_file
"${FLUTTER[@]}" pub get

echo "Starting the Linux development build with hot reload enabled."
exec "${FLUTTER[@]}" run -d linux "$@"
