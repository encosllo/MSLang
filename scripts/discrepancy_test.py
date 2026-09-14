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

    print()
    if FAILURES:
        print(f"discrepancy_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("discrepancy_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
