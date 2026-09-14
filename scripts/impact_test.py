#!/usr/bin/env python3
"""Tests for change blast-radius analysis (Sections 13.1, 13.2, 19).

Uses synthetic records built from computed closures (never authored evidence),
so the checks are independent of the current committed evidence set, plus the
real graph/registry/formal-graph.

Run:
    python3 scripts/impact_test.py
"""
from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import closure  # noqa: E402
import impact  # noqa: E402
import status  # noqa: E402

ROOT = HERE.parent
FAILURES = []


def check(name, condition, detail=""):
    print(f"[{'PASS' if condition else 'FAIL'}] {name}" + (f" -- {detail}" if detail and not condition else ""))
    if not condition:
        FAILURES.append(name)


def main():
    registry = status.load_registry(ROOT / "blocks" / "registry.json")
    edges = closure.load_edges(ROOT / "blocks" / "graph.json", confirmed_only=True)
    rep = {"encoding": status.hash_file(ROOT / "representation" / "pilot-encoding.md")}
    formal_edges = impact.load_formal_edges(ROOT / "blocks" / "formal_graph.json")
    env = {"lean": "leanprover/lean4:v4.33.1", "mathlib": "0df444a"}

    def synth(block, layer):
        cl = closure.compute_closure(
            block, layer, registry, edges, representation_hash=rep["encoding"],
            environment=env if layer == "verification" else None,
        )
        assert not cl.get("blocked"), cl
        return {"evidence_id": f"E-synth-{block}-{layer}", "layer": layer,
                "block": block, "inputs": cl["inputs"]}

    def pairs(staled):
        return {(r["block"], r["layer"]) for r in staled}

    records = [synth("B-C001", "review"), synth("B-C001", "verification"),
               synth("B-C002", "correspondence"), synth("B-P002", "correspondence")]

    blocks = impact.affected_blocks("B-D014", edges)
    check("downstream closure reaches the pilot corollaries",
          {"B-C001", "B-C002", "B-P002", "B-P003"} <= set(blocks), str(blocks))

    staled = impact.simulate("B-D014/informal_statement", registry, records, rep)
    check("definition statement change stales review/correspondence",
          ("B-C001", "review") in pairs(staled) and ("B-C002", "correspondence") in pairs(staled),
          str(pairs(staled)))
    check("definition statement change does not stale verification",
          ("B-C001", "verification") not in pairs(staled), str(pairs(staled)))

    own = impact.simulate("B-C001/formal_proof", registry, records, rep)
    check("own proof change stales own verification",
          ("B-C001", "verification") in pairs(own), str(pairs(own)))
    check("own proof change does not stale own review",
          ("B-C001", "review") not in pairs(own), str(pairs(own)))

    rep_change = impact.simulate("representation/encoding", registry, records, rep)
    check("representation change stales records listing it",
          ("B-C001", "review") in pairs(rep_change)
          and ("B-P002", "correspondence") in pairs(rep_change),
          str(pairs(rep_change)))

    def_change = impact.simulate("B-D014/formal_statement", registry, records, rep,
                                 formal_edges=formal_edges)
    check("formal definition change reaches dependent correspondence",
          ("B-C002", "correspondence") in pairs(def_change), str(pairs(def_change)))
    check("formal definition change does not stale verification",
          ("B-C001", "verification") not in pairs(def_change), str(pairs(def_change)))

    print()
    if FAILURES:
        print(f"impact_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("impact_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
