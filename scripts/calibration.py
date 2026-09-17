#!/usr/bin/env python3
"""Seeded-mismatch calibration (Architecture.md Section 11.4).

Audit reliability is measured, not assumed.  The corpus pairs each audited
contract with a read-back that is either the control (the audited read-back) or a
mutation of it (one named change: direction flip, reversed conclusion, swapped
saturation order, quantifier change, dropped hypothesis, weakened conclusion,
encoding change).  The comparator (Section 11.2 stage 2) is run blind on every
case; a mutation is *detected* when the returned outcome is not ``equivalent``.

Cases come from two places: the hand-authored ``calibration/seeded.json`` and the
deterministically generated ``calibration/generated.json`` (see
``scripts/mutations.py``).  Generated cases carry no verdicts until an audit run
supplies them, and are reported as *unrun*, never as detections.

Detection is reported per mutation type with its case count and an interval
(a rate is never shown without its ``n``), and per model pair, so "a different
model catches more" is a measured claim.  ``--check-baseline`` gates a drop.

Usage:
    python3 scripts/calibration.py --self-test
    python3 scripts/calibration.py --list
    python3 scripts/calibration.py --verdicts calibration/verdicts.json
    python3 scripts/calibration.py --verdicts calibration/verdicts.json --report
    python3 scripts/calibration.py --record-baseline
    python3 scripts/calibration.py --check-baseline
"""
from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import status  # noqa: E402

ROOT = HERE.parent
DEFAULT_SEED = ROOT / "calibration" / "seeded.json"
DEFAULT_GENERATED = ROOT / "calibration" / "generated.json"
DEFAULT_VERDICTS = ROOT / "calibration" / "verdicts.json"
DEFAULT_BASELINE = ROOT / "calibration" / "baseline.json"
REPORT = ROOT / "reports" / "calibration.md"
REQUIRED = {"id", "block", "type", "expect", "contract", "readback"}
MIN_MUTATION_CASES = 2
Z = 1.959963984540054  # 95%


def load_json(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def load_cases(seed, generated_path=DEFAULT_GENERATED):
    cases = list(seed.get("cases", []))
    gp = Path(generated_path)
    if gp.exists():
        cases += load_json(gp).get("cases", [])
    return cases


def corpus_errors(cases, bases):
    errors = []
    seen = set()
    per_type = {}
    for c in cases:
        cid = c.get("id", "?")
        missing = REQUIRED - set(c)
        if missing:
            errors.append(f"{cid}: missing fields {sorted(missing)}")
            continue
        if cid in seen:
            errors.append(f"{cid}: duplicate id")
        seen.add(cid)
        block = c["block"]
        if block not in bases:
            errors.append(f"{cid}: no base_readback for {block}")
            continue
        if c["type"] == "control":
            if c["expect"] != "equivalent":
                errors.append(f"{cid}: control must expect 'equivalent'")
            if c["readback"].strip() != bases[block].strip():
                errors.append(f"{cid}: control read-back differs from its base")
        else:
            if c["expect"] == "equivalent":
                errors.append(f"{cid}: a mutation must not expect 'equivalent'")
            if c["readback"].strip() == bases[block].strip():
                errors.append(f"{cid}: mutation read-back equals its base")
            per_type[c["type"]] = per_type.get(c["type"], 0) + 1
    for t in sorted(per_type):
        if per_type[t] < MIN_MUTATION_CASES:
            errors.append(
                f"mutation type {t!r} has {per_type[t]} case(s), "
                f"minimum is {MIN_MUTATION_CASES}"
            )
    return errors


def is_detected(outcome):
    return outcome.strip().lower() != "equivalent"


def wilson(detected, n, z=Z):
    """Wilson score interval for a binomial proportion (dependency-free)."""
    if n == 0:
        return (0.0, 1.0)
    p = detected / n
    denom = 1 + z * z / n
    centre = (p + z * z / (2 * n)) / denom
    half = (z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n))) / denom
    return (max(0.0, centre - half), min(1.0, centre + half))


