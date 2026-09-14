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
#   9. Lean facet tests                 (statement/proof split, irrelevance)
#  10. Lean formal facets current       (blocks/formal.json drift check)
#  11. calibration corpus + tests       (seeded mismatches, Section 11.4)
#  12. calibration report current       (reports/calibration.md drift check)
#  13. impact tests                     (blast radius, Sections 13.1/19)
#  14. impact report current            (reports/impact.md drift check)
#  15. record schema validation         (journal + evidence)
#  16. project views current            (reports/ drift check)
#  17. exit-code-checked manuscript build
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
run "Lean facet tests" python3 scripts/lean_facets_test.py
run "Lean formal facets current" python3 scripts/lean_facets.py --check
run "calibration corpus + tests" python3 scripts/calibration.py --self-test
run "calibration statistics tests" python3 scripts/calibration_test.py
run "calibration report current" python3 scripts/calibration.py --verdicts calibration/verdicts.json --check-report
run "impact tests" python3 scripts/impact_test.py
run "impact report current" python3 scripts/impact.py --artifact B-D014/informal_statement --check-report
run "record schema validation" python3 scripts/validate_records.py
run "project views current" python3 scripts/report.py --check
run "manuscript build" scripts/build_manuscript.sh

echo
printf 'check_all: %d passed, %d failed\n' "$PASS" "$FAIL"
if [ "$FAIL" -ne 0 ]; then
  printf 'failed: %s\n' "${FAILED[*]}"
  exit 1
fi
