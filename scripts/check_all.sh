#!/usr/bin/env bash
# Run every mechanical check for the workspace (Architecture.md Sections 13.3,
# 21 Phase 4). Intended both as a safe-restart gate and as a pre-commit/CI
# entry point.
#
# Checks, in order:
#   1. non-ASCII scanner (latin1 source)
#   2. anchor hashes current           (blocks/hashes.json)
#   3. importer artifacts up to date    (blocks/{registry,symbols,graph}.json)
#   4. cross-reference audit            (undefined \ref targets)
#   5. hygiene tests                    (line shift / locality / re-ingest)
#   6. propagation tests                (closures, proof irrelevance, fail-closed)
#   7. status tests                     (validity rule, layer status)
#   8. trust boundary tests             (representation residuals propagate)
#   9. record schema validation         (journal + evidence)
#  10. project views current            (reports/ drift check)
#  11. exit-code-checked manuscript build
#
# Usage: scripts/check_all.sh
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 2
# shellcheck source=scripts/env.sh
. "$ROOT/scripts/env.sh"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

PASS=0
FAIL=0
FAILED=()

run() {
  local name="$1"
  shift
  if "$@" >"$TMP" 2>&1; then
    printf 'PASS  %s\n' "$name"
    PASS=$((PASS + 1))
  else
    printf 'FAIL  %s\n' "$name"
    sed 's/^/      /' "$TMP"
    FAIL=$((FAIL + 1))
    FAILED+=("$name")
  fi
}

run "non-ASCII scan" python3 scripts/nonascii_scan.py manuscript/MSEilenberg.tex
run "anchor hashes current" python3 scripts/hash_blocks.py --check blocks/hashes.json manuscript/MSEilenberg.tex
run "importer artifacts current" python3 scripts/ingest.py --check --aux manuscript/MSEilenberg.aux manuscript/MSEilenberg.tex
run "cross-reference audit" python3 scripts/check_crossrefs.py --audit manuscript/MSEilenberg.tex
run "hygiene tests" python3 scripts/hygiene_test.py
run "propagation tests" python3 scripts/propagation_test.py
run "status tests" python3 scripts/status_test.py
run "trust boundary tests" python3 scripts/trust_test.py
run "record schema validation" python3 scripts/validate_records.py
run "project views current" python3 scripts/report.py --check
run "manuscript build" scripts/build_manuscript.sh

echo
printf 'check_all: %d passed, %d failed\n' "$PASS" "$FAIL"
if [ "$FAIL" -ne 0 ]; then
  printf 'failed: %s\n' "${FAILED[*]}"
  exit 1
fi
