#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

if command -v fvm >/dev/null 2>&1; then
  FLUTTER=(fvm flutter)
  DART=(fvm dart)
else
  FLUTTER=(flutter)
  DART=(dart)
fi

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: '$1' is required but was not found on PATH." >&2
    exit 127
  fi
}

require_flutter() {
  if command -v fvm >/dev/null 2>&1; then
    return
  fi
  require_command flutter
  require_command dart
}

ensure_env_file() {
  if [[ -f .env ]]; then
    return
  fi

  if [[ -f .env.template ]]; then
    cp .env.template .env
    echo "Created .env from .env.template; add provider credentials as needed."
  else
    echo "Error: .env is required because it is a Flutter asset." >&2
    exit 1
  fi
}

