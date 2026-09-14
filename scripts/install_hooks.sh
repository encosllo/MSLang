#!/usr/bin/env bash
# Point git at the project's checked-in hooks. Run once after git init.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
git -C "$ROOT" config core.hooksPath scripts/hooks
chmod +x "$ROOT"/scripts/hooks/* "$ROOT"/scripts/*.sh "$ROOT"/scripts/*.py 2>/dev/null || true
echo "hooks installed: core.hooksPath=scripts/hooks"
