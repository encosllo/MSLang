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


def make_record(outcome="pass", block="B-P002", layer="review", registry=None,
                independence=None):
    reg = registry or REGISTRY
    cl = closure.compute_closure(
        block, layer, reg, EDGES, representation_hash=REP_HASH
    )
    assert not cl.get("blocked"), cl
    record = {
        "evidence_id": "E-000001",
        "layer": layer,
        "block": block,
        "inputs": cl["inputs"],
        "outcome": outcome,
        "producer": {"kind": "agent", "role": "comparator", "model": "model-a"},
    }
    record["independence"] = independence or {
        "class": "cross_model",
        "stages": [
            {"role": "read_back_auditor", "model": "model-a"},
            {"role": "comparator", "model": "model-b"},
        ],
    }
    return record


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

    # Independence (Section 9): a same-model positive layer is provisional
    # unless the block is explicitly light-tier; build and cross-model pass.
    same = make_record("pass", independence={
        "class": "same_model",
        "stages": [{"role": "comparator", "model": "model-a"}],
    })
    check(
        "same-model layer is provisional (unclassified is not light)",
        status.layer_status([same], REGISTRY, REP)[0] == "provisional",
    )
    check(
        "same-model layer with an explicit light tier passes",
        status.layer_status([same], REGISTRY, REP, tier="light")[0] == "pass",
    )
    check(
        "same-model layer with a cabinet tier is provisional",
        status.layer_status([same], REGISTRY, REP, tier="cabinet")[0] == "provisional",
    )
    build = make_record("build_ok", independence={"class": "build"})
    check(
        "build layer passes",
        status.layer_status([build], REGISTRY, REP)[0] == "pass",
    )
    check(
        "cross-model layer passes",
        status.layer_status([fresh], REGISTRY, REP)[0] == "pass",
    )
    check(
        "a cross-model record lifts a same-model layer",
        status.layer_status([same, fresh], REGISTRY, REP)[0] == "pass",
    )
    check(
        "shadow gate reports pass but counts the flip",
        status.layer_status([same], REGISTRY, REP, gate=False)[0] == "pass",
    )

    # The tier store flows through block_status so views honour `light`.
    check("the committed tier store loads", isinstance(status.load_default_tiers(), dict))
    light_bs = status.block_status(
        {"correspondence": [same]}, REGISTRY, REP,
        tiers={"B-P002": "light"}, block="B-P002",
    )
    check("an explicit light tier clears provisional through block_status",
          light_bs["correspondence"]["status"] == "pass", str(light_bs))
    dict_bs = status.block_status(
        {"correspondence": [same]}, REGISTRY, REP,
        tiers={"B-P002": {"tier": "light"}}, block="B-P002",
    )
    check("the store's {tier: ...} entry form is honoured",
          dict_bs["correspondence"]["status"] == "pass", str(dict_bs))
    plain_bs = status.block_status(
        {"correspondence": [same]}, REGISTRY, REP, tiers={}, block="B-P002",
    )
    check("an unclassified block stays provisional through block_status",
          plain_bs["correspondence"]["status"] == "provisional", str(plain_bs))

    # Derived classification (legacy records) and derived caveat.
    legacy = make_record("pass")
    del legacy["independence"]
    legacy["producer"] = {"kind": "agent", "role": "comparator", "model": "deepseek-v4.1-flash"}
    check(
        "legacy agent record derives same_model",
        status.independence_of(legacy) == "same_model",
    )
    legacy_build = make_record("build_ok")
    del legacy_build["independence"]
    legacy_build["producer"] = {"kind": "build", "role": "coordinator"}
    check("legacy build record derives build", status.independence_of(legacy_build) == "build")
    caveat_a = status.derive_caveat(same, protocol="two-stage blind")
    caveat_b = status.derive_caveat(same, protocol="two-stage blind")
    check("derived caveat is deterministic", caveat_a == caveat_b)
    caveat_c = status.derive_caveat(
        make_record("pass", independence={
            "class": "cross_model",
            "stages": [{"role": "comparator", "model": "model-b"}],
        }),
        protocol="two-stage blind",
    )
    check("model change changes the caveat", caveat_a != caveat_c)

    print()
    if FAILURES:
        print(f"status_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("status_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
