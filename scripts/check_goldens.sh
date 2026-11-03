#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"

require_flutter
ensure_env_file

update_goldens=false
if [[ "${1:-}" == "--update-goldens" ]]; then
  update_goldens=true
  shift
fi

golden_dir="screenshots/phoneScreenshots"
if [[ "$update_goldens" != true ]] && \
  { [[ ! -d "$golden_dir" ]] || ! compgen -G "$golden_dir/*.png" >/dev/null; }; then
  cat >&2 <<EOF
Error: screenshot baselines are missing from $golden_dir.
Generate and review them locally with:
  ./scripts/check_goldens.sh --update-goldens
Then commit the resulting PNG files before running this check again.
EOF
  exit 1
fi

# Baselines are generated with every region enabled, so compare against that
# same app configuration regardless of the production default (NSW only).
flutter_args=(
  test --tags golden --concurrency=1
  --dart-define=ENABLE_NSW=true \
  --dart-define=ENABLE_VICTORIA=true \
  --dart-define=ENABLE_QUEENSLAND=true \
  --dart-define=ENABLE_SOUTH_AUSTRALIA=true \
  --dart-define=ENABLE_TASMANIA=true \
  --dart-define=ENABLE_NORTHERN_TERRITORY=true \
  --dart-define=ENABLE_WESTERN_AUSTRALIA=true
)
if [[ "$update_goldens" == true ]]; then
  flutter_args+=(--update-goldens)
fi
"${FLUTTER[@]}" "${flutter_args[@]}" "$@"
