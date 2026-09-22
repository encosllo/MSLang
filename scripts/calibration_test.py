#!/usr/bin/env python3
"""Tests for the calibration corpus and statistics (Section 11.4).

Run:
    python3 scripts/calibration_test.py
"""
from __future__ import annotations

import copy
import sys
import tempfile
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
    cases = calibration.load_cases(seed)
    bases = seed["base_readbacks"]

    check("real corpus is structurally valid and meets the per-type minimum",
          calibration.corpus_errors(cases, bases) == [],
          str(calibration.corpus_errors(cases, bases)))

    hand = seed["cases"]

    bad = copy.deepcopy(hand)
    for c in bad:
        if c["type"] == "control":
            c["readback"] = "something else"
            break
    check("a control that differs from its base is flagged",
          any("control read-back differs" in e for e in calibration.corpus_errors(bad, bases)))

    bad2 = copy.deepcopy(hand)
    for c in bad2:
        if c["type"] != "control":
            c["readback"] = bases[c["block"]]
            break
    check("a mutation equal to its base is flagged",
          any("equals its base" in e for e in calibration.corpus_errors(bad2, bases)))

    bad3 = copy.deepcopy(hand)
    bad3.append(copy.deepcopy(bad3[0]))
    check("a duplicate id is flagged",
          any("duplicate id" in e for e in calibration.corpus_errors(bad3, bases)))

    thin = [c for c in hand if c["type"] in ("control", "direction_flip")]
    check("a mutation type below the minimum is flagged",
          any("minimum is" in e for e in calibration.corpus_errors(thin, bases)))

    check("is_detected: equivalent is not a detection",
          calibration.is_detected("equivalent") is False)
    check("is_detected: incomparable is a detection",
          calibration.is_detected("incomparable") is True)
    check("is_detected: formal_stronger is a detection",
          calibration.is_detected("formal_stronger") is True)

    per_type, controls, total = calibration.summarize(
        cases,
        {
            "CAL-002": "incomparable",   # direction_flip, detected
            "CAL-003": "equivalent",     # conclusion_reverse, missed
            "CAL-001": "incomparable",   # control false positive
        },
    )
    check("detection counted per type with its n",
          per_type["direction_flip"]["n"] == 1
          and per_type["direction_flip"]["detected"] == 1
          and per_type["conclusion_reverse"]["n"] == 1
          and per_type["conclusion_reverse"]["detected"] == 0,
          str(per_type))
    check("control false positive counted",
          controls["false_positive"] == 1, str(controls))
    check("overall mutations-only totals",
          total["n"] == 2 and total["detected"] == 1, str(total))
    check("unrun cases are counted, not treated as detected",
          total["unrun"] == len([c for c in cases if c["type"] != "control"]) - 2,
          str(total))

    # Wilson interval: a single-case 1.00 rate is visibly uninformative.
    lo1, hi1 = calibration.wilson(1, 1)
    check("single-case perfect rate has a wide, uninformative interval",
          lo1 < 0.5 and hi1 >= 0.99, f"[{lo1:.2f}, {hi1:.2f}]")
    lo2, hi2 = calibration.wilson(20, 20)
    check("larger sample tightens the interval toward 1", lo2 > lo1,
          f"[{lo2:.2f}, {hi2:.2f}]")

    run = calibration.runs_from({"model": "alpha-1", "producer_model": "alpha-1",
                                 "verdicts": {"CAL-002": "incomparable"}})
    check("verdicts document normalizes to one run", len(run) == 1, str(run))
    check("run carries a model pair",
          calibration.pair_key(run[0]) == ("alpha", "alpha"),
          str(calibration.pair_key(run[0])))

    with tempfile.TemporaryDirectory() as tmp:
        base_path = Path(tmp) / "baseline.json"
        runs = [{"producer_model": "deepseek-v4.1-flash",
                 "model": "deepseek-v4.1-flash",
                 "verdicts": {"CAL-002": "incomparable"}}]
        baseline = calibration.baseline_from(cases, runs)
        base_path.write_text(__import__("json").dumps(baseline), encoding="utf-8")
        import io
        import contextlib
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            ok = calibration.check_baseline(cases, runs, baseline)
        check("baseline check passes when detection holds", ok == 0, buf.getvalue())
        drop_runs = [{"producer_model": "deepseek-v4.1-flash",
                      "model": "deepseek-v4.1-flash",
                      "verdicts": {"CAL-002": "equivalent"}}]
        buf2 = io.StringIO()
        with contextlib.redirect_stdout(buf2):
            dropped = calibration.check_baseline(cases, drop_runs, baseline)
        check("baseline check fails on a detection drop", dropped == 1, buf2.getvalue())
        buf3 = io.StringIO()
        with contextlib.redirect_stdout(buf3):
            none = calibration.check_baseline(cases, runs, None)
        check("missing baseline is reported, not passed",
              none == 0 and "no baseline" in buf3.getvalue(), buf3.getvalue())

    text = calibration.render_report(cases, bases, run, "")
    check("report gives a case count alongside every rate",
          "cases run" in text and "95% interval" in text)
    check("report states when only one model pair was measured",
          "Only one model pair" in text)

    prompt = calibration.render_prompt(cases)
    check("prompt names every case",
          all(c["id"] in prompt for c in cases))
    check("prompt states the corpus size",
          f"Below are {len(cases)} pairs" in prompt)
    committed = (calibration.PROMPT.read_text(encoding="utf-8")
                 if calibration.PROMPT.exists() else None)
    check("committed comparator prompt matches the corpus (no drift)",
          prompt == committed)

    print()
    if FAILURES:
        print(f"calibration_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("calibration_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
