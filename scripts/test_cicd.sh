#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"

TARGET="${1:-all}"
case "$TARGET" in
  web|android|all) ;;
  *)
    echo "Usage: $0 [web|android|all]" >&2
    exit 2
    ;;
esac

"$SCRIPT_DIR/ci.sh"

if [[ "$TARGET" == web || "$TARGET" == all ]]; then
  "$SCRIPT_DIR/build_web.sh"
fi
if [[ "$TARGET" == android || "$TARGET" == all ]]; then
  "$SCRIPT_DIR/build_apk.sh"
fi

echo "Local CI/CD smoke test passed for: $TARGET."

