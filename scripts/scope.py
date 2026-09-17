#!/usr/bin/env python3
"""Scope dispositions for unmapped blocks (Architecture.md Sections 16.4, 17).

A confirmed block with no Lean counterpart is *undecided* until the author
records a scope disposition (``worth-formalizing``, ``deferred``,
``out-of-scope``). The store is author-reserved: this tool refuses to set a
disposition whose ``decided_by`` does not begin with ``author:``.

Usage:
    python3 scripts/scope.py --list
    python3 scripts/scope.py --check
    python3 scripts/scope.py set --block B-X001 --disposition deferred \
        --decided-by author:session81 --rationale "..."
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_STORE = ROOT / "blocks" / "scope_decisions.json"
SCOPE_VALUES = {"worth-formalizing", "deferred", "out-of-scope"}


def load(path):
    p = Path(path)
    if not p.exists():
        return {}
    doc = json.loads(p.read_text(encoding="utf-8"))
    return doc.get("dispositions", doc) if isinstance(doc, dict) else doc


def save(path, dispositions):
    doc = json.loads(Path(path).read_text(encoding="utf-8"))
    doc["dispositions"] = dispositions
    Path(path).write_text(json.dumps(doc, indent=2, sort_keys=True) + "\n",
                          encoding="utf-8")


def validate(dispositions):
    errors = []
    for block, entry in sorted(dispositions.items()):
        value = entry.get("disposition") if isinstance(entry, dict) else entry
        if value not in SCOPE_VALUES:
            errors.append(f"{block}: invalid scope disposition {value!r}")
    return errors


def check_author(name):
    return bool(name) and name.startswith("author:")


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("--store", default=str(DEFAULT_STORE))
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--check", action="store_true")
    sub = ap.add_subparsers(dest="cmd")
    p = sub.add_parser("set")
    p.add_argument("--block", required=True)
    p.add_argument("--disposition", required=True, choices=sorted(SCOPE_VALUES))
    p.add_argument("--decided-by", required=True)
    p.add_argument("--rationale", default="")
    args = ap.parse_args(argv)

    dispositions = load(args.store)

    if args.check:
        errors = validate(dispositions)
        for e in errors:
            print(f"ERROR {e}")
        if errors:
            return 1
        print(f"scope: {len(dispositions)} disposition(s) valid")
        return 0

    if args.list:
        for block, entry in sorted(dispositions.items()):
            value = entry.get("disposition") if isinstance(entry, dict) else entry
            print(f"{block:10s} {value}")
        return 0

    if args.cmd == "set":
        if not check_author(args.decided_by):
            print(
                "scope: refusing to set a scope disposition without an author "
                "decision (--decided-by author:...)",
                file=sys.stderr,
            )
            return 1
        dispositions[args.block] = {
            "disposition": args.disposition,
            "rationale": args.rationale,
            "decided_by": args.decided_by,
        }
        save(args.store, dispositions)
        print(f"scope: set {args.block} = {args.disposition}")
        return 0

    ap.print_help()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
