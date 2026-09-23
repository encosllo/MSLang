#!/usr/bin/env bash
# Exit-code-checked manuscript build wrapper.
#
# Architecture.md Sections 10.6 item 5 and 13.3 item 3: never trust the
# printed log alone. Under latin1 a dropped character can produce a
# clean-looking log while the process exit code is still non-zero.
#
# The source is the active project's `manuscript` (projects.yaml), so a second
# manuscript builds with `--project <id>` and the default is unchanged.
#
# Usage: scripts/build_manuscript.sh [--project ID] [--no-scan]
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/env.sh
. "$ROOT/scripts/env.sh"

PROJECT="${MSLANG_PROJECT:-mslang}"
SCAN=1
while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2 ;;
    --no-scan) SCAN=0; shift ;;
    *) echo "build_manuscript: unknown argument: $1" >&2; exit 2 ;;
  esac
done

# Re-resolve the project's paths when a project was named explicitly.
if [ "$PROJECT" != "${MSLANG_PROJECT:-}" ] && [ -f "$ROOT/projects.yaml" ]; then
  eval "$(python3 "$ROOT/scripts/projects.py" --env "$PROJECT" 2>/dev/null)"
fi

SRC="${MSLANG_MANUSCRIPT:-$ROOT/manuscript/MSEilenberg.tex}"
command -v latexmk >/dev/null 2>&1 || { echo "latexmk not found" >&2; exit 127; }

if [ "$SCAN" = "1" ]; then
  echo "== non-ASCII scan ==" >&2
  if ! python3 "$ROOT/scripts/nonascii_scan.py" "$SRC"; then
    echo "BUILD ABORTED: suspicious UTF-8 in a latin1 source." >&2
    exit 3
  fi
fi

echo "== latexmk -pdf ($PROJECT: $SRC) ==" >&2
latexmk -pdf -interaction=nonstopmode -file-line-error -cd "$SRC"
status=$?

echo "== manuscript compile exit code: $status ==" >&2
if [ "$status" -ne 0 ]; then
  echo "BUILD FAILED (latexmk exit $status)" >&2
fi
exit "$status"