def summarize(cases, verdicts):
    """Return (per_type, controls, total). per_type: {type: {n, detected, unrun}}."""
    per_type = {}
    controls = {"n": 0, "false_positive": 0}
    total = {"n": 0, "detected": 0, "unrun": 0}
    for c in cases:
        outcome = verdicts.get(c["id"])
        if c["type"] == "control":
            if outcome is None:
                controls["n"] += 1
                continue
            controls["n"] += 1
            if is_detected(outcome):
                controls["false_positive"] += 1
            continue
        slot = per_type.setdefault(c["type"], {"n": 0, "detected": 0, "unrun": 0})
        if outcome is None:
            slot["unrun"] += 1
            total["unrun"] += 1
            continue
        slot["n"] += 1
        slot["detected"] += 1 if is_detected(outcome) else 0
        total["n"] += 1
        total["detected"] += 1 if is_detected(outcome) else 0
    return per_type, controls, total


def runs_from(verdicts_doc):
    """Normalize a verdicts document into a list of model-pair runs."""
    if "runs" in verdicts_doc and isinstance(verdicts_doc["runs"], list):
        runs = []
        for r in verdicts_doc["runs"]:
            runs.append({
                "producer_model": r.get("producer_model", r.get("model", "unknown")),
                "model": r.get("model", "unknown"),
                "verdicts": r.get("verdicts", {}),
            })
        return runs
    model = verdicts_doc.get("model", "unknown")
    return [{
        "producer_model": verdicts_doc.get("producer_model", model),
        "model": model,
        "verdicts": verdicts_doc.get("verdicts", verdicts_doc),
    }]


def pair_key(run):
    return (status.family_of(run["producer_model"]) or "unknown",
            status.family_of(run["model"]) or "unknown")


def render_report(cases, bases, runs, audit_note):
    lines = [
        "# Calibration report (Section 11.4)",
        "",
        "Generated by `scripts/calibration.py` from `calibration/seeded.json`,",
        "`calibration/generated.json`, and `calibration/verdicts.json`. A mutation",
        "is *detected* when the blind comparator returns an outcome other than",
        "`equivalent`. Controls are the audited read-backs; a control judged",
        "non-equivalent is a false positive. Generated cases with no verdict are",
        "*unrun*, never detections.",
        "",
        f"Corpus: {len(cases)} case(s) over {len(bases)} base block(s).",
        "",
        audit_note.rstrip(),
        "",
    ]
    if len(runs) == 1:
        lines += ["Only one model pair was measured (same-model run); no second "
                  "model is currently available.", ""]
    for run in runs:
        pf, cf = pair_key(run)
        per_type, controls, total = summarize(cases, run["verdicts"])
        lines += [
            f"## Model pair: {pf} (producer) -> {cf} (comparator)",
            "",
            "| mutation type | cases run | detected | rate | 95% interval | unrun |",
            "|---|---|---|---|---|---|",
        ]
        for t in sorted(per_type):
            s = per_type[t]
            if s["n"] == 0:
                rate, interval = "n/a", "n/a"
            else:
                rate = f"{s['detected'] / s['n']:.2f}"
                lo, hi = wilson(s["detected"], s["n"])
                interval = f"[{lo:.2f}, {hi:.2f}]"
            lines.append(
                f"| {t} | {s['n']} | {s['detected']} | {rate} | {interval} | {s['unrun']} |"
            )
        lines += [
            "",
            f"Controls run: {controls['n']}; false positives: {controls['false_positive']}.",
            "",
            f"Mutations run: {total['n']}; detected: {total['detected']}; unrun: {total['unrun']}.",
            "",
        ]
    return "\n".join(lines)


def baseline_from(cases, runs):
    run = runs[0]
    per_type, _, _ = summarize(cases, run["verdicts"])
    pf, cf = pair_key(run)
    return {
        "pair": {"producer": pf, "comparator": cf},
        "rates": {
            t: (s["detected"] / s["n"]) for t, s in per_type.items() if s["n"] > 0
        },
    }


