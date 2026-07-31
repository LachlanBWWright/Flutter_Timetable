#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"

require_flutter
ensure_env_file
"${FLUTTER[@]}" test --exclude-tags integration "$@"

