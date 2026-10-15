#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"

mode="${1:-nsw}"
if [[ $# -gt 0 ]]; then
  shift
fi

case "$mode" in
  nsw)
    dart_defines=(
      --dart-define=ENABLE_NSW=true
      --dart-define=ENABLE_VICTORIA=false
      --dart-define=ENABLE_QUEENSLAND=false
      --dart-define=ENABLE_SOUTH_AUSTRALIA=false
      --dart-define=ENABLE_TASMANIA=false
      --dart-define=ENABLE_NORTHERN_TERRITORY=false
      --dart-define=ENABLE_WESTERN_AUSTRALIA=false
    )
    ;;
  all-regions)
    dart_defines=(
      --dart-define=ENABLE_NSW=true
      --dart-define=ENABLE_VICTORIA=true
      --dart-define=ENABLE_QUEENSLAND=true
      --dart-define=ENABLE_SOUTH_AUSTRALIA=true
      --dart-define=ENABLE_TASMANIA=true
      --dart-define=ENABLE_NORTHERN_TERRITORY=true
      --dart-define=ENABLE_WESTERN_AUSTRALIA=true
    )
    ;;
  *)
    echo "Usage: $0 [nsw|all-regions] [flutter test arguments...]" >&2
    exit 2
    ;;
esac

require_flutter
ensure_env_file
"${FLUTTER[@]}" pub get
"${DART[@]}" format --output=none --set-exit-if-changed .
"${FLUTTER[@]}" analyze
# Keep test worker usage predictable on both developer machines and hosted CI.
# Set all region defines explicitly so each mode is deterministic and cannot
# drift when the production defaults change.
"${FLUTTER[@]}" test --coverage --exclude-tags=integration,golden --concurrency=1 "${dart_defines[@]}" "$@"

echo "Local CI checks passed ($mode mode)."