def check_baseline(cases, runs, baseline):
    if not baseline:
        print("calibration: no baseline recorded -- not a pass")
        return 0
    run = runs[0]
    per_type, _, _ = summarize(cases, run["verdicts"])
    drops = []
    for t, base_rate in sorted(baseline.get("rates", {}).items()):
        s = per_type.get(t)
        if not s or s["n"] == 0:
            drops.append(f"{t}: no cases run (baseline {base_rate:.2f})")
            continue
        rate = s["detected"] / s["n"]
        if rate < base_rate - 1e-9:
            drops.append(f"{t}: {rate:.2f} < baseline {base_rate:.2f}")
    pf, cf = pair_key(run)
    print(f"calibration: baseline {baseline.get('pair', {})}; run {pf} -> {cf}")
    for d in drops:
        print(f"FAIL {d}")
    if drops:
        print("calibration: detection dropped below baseline")
        return 1
    print("calibration: detection at or above baseline")
    return 0


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("--seed", default=str(DEFAULT_SEED))
    ap.add_argument("--generated", default=str(DEFAULT_GENERATED))
    ap.add_argument("--verdicts", default=str(DEFAULT_VERDICTS))
    ap.add_argument("--baseline", default=str(DEFAULT_BASELINE))
    ap.add_argument("--self-test", action="store_true")
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--report", action="store_true")
    ap.add_argument("--check-report", action="store_true")
    ap.add_argument("--record-baseline", action="store_true")
    ap.add_argument("--check-baseline", action="store_true")
    args = ap.parse_args(argv)

    seed = load_json(args.seed)
    bases = seed.get("base_readbacks", {})
    cases = load_cases(seed, args.generated)

    if args.self_test:
        errors = corpus_errors(cases, bases)
        for e in errors:
            print(f"FAIL {e}")
        if errors:
            return 1
        from collections import Counter
        counts = Counter(c["type"] for c in cases if c["type"] != "control")
        detail = ", ".join(f"{t}={counts[t]}" for t in sorted(counts))
        print(f"calibration: corpus OK ({len(cases)} cases; {detail})")
        return 0

    if args.list:
        for c in cases:
            print(f"{c['id']}  {c['block']:8s} {c['type']}")
        return 0

    verdicts_doc = {}
    vpath = Path(args.verdicts)
    if vpath.exists():
        verdicts_doc = load_json(vpath)
    runs = runs_from(verdicts_doc)

    if args.check_baseline:
        baseline = load_json(args.baseline) if Path(args.baseline).exists() else None
        return check_baseline(cases, runs, baseline)

    if args.record_baseline:
        baseline = baseline_from(cases, runs)
        Path(args.baseline).write_text(
            json.dumps({"note": "Detection baseline (Section 11.4); a later run "
                                "below these rates blocks the change.",
                        **baseline}, indent=2, sort_keys=True) + "\n",
            encoding="utf-8")
        print(f"calibration: wrote {Path(args.baseline).relative_to(ROOT)}")
        return 0

    per_type, controls, total = summarize(cases, runs[0]["verdicts"])
    print(
        f"calibration: {total['n']} mutation(s) run, {total['detected']} detected, "
        f"{total['unrun']} unrun; {controls['n']} control(s), "
        f"{controls['false_positive']} false positive(s)"
    )
    for t in sorted(per_type):
        s = per_type[t]
        rate = "n/a" if s["n"] == 0 else f"{s['detected'] / s['n']:.2f}"
        print(f"  {t:22s} {s['detected']}/{s['n']} (rate {rate}, unrun {s['unrun']})")

    note = seed.get("audit_note", "")
    text = render_report(cases, bases, runs, note)
    if args.report:
        REPORT.parent.mkdir(parents=True, exist_ok=True)
        REPORT.write_text(text, encoding="utf-8")
        print(f"calibration: wrote {REPORT.relative_to(ROOT)}")
    if args.check_report:
        actual = REPORT.read_text(encoding="utf-8") if REPORT.exists() else None
        if actual != text:
            print("calibration: report drift in reports/calibration.md")
            return 1
        print("calibration: report current")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
