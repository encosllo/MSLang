#!/usr/bin/env bash
# Mechanical checks for the workspace (Architecture.md Sections 13.3, 21).
#
# Two tiers, one entry point:
#   --fast   every check that needs neither Lean compilation nor a manuscript
#            PDF build; seconds-fast; the default per-edit gate. Slow-only
#            checks are printed as DEFERRED, never as PASS.
#   (none)   the full gate: fast checks plus the Lean mechanical gate and the
#            manuscript build; the artifact of record at session close.
#
# Usage: scripts/check_all.sh [--fast]
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 2
# shellcheck source=scripts/env.sh
. "$ROOT/scripts/env.sh"

MODE="full"
if [ "${1:-}" = "--fast" ]; then MODE="fast"; fi

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

PASS=0
FAIL=0
DEFERRED=0
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

defer() {
  printf 'DEFERRED  %s (slow tier)\n' "$1"
  DEFERRED=$((DEFERRED + 1))
}

# --- fast tier: no Lean compilation, no PDF ---------------------------------
run "non-ASCII scan" python3 scripts/nonascii_scan.py manuscript/MSEilenberg.tex
run "anchor hashes current" python3 scripts/hash_blocks.py --check blocks/hashes.json manuscript/MSEilenberg.tex
run "importer artifacts current" python3 scripts/ingest.py --check --aux manuscript/MSEilenberg.aux manuscript/MSEilenberg.tex
run "notation resolutions valid" python3 scripts/notation.py --check
run "notation tests" python3 scripts/notation_test.py
run "ingest tests" python3 scripts/ingest_test.py
run "cross-reference audit" python3 scripts/check_crossrefs.py --audit manuscript/MSEilenberg.tex
run "hygiene tests" python3 scripts/hygiene_test.py
run "propagation tests" python3 scripts/propagation_test.py
run "status tests" python3 scripts/status_test.py
run "trust boundary tests" python3 scripts/trust_test.py
run "model registry + tests" python3 scripts/models.py --check
run "model routing tests" python3 scripts/models_test.py
run "Lean facet tests" python3 scripts/lean_facets_test.py
run "Lean formal facets current" python3 scripts/lean_facets.py --check
run "calibration corpus + tests" python3 scripts/calibration.py --self-test
run "calibration statistics tests" python3 scripts/calibration_test.py
run "calibration baseline" python3 scripts/calibration.py --check-baseline
run "calibration report current" python3 scripts/calibration.py --verdicts calibration/verdicts.json --check-report
run "impact tests" python3 scripts/impact_test.py
run "impact report current" python3 scripts/impact.py --artifact B-D014/informal_statement --check-report
run "discrepancy tests" python3 scripts/discrepancy_test.py
run "discrepancy dispositions valid" python3 scripts/discrepancy.py --check-dispositions
run "discrepancy report current" python3 scripts/discrepancy.py --check-report
run "scope dispositions valid" python3 scripts/scope.py --check
run "scope tests" python3 scripts/scope_test.py
run "treatment tiers valid" python3 scripts/tiers.py --check
run "treatment tiers tests" python3 scripts/tiers_test.py
run "decisions tests" python3 scripts/decisions_test.py
run "decisions report current" python3 scripts/decisions.py --check-report
run "sanity checks report current" python3 scripts/sanity.py --check-report
run "reconciliation tests" python3 scripts/reconcile_test.py
run "reconciliation report current" python3 scripts/reconcile.py --check-report
run "evidence bundle current" python3 scripts/bundle.py --check-report
run "frontier report current" python3 scripts/frontier.py --check-report
run "ranking goal valid" python3 scripts/ranking.py --check
run "ranking tests" python3 scripts/ranking_test.py
run "ranking report current" python3 scripts/ranking.py --check-report
run "record schema validation" python3 scripts/validate_records.py
run "project views current" python3 scripts/report.py --check

# --- slow tier: Lean mechanical gate + manuscript build ---------------------
if [ "$MODE" = "fast" ]; then
  defer "Lean audit tests"
  defer "Lean mechanical gate current"
  defer "manuscript build"
else
  run "Lean audit tests" python3 scripts/lean_audit_test.py
  run "Lean mechanical gate current" python3 scripts/lean_audit.py --check
  run "manuscript build" scripts/build_manuscript.sh
fi

echo
if [ "$MODE" = "fast" ]; then
  printf 'check_all (fast): %d passed, %d failed, %d deferred\n' "$PASS" "$FAIL" "$DEFERRED"
else
  printf 'check_all: %d passed, %d failed\n' "$PASS" "$FAIL"
fi
if [ "$FAIL" -ne 0 ]; then
  printf 'failed: %s\n' "${FAILED[*]}"
  exit 1
fi
