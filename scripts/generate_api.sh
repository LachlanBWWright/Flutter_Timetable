#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"

require_flutter
"${FLUTTER[@]}" pub get
"${DART[@]}" run build_runner build --delete-conflicting-outputs "$@"

