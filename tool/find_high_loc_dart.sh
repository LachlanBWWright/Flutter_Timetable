#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${1:-.}"
MIN_LINES="${2:-300}"
LIMIT="${3:-50}"

find "$ROOT_DIR" -type f -name '*.dart' \
  -not -path '*/build/*' \
  -not -path '*/.dart_tool/*' \
  -print0 \
| xargs -0 -I{} sh -c 'printf "%6d %s\n" "$(wc -l < "{}")" "{}"' \
| awk -v min="$MIN_LINES" '$1 >= min' \
| sort -nr \
| head -n "$LIMIT"
