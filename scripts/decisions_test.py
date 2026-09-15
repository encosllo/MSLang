#!/usr/bin/env python3
"""Tests for the decision queue (Sections 16.4, 19).

Run:
    python3 scripts/decisions_test.py
"""
from __future__ import annotations

import json
import sys
import tempfile
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
    check("standing decisions load as a list", isinstance(standing, list), str(type(standing)))
    check("standing decisions are well formed",
          all("id" in d and "category" in d and "decision" in d for d in standing))

    # Exercise the queue logic on synthetic events so the test does not depend
    # on which real escalations happen to be open.
    with tempfile.TemporaryDirectory() as td:
        journal = Path(td) / "events.jsonl"
        journal.write_text(
            "\n".join(json.dumps(e) for e in [
                {"event_id": "EV-900001", "kind": "escalation_opened",
                 "block": "B-X001", "summary": "synthetic open",
                 "details": {"change_class": "C4"}},
                {"event_id": "EV-900002", "kind": "escalation_opened",
                 "block": "B-X002", "summary": "synthetic resolved",
                 "details": {"change_class": "C4"}},
                {"event_id": "EV-900003", "kind": "escalation_resolved",
                 "details": {"escalation": "EV-900002"}, "summary": "closed"},
            ]) + "\n",
            encoding="utf-8",
        )
        esc = decisions.open_escalations(journal)
    ids = {e.get("event_id") for e in esc}
    check("open escalation is reported", "EV-900001" in ids, str(ids))
    check("resolved escalation is filtered out", "EV-900002" not in ids, str(ids))

    sample = [{"id": "D-sample", "category": "contract", "decision": "do the thing"}]
    text = decisions.render_report(sample, esc)
    check("report names a standing decision", "D-sample" in text)
    check("report names an open escalation", "EV-900001" in text)

    # The real queue must render (the live report is checked for drift in check_all).
    real_esc = decisions.open_escalations(ROOT / "journal" / "events.jsonl")
    decisions.render_report(standing, real_esc)
    check("real journal parses as escalations", isinstance(real_esc, list))

    print()
    if FAILURES:
        print(f"decisions_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("decisions_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
