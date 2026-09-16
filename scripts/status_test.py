#!/usr/bin/env python3
"""Tests for the evidence validity rule and layer status (Sections 7.2, 8).

Builds *synthetic* records from computed closures -- never authored evidence --
and checks that the validity rule responds soundly to seeded changes.

Run:
    python3 scripts/status_test.py
"""
from __future__ import annotations

import copy
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import closure  # noqa: E402
import status  # noqa: E402

ROOT = HERE.parent
REGISTRY = closure.load_registry(ROOT / "blocks" / "registry.json")
EDGES = closure.load_edges(ROOT / "blocks" / "graph.json", confirmed_only=True)
REP_HASH = "r" * 64
REP = {"encoding": REP_HASH}

FAILURES = []


def check(name, condition, detail=""):
    print(f"[{'PASS' if condition else 'FAIL'}] {name}" + (f" -- {detail}" if detail and not condition else ""))
    if not condition:
        FAILURES.append(name)


def make_record(outcome="pass", block="B-P002", layer="review", registry=None):
    reg = registry or REGISTRY
    cl = closure.compute_closure(
        block, layer, reg, EDGES, representation_hash=REP_HASH
    )
    assert not cl.get("blocked"), cl
    return {
        "evidence_id": "E-000001",
        "layer": layer,
        "block": block,
        "inputs": cl["inputs"],
        "outcome": outcome,
    }


def main():
    rec = make_record()
    check("synthetic record is current", status.record_is_current(rec, REGISTRY, REP))

    # Seed a dependency statement change.
    changed = copy.deepcopy(REGISTRY)
    changed["B-D014"]["facets"]["informal_statement"]["hash"] = "a" * 64
    check(
        "dependency statement change stales the record",
        not status.record_is_current(rec, changed, REP),
    )

    # Seed a dependency proof change (not an input) -> still current.
    dep_proof = copy.deepcopy(REGISTRY)
    dep_proof["B-D014"]["facets"]["informal_proof"] = {"hash": "b" * 64}
    check(
        "dependency proof change keeps the record current",
        status.record_is_current(rec, dep_proof, REP),
    )

    # Representation change -> stale.
    check(
        "representation change stales the record",
        not status.record_is_current(rec, REGISTRY, {"encoding": "d" * 64}),
    )

    # Unresolvable representation -> fail closed.
    check(
        "missing representation fails closed",
        not status.record_is_current(rec, REGISTRY, {}),
    )

    # Layer status: pass, stale, fail, none.
    fresh = make_record("pass")
    check("layer pass", status.layer_status([fresh], REGISTRY, REP)[0] == "pass")
    stale_rec = make_record("pass")
    stale_rec["inputs"][0]["hash"] = "e" * 64
    check("layer stale", status.layer_status([stale_rec], REGISTRY, REP)[0] == "stale")
    neg = make_record("fail")
    check("layer fail", status.layer_status([neg], REGISTRY, REP)[0] == "fail")
    check("layer none", status.layer_status([], REGISTRY, REP)[0] == "none")
    check(
        "current beats stale",
        status.layer_status([stale_rec, fresh], REGISTRY, REP)[0] == "pass",
    )

    # Supersession: a stale record in a layer that still has current evidence is
    # superseded; one whose layer has no current evidence is awaiting.
    successor = make_record("pass")
    successor["evidence_id"] = "E-000002"
    successor["supersedes"] = stale_rec["evidence_id"]
    st, detail = status.layer_status([stale_rec, successor], REGISTRY, REP)
    check(
        "stale with current evidence in its layer is superseded",
        st == "pass" and detail["superseded"] == 1 and detail["awaiting"] == 0,
        str(detail),
    )
    st2, detail2 = status.layer_status([stale_rec], REGISTRY, REP)
    check(
        "stale with no current evidence in its layer is awaiting",
        st2 == "stale" and detail2["superseded"] == 0 and detail2["awaiting"] == 1,
        str(detail2),
    )

    # Independent layers do not contaminate each other.
    grouped = status.group_by_block_layer([fresh, neg])
    bs = status.block_status(grouped["B-P002"], REGISTRY, REP)
    check(
        "block status groups by layer",
        set(bs) == {"review"} and bs["review"]["status"] == "fail",
        str(bs),
    )

    print()
    if FAILURES:
        print(f"status_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("status_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
