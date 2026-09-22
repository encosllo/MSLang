#!/usr/bin/env python3
"""Seeded mutation operators (Architecture.md Section 11.4).

Each operator takes an audited read-back and returns a mutated read-back in
which exactly one named thing is changed, or ``None`` when it does not apply to
that read-back. Operators are deterministic text transforms, so a corpus
generated from them is reproducible. The operator set is the named mutations the
architecture calls for: direction flip, reversed conclusion, swapped saturation
order, quantifier change, dropped hypothesis, weakened conclusion, and encoding
change.

``python3 scripts/mutations.py --generate`` writes ``calibration/generated.json``
from the base read-backs in ``calibration/seeded.json``.

Usage:
    python3 scripts/mutations.py --list
    python3 scripts/mutations.py --generate
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_SEED = ROOT / "calibration" / "seeded.json"
DEFAULT_OUT = ROOT / "calibration" / "generated.json"


def op_direction_flip(text):
    # Swap the phrase *and* its parenthetical gloss together, so the mutated
    # read-back stays internally consistent and the flip is a genuine one. A
    # bare phrase swap (no gloss) is the fallback.
    pairs = [
        ("Phi refines Psi (every pair related by Phi is related by Psi)",
         "Psi refines Phi (every pair related by Psi is related by Phi)"),
        ("Psi refines Phi (every pair related by Psi is related by Phi)",
         "Phi refines Psi (every pair related by Phi is related by Psi)"),
    ]
    for a, b in pairs:
        if a in text:
            return text.replace(a, b)
    for a, b in (("Phi refines Psi", "Psi refines Phi"), ("Psi refines Phi", "Phi refines Psi")):
        if a in text:
            return text.replace(a, b)
    return None


def op_conclusion_reverse(text):
    for a, b in (("is also Phi-saturated", "is also Psi-saturated"),
                 ("is also Psi-saturated", "is also Phi-saturated")):
        if a in text:
            return text.replace(a, b)
    return None


def op_saturation_order(text):
    # Swap the saturation order *throughout* the conclusion clause, so
    # ``[[X]^Psi]^Phi = [X]^Psi`` becomes ``[[X]^Phi]^Psi = [X]^Phi``.  The
    # trailing ``alone`` term must move with the order: swapping only the order
    # phrase yields ``[[X]^Phi]^Psi = [X]^Psi``, which is *equivalent* to the
    # contract (both hold iff Phi is contained in Psi), i.e. a non-mutation --
    # the generated case CAL-G010 read ``equivalent`` under the cross-model pass
    # and exposed exactly that.  Swapping Phi/Psi through the whole clause is
    # the genuine mismatch, matching the hand-authored CAL-005.
    for a, b in (("by Psi and then by Phi equals saturating X by Psi alone",
                  "by Phi and then by Psi equals saturating X by Phi alone"),
                 ("by Phi and then by Psi equals saturating X by Phi alone",
                  "by Psi and then by Phi equals saturating X by Psi alone")):
        if a in text:
            return text.replace(a, b)
    return None


def op_quantifier_change(text):
    for a, b in (("for every componentwise subset X", "there exists a componentwise subset X"),
                 ("for every sort s", "there exists a sort s")):
        if a in text:
            return text.replace(a, b)
    return None


def op_weakened_conclusion(text):
    for a, b in (("equals all of A_s", "is nonempty"), ("X_s = A_s", "X_s is nonempty")):
        if a in text:
            return text.replace(a, b)
    return None


def op_dropped_hypothesis(text):
    dropped = "Suppose Phi refines Psi (every pair related by Phi is related by Psi). "
    if dropped in text:
        return text.replace(dropped, "")
    both = "saturated under both Phi and Psi"
    if both in text:
        return text.replace(both, "saturated under Phi")
    return None


def op_encoding(text):
    # A genuine encoding mismatch: the representation models sorted
    # equivalences as Setoids (residual D4); a read-back that says "relations"
    # has dropped reflexivity/symmetry/transitivity. Earlier this operator only
    # changed "componentwise subset" to "subset", which is *not* a mismatch in
    # this setting (subsets of an S-sorted set are componentwise), and a blind
    # run rightly judged it equivalent.
    if "S-sorted equivalences" in text:
        return text.replace("S-sorted equivalences", "S-sorted relations", 1)
    return None


OPERATORS = {
    "direction_flip": op_direction_flip,
    "conclusion_reverse": op_conclusion_reverse,
    "saturation_order": op_saturation_order,
    "quantifier_change": op_quantifier_change,
    "dropped_hypothesis": op_dropped_hypothesis,
    "weakened_conclusion": op_weakened_conclusion,
    "encoding": op_encoding,
}


def generate(seed, start=1):
    """Return generated mutation cases from the seed's base read-backs."""
    bases = seed["base_readbacks"]
    contracts = {}
    for case in seed["cases"]:
        contracts.setdefault(case["block"], case["contract"])
    cases = []
    n = start
    for block in sorted(bases):
        base = bases[block]
        contract = contracts.get(block, "")
        for name in sorted(OPERATORS):
            mutated = OPERATORS[name](base)
            if not mutated or mutated == base:
                continue
            cases.append({
                "id": f"CAL-G{n:03d}",
                "block": block,
                "type": name,
                "expect": "detected",
                "operator": name,
                "source": "generated",
                "contract": contract,
                "readback": mutated,
            })
            n += 1
    return cases


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("--seed", default=str(DEFAULT_SEED))
    ap.add_argument("--out", default=str(DEFAULT_OUT))
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--generate", action="store_true")
    args = ap.parse_args(argv)

    if args.list:
        for name in sorted(OPERATORS):
            print(name)
        return 0

    seed = json.loads(Path(args.seed).read_text(encoding="utf-8"))
    cases = generate(seed)
    if args.generate:
        doc = {
            "note": "Generated seeded mutations (Architecture.md Section 11.4). "
                    "Produced deterministically by scripts/mutations.py from the base "
                    "read-backs in calibration/seeded.json. These carry no verdicts "
                    "until an audit run supplies them; the report counts them as unrun.",
            "cases": cases,
        }
        Path(args.out).write_text(json.dumps(doc, indent=2, sort_keys=True) + "\n",
                                  encoding="utf-8")
        print(f"mutations: wrote {Path(args.out).relative_to(ROOT)} ({len(cases)} cases)")
        return 0

    from collections import Counter
    counts = Counter(c["type"] for c in cases)
    for name in sorted(counts):
        print(f"{name:22s} {counts[name]}")
    print(f"mutations: {len(cases)} generated case(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
