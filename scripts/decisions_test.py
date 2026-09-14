#!/usr/bin/env python3
"""Tests for the decision queue (Sections 16.4, 19).

Run:
    python3 scripts/decisions_test.py
"""
from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import decisions  # noqa: E402

ROOT = HERE.parent
FAILURES = []


def check(name, condition, detail=""):
    print(f"[{'PASS' if condition else 'FAIL'}] {name}" + (f" -- {detail}" if detail and not condition else ""))
    if not condition:
        FAILURES.append(name)


def main():
    standing = decisions.load_standing(ROOT / "decisions" / "standing.json")
    check("standing decisions load", len(standing) >= 1, str(len(standing)))
    check("standing decisions have ids and categories",
          all("id" in d and "category" in d and "decision" in d for d in standing))

    esc = decisions.open_escalations(ROOT / "journal" / "events.jsonl")
    ids = {e.get("event_id") for e in esc}
    check("the B-D014 escalation is open", "EV-000019" in ids, str(ids))

    text = decisions.render_report(standing, esc)
    check("report names the open escalation", "EV-000019" in text)
    check("report names a standing decision", "D-representation" in text)

    print()
    if FAILURES:
        print(f"decisions_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("decisions_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
