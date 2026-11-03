#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${1:-.}"
MIN_INDENT="${2:-20}"
LIMIT="${3:-50}"

find "$ROOT_DIR" -type f -name '*.dart' \
  -not -path '*/build/*' \
  -not -path '*/.dart_tool/*' \
  -print0 \
| xargs -0 -I{} sh -c '
  awk '\''
    {
      if ($0 ~ /[^[:space:]]/ && $0 !~ /^[[:space:]]*\/\//) {
        match($0, /^ */);
        indent = RLENGTH;
        if (indent > max_indent) max_indent = indent;
      }
    }
    END {
      printf "%4d %s\n", max_indent, FILENAME;
    }
  '\'' "{}"
' \
| awk -v min="$MIN_INDENT" '$1 >= min' \
| sort -nr \
| head -n "$LIMIT"
