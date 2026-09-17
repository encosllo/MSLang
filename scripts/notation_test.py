#!/usr/bin/env python3
"""Tests for notation resolutions (Architecture.md Sections 12.1, 16.4).

Run:
    python3 scripts/notation_test.py
"""
from __future__ import annotations

import json
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import notation  # noqa: E402

FAILURES = []


def check(name, condition, detail=""):
    print(f"[{'PASS' if condition else 'FAIL'}] {name}" + (f" -- {detail}" if detail and not condition else ""))
    if not condition:
        FAILURES.append(name)


def main():
    check("the real store loads", isinstance(notation.load(notation.DEFAULT_STORE), dict))
    check("a valid block resolution passes validation",
          notation.validate({"supp": {"resolution": "block", "target": "B-D009",
                                      "decided_by": "author:s82"}}) == [])
    check("a valid ambient resolution passes validation",
          notation.validate({"Hom": {"resolution": "ambient", "target": None,
                                     "decided_by": "author:s82"}}) == [])
    check("a block resolution without a B- target is rejected",
          notation.validate({"supp": {"resolution": "block", "target": "nope",
                                      "decided_by": "author:s82"}}) != [])
    check("an unknown resolution value is rejected",
          notation.validate({"supp": {"resolution": "maybe",
                                      "decided_by": "author:s82"}}) != [])
    check("a recorded resolution must name an author decision",
          notation.validate({"supp": {"resolution": "block", "target": "B-D009",
                                      "decided_by": "agent:opencode"}}) != [])
    check("an agent cannot set a resolution", not notation.check_author("agent:opencode"))
    check("an author can set a resolution", notation.check_author("author:session82"))

    with tempfile.TemporaryDirectory() as tmp:
        store = Path(tmp) / "notation.json"
        store.write_text(json.dumps({"note": "t", "resolutions": {}}), encoding="utf-8")
        rc = notation.main(["--store", str(store), "set", "--notation", "supp",
                            "--resolution", "block", "--target", "B-D009",
                            "--decided-by", "agent:opencode"])
        check("the CLI refuses an agent write", rc == 1)
        check("the refused write changed nothing", notation.load(store) == {})
        rc2 = notation.main(["--store", str(store), "set", "--notation", "supp",
                             "--resolution", "block", "--target", "B-D009",
                             "--decided-by", "author:session82",
                             "--rationale", "root support definition"])
        check("the CLI accepts an author write", rc2 == 0)
        loaded = notation.load(store)
        check("the resolution survives a reload",
              loaded.get("supp", {}).get("target") == "B-D009", str(loaded))
        check("the accepted store validates", notation.validate(loaded) == [])

    print()
    if FAILURES:
        print(f"notation_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("notation_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
