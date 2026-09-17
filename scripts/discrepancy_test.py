#!/usr/bin/env python3
"""Tests for the dependency-graph discrepancy report (Sections 12.2, 19).

Run:
    python3 scripts/discrepancy_test.py
"""
from __future__ import annotations

import sys
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import discrepancy  # noqa: E402

ROOT = HERE.parent
FAILURES = []


def check(name, condition, detail=""):
    print(f"[{'PASS' if condition else 'FAIL'}] {name}" + (f" -- {detail}" if detail and not condition else ""))
    if not condition:
        FAILURES.append(name)


def main():
    informal = [("A", "B"), ("A", "C"), ("B", "C"), ("D", "A"), ("E", "F")]
    formal = [("A", "B"), ("A", "C"), ("C", "A"), ("B", "C")]
    d = discrepancy.compare(informal, formal)
    check("agreeing edges", d["agree"] == [("A", "B"), ("A", "C"), ("B", "C")], str(d["agree"]))
    check("formal-only edge found", d["formal_only"] == [("C", "A")], str(d["formal_only"]))
    check("unmapped informal edges are separated out",
          all(a not in d["universe"] or b not in d["universe"] for a, b in d["unmapped"]),
          str(d["unmapped"]))

    # Real repo: the mapped universe is non-trivial and cross-checked.
    real_informal = discrepancy.load_edges(ROOT / "blocks" / "graph.json", discrepancy.DEPENDENCY_KINDS)
    real_formal = discrepancy.load_edges(ROOT / "blocks" / "formal_graph.json")
    rd = discrepancy.compare(real_informal, real_formal)
    check("real formal graph is non-empty", bool(real_formal))
    check("real mapped universe includes the pilot definitions",
          {"B-D002", "B-D014"} <= set(rd["universe"]), str(rd["universe"]))
    check("real B-C001 uses B-D014 formally",
          ("B-C001", "B-D014") in set(real_formal))

    notes = json.loads((ROOT / "blocks" / "discrepancy_notes.json").read_text(encoding="utf-8"))["notes"]
    check("the informal-only edge is annotated",
          "B-P002->B-D006" in notes, str(sorted(notes)))

    # Typed dispositions (Section 12.2).
    decisions = discrepancy.load_decisions(
        ROOT / "blocks" / "discrepancy_decisions.json",
        ROOT / "blocks" / "discrepancy_notes.json",
    )
    check("recorded dispositions load", "B-P002->B-D006" in decisions, str(sorted(decisions)))
    check("recorded dispositions are valid", discrepancy.validate_decisions(decisions) == [])
    check("an unknown disposition is rejected",
          discrepancy.validate_decisions({"X->Y": {"disposition": "whatever"}}) != [])
    check("the carrier pattern defaults to type-carrier",
          discrepancy.default_disposition("B-P001", "B-D002") == "type-carrier")
    check("an unmatched edge has no default",
          discrepancy.default_disposition("B-P001", "B-P002") is None)
    value, source = discrepancy.disposition_of("B-C001", "B-D002", decisions)
    check("a recorded disposition wins over the default", source == "recorded", f"{value} {source}")
    undecided, defaults, reviewed = discrepancy.classify(rd, decisions)
    check("undecided rows are separated from classified rows",
          ("B-P002", "B-D006") not in undecided
          and defaults.get("type-carrier", 0) > 0,
          f"undecided={len(undecided)} defaults={defaults}")
    text = discrepancy.render_report(rd, decisions)
    check("the report states an undecided count",
          f"## Undecided edges ({len(undecided)})" in text, text[:120])
    check("default-classified edges are collapsed, not enumerated",
          "## Default-classified edges (collapsed)" in text)

    # A disposition is not evidence: it changes no layer status.
    import copy as _copy
    import status  # noqa: E402
    reg = status.load_registry(ROOT / "blocks" / "registry.json")
    recs = status.load_evidence(ROOT / "evidence")
    rep = {"encoding": status.hash_file(ROOT / "representation" / "pilot-encoding.md")}
    before = {
        b: status.block_status(layers, reg, rep, block=b)
        for b, layers in status.group_by_block_layer(recs).items()
    }
    discrepancy.classify(rd, decisions)
    after = {
        b: status.block_status(layers, reg, rep, block=b)
        for b, layers in status.group_by_block_layer(recs).items()
    }
    check("recording dispositions changes no layer status", before == after)

    print()
    if FAILURES:
        print(f"discrepancy_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("discrepancy_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
