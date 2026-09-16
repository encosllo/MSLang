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
#  10. Lean formal facets current       (blocks/formal{,_graph}.json drift)
#  10b. Lean audit tests               (gate parsing, Section 15.6)
#  10c. Lean mechanical gate current   (build+axioms+sorry, Section 15.6)
#  11. calibration corpus + tests       (seeded mismatches, Section 11.4)
#  12. calibration report current       (reports/calibration.md drift check)
#  13. impact tests                     (blast radius, Sections 13.1/19)
#  14. impact report current            (reports/impact.md drift check)
#  15. discrepancy tests                (informal vs formal graph, Section 12.2)
#  16. discrepancy report current       (reports/discrepancy.md drift check)
#  17. decisions tests                  (decision queue, Sections 16.4/19)
#  18. decisions report current         (reports/decisions.md drift check)
#  19. sanity checks report current     (reports/sanity.md drift check)
#  20. evidence bundle current          (reports/bundle.md drift check)
#  21. record schema validation         (journal + evidence)
#  22. frontier report current           (reports/frontier.md drift check)
#  23. project views current            (reports/ drift check)
#  24. exit-code-checked manuscript build
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
run "Lean audit tests" python3 scripts/lean_audit_test.py
run "Lean mechanical gate current" python3 scripts/lean_audit.py --check
run "calibration corpus + tests" python3 scripts/calibration.py --self-test
run "calibration statistics tests" python3 scripts/calibration_test.py
run "calibration report current" python3 scripts/calibration.py --verdicts calibration/verdicts.json --check-report
run "impact tests" python3 scripts/impact_test.py
run "impact report current" python3 scripts/impact.py --artifact B-D014/informal_statement --check-report
run "discrepancy tests" python3 scripts/discrepancy_test.py
run "discrepancy report current" python3 scripts/discrepancy.py --check-report
run "decisions tests" python3 scripts/decisions_test.py
run "decisions report current" python3 scripts/decisions.py --check-report
run "sanity checks report current" python3 scripts/sanity.py --check-report
run "evidence bundle current" python3 scripts/bundle.py --check-report
run "frontier report current" python3 scripts/frontier.py --check-report
run "record schema validation" python3 scripts/validate_records.py
run "project views current" python3 scripts/report.py --check
run "manuscript build" scripts/build_manuscript.sh

echo
printf 'check_all: %d passed, %d failed\n' "$PASS" "$FAIL"
if [ "$FAIL" -ne 0 ]; then
  printf 'failed: %s\n' "${FAILED[*]}"
  exit 1
fi
