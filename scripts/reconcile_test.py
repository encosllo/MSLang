#!/usr/bin/env python3
"""Tests for manuscript reconciliation (Architecture.md Section 11a.5).

Run:
    python3 scripts/reconcile_test.py
"""
from __future__ import annotations

import json
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import reconcile  # noqa: E402

FAILURES = []


def check(name, condition, detail=""):
    print(f"[{'PASS' if condition else 'FAIL'}] {name}" + (f" -- {detail}" if detail and not condition else ""))
    if not condition:
        FAILURES.append(name)


def main():
    real = reconcile.load()
    check("the real catalogue has two open reconstructed-proof proposals",
          len(real) >= 2 and all(
              p["kind"] == "reconstructed-proof" and p["state"] == "open"
              for p in real.values()),
          str(real))

    with tempfile.TemporaryDirectory() as tmp:
        ex = Path(tmp) / "explanations"
        ex.mkdir()
        (ex / "B-Z001.md").write_text("# Explanation for `B-Z001` -- PROPOSED\n\nText.\n",
                                      encoding="utf-8")
        proposals = {}
        n = reconcile.sync_explanations(proposals, ex)
        check("sync registers one proposal per Explanation", n == 1, str(proposals))
        pid = next(iter(proposals))
        check("a proposal records its kind, source, and state",
              proposals[pid]["kind"] == "reconstructed-proof"
              and proposals[pid]["source"].endswith("B-Z001.md")
              and proposals[pid]["state"] == "open", str(proposals[pid]))

        err = reconcile.set_state(proposals, pid, "accepted", "agent:opencode",
                                  "a" * 64)
        check("an agent cannot accept a proposal", err is not None, str(err))
        check("the refused acceptance changed nothing",
              proposals[pid]["state"] == "open", str(proposals[pid]))

        err2 = reconcile.set_state(proposals, pid, "accepted", "author:session81", None)
        check("acceptance without a manuscript hash is refused", err2 is not None, str(err2))

        err3 = reconcile.set_state(proposals, pid, "accepted", "author:session81", "b" * 64)
        check("an author acceptance with a hash succeeds", err3 is None, str(err3))
        check("an accepted proposal records the manuscript hash",
              proposals[pid]["state"] == "accepted"
              and proposals[pid]["manuscript_hash"] == "b" * 64,
              str(proposals[pid]))

        err4 = reconcile.set_state(proposals, pid, "rejected", "author:session81",
                                   rationale="exposition style")
        check("a rejection retains its rationale",
              err4 is None and proposals[pid]["rationale"] == "exposition style",
              str(proposals[pid]))

    text = reconcile.render_report(real)
    check("the view lists open proposals with their proposed change",
          "## Open proposals" in text and "reconstructed-proof" in text)

    print()
    if FAILURES:
        print(f"reconcile_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("reconcile_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
