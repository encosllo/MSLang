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
# Multi-manuscript: source-dependent checks (non-ASCII scan, anchor hashes,
# importer artifacts, cross-reference audit, record validation) run once per
# registered project and name the project; a project whose provenance has not
# been ingested yet (`ingested: false`) has those checks deferred, never
# reported as passing (OpenSpec change `add-mscong-project`).
#
# Usage: scripts/check_all.sh [--fast] [--project ID]
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 2
# shellcheck source=scripts/env.sh
. "$ROOT/scripts/env.sh"

MODE="full"
PROJECT_FILTER=""
while [ $# -gt 0 ]; do
  case "$1" in
    --fast) MODE="fast"; shift ;;
    --project) PROJECT_FILTER="$2"; shift 2 ;;
    *) echo "check_all: unknown argument: $1" >&2; exit 2 ;;
  esac
done

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
  printf 'DEFERRED  %s\n' "$1"
  DEFERRED=$((DEFERRED + 1))
}

project_field() { python3 scripts/projects.py --field "$1" "$2"; }

project_selection() {
  if [ -n "$PROJECT_FILTER" ]; then
    printf '%s\n' "$PROJECT_FILTER"
  else
    python3 scripts/projects.py --list
  fi
}

run_project_checks() {
  local pid="$1"
  local man
  man="$(project_field "$pid" manuscript)"
  if [ -n "$man" ]; then
    run "non-ASCII scan [$pid]" python3 scripts/nonascii_scan.py "$man"
  else
    defer "non-ASCII scan [$pid] (no manuscript)"
  fi
  if [ "$(project_field "$pid" ingested)" = "true" ]; then
    run "anchor hashes current [$pid]" python3 scripts/hash_blocks.py --project "$pid" --check
    run "importer artifacts current [$pid]" python3 scripts/ingest.py --project "$pid" --check
    run "cross-reference audit [$pid]" python3 scripts/check_crossrefs.py --audit "$(project_field "$pid" source)"
  else
    defer "anchor hashes/importer/crossrefs [$pid] (provenance not yet ingested)"
  fi
  run "record schema validation [$pid]" python3 scripts/validate_records.py \
    --journal "$(project_field "$pid" journal)" \
    --evidence-dir "$(project_field "$pid" evidence_dir)"
}

echo "active project: ${MSLANG_PROJECT:-mslang}"

# --- fast tier: no Lean compilation, no PDF ---------------------------------
run "project registry valid" python3 scripts/projects.py --check
run "project registry tests" python3 scripts/projects_test.py
run "default-project golden baseline" python3 scripts/projects.py --check-baseline
run "cross-project identifier isolation" python3 scripts/projects.py --collisions

for PID in $(project_selection); do
  run_project_checks "$PID"
done

run "notation resolutions valid" python3 scripts/notation.py --check
run "notation tests" python3 scripts/notation_test.py
run "ingest tests" python3 scripts/ingest_test.py
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
run "calibration prompt current" python3 scripts/calibration.py --check-prompt
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
run "project views current" python3 scripts/report.py --check

# --- slow tier: Lean mechanical gate + manuscript build ---------------------
if [ "$MODE" = "fast" ]; then
  defer "Lean audit tests (slow tier)"
  defer "Lean mechanical gate current (slow tier)"
  defer "manuscript build (slow tier)"
else
  run "Lean audit tests" python3 scripts/lean_audit_test.py
  run "Lean mechanical gate current" python3 scripts/lean_audit.py --check
  run "manuscript build" scripts/build_manuscript.sh
fi

echo
if [ "$MODE" = "fast" ]; then
  printf 'check_all (fast) project=%s: %d passed, %d failed, %d deferred\n' \
    "${MSLANG_PROJECT:-mslang}" "$PASS" "$FAIL" "$DEFERRED"
else
  printf 'check_all project=%s: %d passed, %d failed\n' \
    "${MSLANG_PROJECT:-mslang}" "$PASS" "$FAIL"
fi
if [ "$FAIL" -ne 0 ]; then
  printf 'failed: %s\n' "${FAILED[*]}"
  exit 1
fi
