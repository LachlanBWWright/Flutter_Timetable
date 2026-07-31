#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"

require_flutter
ensure_env_file
"${FLUTTER[@]}" pub get
"${DART[@]}" format --output=none --set-exit-if-changed .
"${FLUTTER[@]}" analyze
"${FLUTTER[@]}" test --exclude-tags integration

echo "Local CI checks passed."

