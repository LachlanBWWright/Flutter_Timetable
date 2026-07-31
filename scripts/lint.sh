#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"

require_flutter
"${DART[@]}" format --output=none --set-exit-if-changed .
"${FLUTTER[@]}" analyze

