#!/usr/bin/env python3
"""Notation resolutions (Architecture.md Sections 12.1, 16.4).

A compound notation identity (a ``\\mathrm{...}`` base plus its subscript chain,
or a bare macro) is owned by the definition that introduces it.  When the
mechanical introducer heuristic cannot resolve an identity to a single block --
because two definitions introduce the same glyph, or the notation is ambient --
the resolution is an author decision recorded here.

The store is author-reserved: this tool refuses to set a resolution whose
``decided_by`` does not begin with ``author:``.  ``resolution`` is ``block``
(with a ``target`` defining block, emitting symbol-usage edges) or ``ambient``
(no dependency edge).  An identity absent here that is not mechanically unique
is reported as unresolved by ``scripts/ingest.py``.

Usage:
    python3 scripts/notation.py --list
    python3 scripts/notation.py --check
    python3 scripts/notation.py set --notation supp --resolution block \
        --target B-D009 --decided-by author:session82 --rationale "..."
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_STORE = ROOT / "blocks" / "notation.json"
RESOLUTION_VALUES = {"block", "ambient"}
BLOCK_RE = re.compile(r"^B-[A-Za-z0-9]+$")


def load(path):
    p = Path(path)
    if not p.exists():
        return {}
    doc = json.loads(p.read_text(encoding="utf-8"))
    return doc.get("resolutions", doc) if isinstance(doc, dict) else doc


def save(path, resolutions):
    doc = json.loads(Path(path).read_text(encoding="utf-8"))
    doc["resolutions"] = resolutions
    Path(path).write_text(json.dumps(doc, indent=2, sort_keys=True) + "\n",
                          encoding="utf-8")


def validate(resolutions):
    errors = []
    for identity, entry in sorted(resolutions.items()):
        if not isinstance(entry, dict):
            errors.append(f"{identity}: resolution entry must be an object")
            continue
        value = entry.get("resolution")
        if value not in RESOLUTION_VALUES:
            errors.append(f"{identity}: invalid resolution {value!r}")
            continue
        if value == "block" and not BLOCK_RE.match(entry.get("target") or ""):
            errors.append(f"{identity}: block resolution needs a B- target")
        if value == "ambient" and entry.get("target"):
            errors.append(f"{identity}: ambient resolution must not name a target")
        if not check_author(entry.get("decided_by")):
            errors.append(
                f"{identity}: decided_by must begin with 'author:' "
                f"(got {entry.get('decided_by')!r})"
            )
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
    p.add_argument("--notation", required=True)
    p.add_argument("--resolution", required=True, choices=sorted(RESOLUTION_VALUES))
    p.add_argument("--target", default="")
    p.add_argument("--decided-by", required=True)
    p.add_argument("--rationale", default="")
    args = ap.parse_args(argv)

    resolutions = load(args.store)

    if args.check:
        errors = validate(resolutions)
        for e in errors:
            print(f"ERROR {e}")
        if errors:
            return 1
        print(f"notation: {len(resolutions)} resolution(s) valid")
        return 0

    if args.list:
        for identity, entry in sorted(resolutions.items()):
            target = entry.get("target") or ""
            value = entry.get("resolution") if isinstance(entry, dict) else entry
            print(f"{identity:16s} {value:8s} {target}")
        return 0

    if args.cmd == "set":
        if not check_author(args.decided_by):
            print(
                "notation: refusing to set a resolution without an author "
                "decision (--decided-by author:...)",
                file=sys.stderr,
            )
            return 1
        if args.resolution == "block" and not BLOCK_RE.match(args.target):
            print("notation: a block resolution needs --target B-...", file=sys.stderr)
            return 1
        if args.resolution == "ambient" and args.target:
            print("notation: an ambient resolution takes no --target", file=sys.stderr)
            return 1
        resolutions[args.notation] = {
            "resolution": args.resolution,
            "target": args.target or None,
            "rationale": args.rationale,
            "decided_by": args.decided_by,
        }
        save(args.store, resolutions)
        print(f"notation: set {args.notation} = {args.resolution} {args.target}".rstrip())
        return 0

    ap.print_help()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
