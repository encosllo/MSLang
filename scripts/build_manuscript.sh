#!/usr/bin/env bash
# Exit-code-checked manuscript build wrapper.
#
# Architecture.md Sections 10.6 item 5 and 13.3 item 3: never trust the
# printed log alone. Under latin1 a dropped character can produce a
# clean-looking log while the process exit code is still non-zero.
#
# Usage: scripts/build_manuscript.sh [--no-scan]
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/env.sh
. "$ROOT/scripts/env.sh"

SRC="$ROOT/manuscript/MSEilenberg.tex"
command -v latexmk >/dev/null 2>&1 || { echo "latexmk not found" >&2; exit 127; }

if [ "${1:-}" != "--no-scan" ]; then
  echo "== non-ASCII scan ==" >&2
  if ! python3 "$ROOT/scripts/nonascii_scan.py" "$SRC"; then
    echo "BUILD ABORTED: suspicious UTF-8 in a latin1 source." >&2
    exit 3
  fi
fi

echo "== latexmk -pdf ==" >&2
latexmk -pdf -interaction=nonstopmode -file-line-error -cd "$SRC"
status=$?

echo "== manuscript compile exit code: $status ==" >&2
if [ "$status" -ne 0 ]; then
  echo "BUILD FAILED (latexmk exit $status)" >&2
fi
exit "$status"
