#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <device-id> [flutter drive arguments...]" >&2
  echo "Example: $0 linux" >&2
  exit 2
fi
profile_device="$1"
shift
require_flutter
ensure_env_file
mkdir -p build/performance
"${FLUTTER[@]}" --version --machine > build/performance/flutter-version.json
git rev-parse HEAD > build/performance/commit.txt
"${FLUTTER[@]}" drive --profile \
  --driver=test_driver/performance_driver.dart \
  --target=integration_test/performance_test.dart \
  --dart-define=ENABLE_NSW=true \
  -d "$profile_device" "$@"
echo "Performance report: $REPO_ROOT/build/performance/performance.json"
