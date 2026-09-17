#!/usr/bin/env python3
"""Tests for scope dispositions (Architecture.md Sections 16.4, 17).

Run:
    python3 scripts/scope_test.py
"""
from __future__ import annotations

import json
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import scope  # noqa: E402

FAILURES = []


def check(name, condition, detail=""):
    print(f"[{'PASS' if condition else 'FAIL'}] {name}" + (f" -- {detail}" if detail and not condition else ""))
    if not condition:
        FAILURES.append(name)


def main():
    check("the real store loads", isinstance(scope.load(scope.DEFAULT_STORE), dict))
    check("an unknown disposition is rejected",
          scope.validate({"B-X001": {"disposition": "maybe"}}) != [])
    check("a valid disposition passes validation",
          scope.validate({"B-X001": {"disposition": "deferred"}}) == [])
    check("an agent cannot set a scope disposition", not scope.check_author("agent:opencode"))
    check("an author can set a scope disposition", scope.check_author("author:session81"))

    with tempfile.TemporaryDirectory() as tmp:
        store = Path(tmp) / "scope.json"
        store.write_text(json.dumps({"note": "t", "dispositions": {}}), encoding="utf-8")
        rc = scope.main(["--store", str(store), "set", "--block", "B-X001",
                         "--disposition", "deferred", "--decided-by", "agent:opencode"])
        check("the CLI refuses an agent write", rc == 1)
        check("the refused write changed nothing", scope.load(store) == {})
        rc2 = scope.main(["--store", str(store), "set", "--block", "B-X001",
                          "--disposition", "deferred", "--decided-by", "author:session81",
                          "--rationale", "not on the critical path"])
        check("the CLI accepts an author write", rc2 == 0)
        loaded = scope.load(store)
        check("the disposition survives a reload",
              loaded.get("B-X001", {}).get("disposition") == "deferred", str(loaded))

    print()
    if FAILURES:
        print(f"scope_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("scope_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
