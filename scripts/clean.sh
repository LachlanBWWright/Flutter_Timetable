#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"

require_flutter
"${FLUTTER[@]}" clean
"${FLUTTER[@]}" pub get

