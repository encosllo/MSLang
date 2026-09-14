#!/usr/bin/env python3
"""Tests for change blast-radius analysis (Sections 13.1, 13.2, 19).

Runs the non-destructive impact simulation against the *real* committed
registry, graph, and evidence, and checks that a definition-statement change
propagates to review/correspondence but not to verification (statement/proof
separation), while a proof change propagates to the block's own verification.

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
    records = status.load_evidence(ROOT / "evidence")
    rep = {"encoding": status.hash_file(ROOT / "representation" / "pilot-encoding.md")}

    def ids(staled):
        return {r["evidence_id"] for r in staled}

    def layers(staled):
        return {r["layer"] for r in staled}

    # Downstream closure: B-D014 is used by the pilot corollaries/propositions.
    blocks = impact.affected_blocks("B-D014", edges)
    check("downstream closure reaches the pilot corollaries",
          {"B-C001", "B-C002", "B-P002", "B-P003"} <= set(blocks),
          str(blocks))

    # A definition *statement* change stales review/correspondence, not verification.
    staled = impact.simulate("B-D014/informal_statement", registry, records, rep)
    check("definition statement change stales some records", bool(staled), str(ids(staled)))
    check("staled layers are review/correspondence only",
          layers(staled) <= {"review", "correspondence"}, str(layers(staled)))
    check("the pilot's B-C001 review is among the staled", "E-000001" in ids(staled),
          str(ids(staled)))

    # A block's own *proof* change stales its verification, not its review.
    own_proof = impact.simulate("B-C001/formal_proof", registry, records, rep)
    check("own proof change stales the verification record",
          "E-000003" in ids(own_proof), str(ids(own_proof)))
    check("own proof change does not stale the review record",
          "E-000001" not in ids(own_proof), str(ids(own_proof)))

    # A representation (C6) change stales every record listing it.
    rep_change = impact.simulate("representation/encoding", registry, records, rep)
    check("representation change stales records listing it",
          "E-000001" in ids(rep_change) and "E-000004" in ids(rep_change),
          str(ids(rep_change)))

    print()
    if FAILURES:
        print(f"impact_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("impact_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
