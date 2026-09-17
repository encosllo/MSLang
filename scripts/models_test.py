#!/usr/bin/env python3
"""Tests for the model registry and independence routing (Section 9).

Run:
    python3 scripts/models_test.py
"""
from __future__ import annotations

import json
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import models  # noqa: E402

FAILURES = []


def check(name, condition, detail=""):
    print(f"[{'PASS' if condition else 'FAIL'}] {name}" + (f" -- {detail}" if detail and not condition else ""))
    if not condition:
        FAILURES.append(name)


def write_registry(tmp, entries):
    path = Path(tmp) / "models.json"
    path.write_text(json.dumps({"models": entries}), encoding="utf-8")
    return path


def main():
    real = models.load_registry(models.DEFAULT_REGISTRY)
    check("declared registry loads", "deepseek-v4.1-flash" in real, str(real))

    with tempfile.TemporaryDirectory() as tmp:
        two = write_registry(tmp, [
            {"id": "alpha-1", "family": "alpha"},
            {"id": "beta-2", "family": "beta"},
        ])
        reg2 = models.load_registry(two)
        chosen = models.choose_stages(reg2, "alpha-1", ["read_back_auditor", "comparator"])
        check("two families route the independence stage cross-family",
              chosen["class"] == "cross_model", str(chosen))
        by_role = {s["role"]: s["model"] for s in chosen["stages"]}
        check("comparator leaves the producer family",
              models.status.family_of(by_role["comparator"]) == "beta", str(by_role))
        check("read-back may stay on the producer",
              models.status.family_of(by_role["read_back_auditor"]) == "alpha", str(by_role))

        one = write_registry(tmp, [{"id": "alpha-1", "family": "alpha"}])
        reg1 = models.load_registry(one)
        solo = models.choose_stages(reg1, "alpha-1", ["read_back_auditor", "comparator"])
        check("a single family yields same_model", solo["class"] == "same_model", str(solo))

        bad = write_registry(tmp, [{"id": "alpha-1", "family": "gamma"}])
        try:
            models.load_registry(bad)
            check("family mismatch is rejected", False)
        except ValueError:
            check("family mismatch is rejected", True)

        ev = Path(tmp) / "evidence"
        ev.mkdir()
        (ev / "E-000001.json").write_text(json.dumps({
            "producer": {"model": "ghost-9"},
            "independence": {"class": "same_model",
                             "stages": [{"role": "comparator", "model": "ghost-9"}]},
        }), encoding="utf-8")
        unknown = models.check_records(reg2, ev)
        check("undeclared recorded model is flagged", len(unknown) == 1, str(unknown))
        (ev / "E-000002.json").write_text(json.dumps({
            "producer": {"model": "alpha-1", "kind": "build"},
            "independence": {"class": "build",
                             "stages": [{"role": "coordinator", "model": "build"}]},
        }), encoding="utf-8")
        unknown2 = models.check_records(reg2, ev)
        check("build pseudo-model is not flagged", len(unknown2) == 1, str(unknown2))

    print()
    if FAILURES:
        print(f"models_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("models_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
