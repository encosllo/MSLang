#!/usr/bin/env python3
"""Tests for the calibration corpus and statistics (Section 11.4).

Run:
    python3 scripts/calibration_test.py
"""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import calibration  # noqa: E402

FAILURES = []


def check(name, condition, detail=""):
    print(f"[{'PASS' if condition else 'FAIL'}] {name}" + (f" -- {detail}" if detail and not condition else ""))
    if not condition:
        FAILURES.append(name)


def main():
    seed = calibration.load_json(calibration.DEFAULT_SEED)

    check("real corpus is structurally valid", calibration.corpus_errors(seed) == [],
          str(calibration.corpus_errors(seed)))

    bad = copy.deepcopy(seed)
    for c in bad["cases"]:
        if c["type"] == "control":
            c["readback"] = "something else"
            break
    check("a control that differs from its base is flagged",
          any("control read-back differs" in e for e in calibration.corpus_errors(bad)))

    bad2 = copy.deepcopy(seed)
    for c in bad2["cases"]:
        if c["type"] != "control":
            c["readback"] = bad2["base_readbacks"][c["block"]]
            break
    check("a mutation equal to its base is flagged",
          any("equals its base" in e for e in calibration.corpus_errors(bad2)))

    bad3 = copy.deepcopy(seed)
    bad3["cases"].append(copy.deepcopy(bad3["cases"][0]))
    check("a duplicate id is flagged",
          any("duplicate id" in e for e in calibration.corpus_errors(bad3)))

    check("is_detected: equivalent is not a detection",
          calibration.is_detected("equivalent") is False)
    check("is_detected: incomparable is a detection",
          calibration.is_detected("incomparable") is True)
    check("is_detected: formal_stronger is a detection",
          calibration.is_detected("formal_stronger") is True)

    per_type, controls, total = calibration.summarize(
        seed,
        {
            "CAL-002": "incomparable",   # direction_flip, detected
            "CAL-003": "equivalent",     # conclusion_reverse, missed
            "CAL-001": "incomparable",   # control false positive
        },
    )
    check("detection counted per type",
          per_type["direction_flip"] == {"n": 1, "detected": 1}
          and per_type["conclusion_reverse"] == {"n": 1, "detected": 0},
          str(per_type))
    check("control false positive counted",
          controls["false_positive"] == 1, str(controls))
    check("overall mutations-only totals",
          total["n"] == 2 and total["detected"] == 1, str(total))

    print()
    if FAILURES:
        print(f"calibration_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("calibration_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
