#!/usr/bin/env python3
"""Treatment tiers (Architecture.md Sections 8.3, 9).

A block's *treatment tier* governs scrutiny, not truth: ``light`` requires a
current verification and an R1 self-check, ``cabinet`` requires independent
checks. The tier also decides whether a `same_model` layer reports
`provisional`: an explicitly ``light`` block is exempt, and an unclassified
block is not.

Setting a tier is author-reserved (a block enters the cabinet by author
designation, and leaves only by author decision), so this tool refuses a write
whose ``--decided-by`` does not begin with ``author:``.

Usage:
    python3 scripts/tiers.py --list
    python3 scripts/tiers.py --check
    python3 scripts/tiers.py set --block B-C001 --tier cabinet \
        --decided-by author:session81 --rationale "headline result"
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_STORE = ROOT / "blocks" / "treatment_tiers.json"
TIER_VALUES = {"light", "cabinet"}


def load(path):
    p = Path(path)
    if not p.exists():
        return {}
    doc = json.loads(p.read_text(encoding="utf-8"))
    return doc.get("tiers", doc) if isinstance(doc, dict) else doc


def save(path, tiers):
    doc = json.loads(Path(path).read_text(encoding="utf-8"))
    doc["tiers"] = tiers
    Path(path).write_text(json.dumps(doc, indent=2, sort_keys=True) + "\n",
                          encoding="utf-8")


def validate(tiers):
    errors = []
    for block, entry in sorted(tiers.items()):
        value = entry.get("tier") if isinstance(entry, dict) else entry
        if value not in TIER_VALUES:
            errors.append(f"{block}: invalid tier {value!r}")
    return errors


def tier_of(tiers, block):
    entry = tiers.get(block)
    value = entry.get("tier") if isinstance(entry, dict) else entry
    return value if value in TIER_VALUES else None


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("--store", default=str(DEFAULT_STORE))
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--check", action="store_true")
    sub = ap.add_subparsers(dest="cmd")
    p = sub.add_parser("set")
    p.add_argument("--block", required=True)
    p.add_argument("--tier", required=True, choices=sorted(TIER_VALUES))
    p.add_argument("--decided-by", required=True)
    p.add_argument("--rationale", default="")
    args = ap.parse_args(argv)

    tiers = load(args.store)

    if args.check:
        errors = validate(tiers)
        for e in errors:
            print(f"ERROR {e}")
        if errors:
            return 1
        print(f"tiers: {len(tiers)} designation(s) valid")
        return 0

    if args.list:
        for block, entry in sorted(tiers.items()):
            print(f"{block:10s} {tier_of(tiers, block)}")
        return 0

    if args.cmd == "set":
        if not (args.decided_by and args.decided_by.startswith("author:")):
            print(
                "tiers: refusing to set a treatment tier without an author "
                "decision (--decided-by author:...)",
                file=sys.stderr,
            )
            return 1
        tiers[args.block] = {
            "tier": args.tier,
            "rationale": args.rationale,
            "decided_by": args.decided_by,
        }
        save(args.store, tiers)
        print(f"tiers: set {args.block} = {args.tier}")
        return 0

    ap.print_help()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
