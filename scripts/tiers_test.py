#!/usr/bin/env python3
"""Tests for treatment tiers (Architecture.md Sections 8.3, 9).

Run:
    python3 scripts/tiers_test.py
"""
from __future__ import annotations

import json
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import status  # noqa: E402
import tiers  # noqa: E402

FAILURES = []


def check(name, condition, detail=""):
    print(f"[{'PASS' if condition else 'FAIL'}] {name}" + (f" -- {detail}" if detail and not condition else ""))
    if not condition:
        FAILURES.append(name)


def main():
    check("the real store loads", isinstance(tiers.load(tiers.DEFAULT_STORE), dict))
    check("an unknown tier is rejected", tiers.validate({"B-X": {"tier": "gold"}}) != [])
    check("a cabinet tier validates", tiers.validate({"B-X": {"tier": "cabinet"}}) == [])
    check("tier_of reads the entry form",
          tiers.tier_of({"B-X": {"tier": "light"}}, "B-X") == "light")
    check("an absent block has no tier", tiers.tier_of({}, "B-X") is None)

    # status consumes the same store shape.
    check("status.tier_of agrees with tiers.tier_of",
          status.tier_of({"B-X": {"tier": "cabinet"}}, "B-X") == "cabinet")

    with tempfile.TemporaryDirectory() as tmp:
        store = Path(tmp) / "tiers.json"
        store.write_text(json.dumps({"note": "t", "tiers": {}}), encoding="utf-8")
        rc = tiers.main(["--store", str(store), "set", "--block", "B-X",
                         "--tier", "cabinet", "--decided-by", "agent:opencode"])
        check("the CLI refuses an agent write", rc == 1)
        check("the refused write changed nothing", tiers.load(store) == {})
        rc2 = tiers.main(["--store", str(store), "set", "--block", "B-X",
                          "--tier", "light", "--decided-by", "author:session81",
                          "--rationale", "docs-only"])
        check("the CLI accepts an author write", rc2 == 0)
        loaded = tiers.load(store)
        check("the tier survives a reload",
              tiers.tier_of(loaded, "B-X") == "light", str(loaded))
        check("the written store validates", tiers.validate(loaded) == [])

    print()
    if FAILURES:
        print(f"tiers_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("tiers_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
