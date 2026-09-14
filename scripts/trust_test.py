#!/usr/bin/env python3
"""Tests for trust-boundary propagation (Sections 6, 7.5, 11.5).

Builds *synthetic* representation records -- never authored evidence -- and
checks that a `faithful-with-caveat` audit propagates exactly its residuals to
exactly the blocks it covers, and that a stale audit fails the boundary closed.

Run:
    python3 scripts/trust_test.py
"""
from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import status  # noqa: E402
import trust  # noqa: E402

ROOT = HERE.parent
REP_HASH = "r" * 64
REP = {"encoding": REP_HASH}

FINDINGS = [
    "D1 (universe): Bounded: none of the pilot-cluster statements depend on "
    "U-large objects.",
    "D2 (carrier model): Residual caveat; must be propagated into dependent "
    "trust boundaries.",
    "D4 (Setoid vs relation): a bridge obligation that is NOT yet proved.",
    "D3/D5 bounded: no absolute complement and no quotient construction.",
    "D6: permitted axioms. D7: empty sorts permitted.",
    "Verdict: faithful-with-caveat with residuals D1, D2, D4.",
]

FAILURES = []


def check(name, condition, detail=""):
    print(f"[{'PASS' if condition else 'FAIL'}] {name}" + (f" -- {detail}" if detail and not condition else ""))
    if not condition:
        FAILURES.append(name)


def rep_record(outcome="faithful-with-caveat", findings=None, rep_hash=REP_HASH):
    return {
        "evidence_id": "E-000002",
        "layer": "representation",
        "block": "representation/encoding",
        "inputs": [{"artifact": "representation/encoding", "hash": rep_hash}],
        "outcome": outcome,
        "findings": FINDINGS if findings is None else findings,
    }


def run_synthetic():
    coverage = {"encoding": {"file": "representation/pilot-encoding.md",
                             "blocks": ["B-C001", "B-D002"],
                             "bridge_obligations": ["setoid_le_iff"]}}
    registry = {"B-C001": {}, "B-D002": {}, "B-D001": {}}

    reps, boundary = trust.compute(
        registry, coverage, [rep_record()], REP
    )
    check("residual parser ignores bounded labels",
          reps["encoding"]["residuals"] == ["D1", "D2", "D4"],
          str(reps["encoding"]["residuals"]))
    check("covered block inherits residuals",
          trust.block_residuals(boundary["B-C001"]) == ["D1", "D2", "D4"],
          str(boundary["B-C001"]))
    check("all covered blocks inherit",
          trust.block_residuals(boundary["B-D002"]) == ["D1", "D2", "D4"])
    check("uncovered block has none",
          boundary["B-D001"] == [])

    reps_f, boundary_f = trust.compute(
        registry, coverage, [rep_record(outcome="faithful",
                                        findings=["Verdict: faithful."])], REP
    )
    check("faithful imposes no residual",
          reps_f["encoding"]["residuals"] == []
          and trust.block_residuals(boundary_f["B-C001"]) == [])

    # Stale audit (representation hash changed) -> boundary fails closed:
    # the residual is no longer current evidence, and an unfaithful/stale
    # outcome must not be silently treated as clean.
    reps_s, boundary_s = trust.compute(
        registry, coverage, [rep_record()], {"encoding": "s" * 64}
    )
    check("stale representation audit is not current",
          reps_s["encoding"]["current"] is False)
    check("stale audit does not assert residuals",
          trust.block_residuals(boundary_s["B-C001"]) == [])

    check("verdict is preferred over bounded findings",
          trust.residuals_from_record(
              {"findings": ["D3/D5 bounded.", "Verdict: faithful."]}
          ) == [])


def run_real():
    registry = status.load_registry(ROOT / "blocks" / "registry.json")
    records = status.load_evidence(ROOT / "evidence")
    coverage = trust.load_coverage(ROOT / "representation" / "coverage.json")
    rep = {"encoding": trust.hash_file(ROOT / "representation" / "pilot-encoding.md")}
    reps, boundary = trust.compute(registry, coverage, records, rep)
    check("real encoding audit parsed",
          reps["encoding"]["outcome"] == "faithful-with-caveat"
          and reps["encoding"]["residuals"] == ["D1", "D2", "D4"],
          str(reps["encoding"]))
    check("real B-C001 trust boundary carries the caveat",
          trust.block_residuals(boundary["B-C001"]) == ["D1", "D2", "D4"])
    check("real covered definition carries the caveat",
          trust.block_residuals(boundary["B-D014"]) == ["D1", "D2", "D4"])
    check("real uncovered block carries none",
          trust.block_residuals(boundary["B-D001"]) == [])


def main():
    run_synthetic()
    run_real()
    print()
    if FAILURES:
        print(f"trust_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("trust_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
