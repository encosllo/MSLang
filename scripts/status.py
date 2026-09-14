#!/usr/bin/env python3
"""Evidence validity and layer status (Architecture.md Sections 7.2, 8).

An evidence record is *current* iff every input hash equals the artifact's
current hash; otherwise it is *stale*.  Stale evidence is not false -- it
remains a true statement about the recorded inputs -- it is simply no longer
evidence about the current block.  This module implements that rule and derives
each layer's status from the records:

    none | in_progress | pass | fail | stale | blocked

It never authors evidence.  It only reads records that some audit produced and
compares their recorded inputs against current facet hashes.

Facet resolution mirrors ``scripts/closure.py``:
    B-D014/informal_statement  -> registry facet hash
    representation/<name>      -> hash of the representation file (--representation)

Usage:
    python3 scripts/status.py --representation representation/pilot-encoding.md
    python3 scripts/status.py --block B-P002 --representation FILE
    python3 scripts/status.py --evidence-dir evidence --json
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import closure  # noqa: E402

POSITIVE = {
    "equivalent",
    "formal_stronger",
    "faithful",
    "faithful-with-caveat",
    "pass",
    "build_ok",
}
NEGATIVE = {
    "formal_weaker",
    "incomparable",
    "ill_posed",
    "unfaithful",
    "fail",
    "build_failed",
}


def load_registry(path):
    return closure.load_registry(Path(path))


def load_evidence(directory):
    records = []
    for path in sorted(Path(directory).glob("*.json")):
        try:
            records.append(json.loads(path.read_text(encoding="utf-8")))
        except Exception:
            continue
    return records


def facet_hash(registry, artifact):
    parts = artifact.split("/", 1)
    if len(parts) != 2:
        return None
    block, facet = parts
    entry = registry.get(block, {}).get("facets", {}).get(facet)
    return entry.get("hash") if entry else None


def resolve(artifact, registry, representation_hashes):
    block, _, facet = artifact.partition("/")
    if block == "representation":
        return representation_hashes.get(facet)
    return facet_hash(registry, artifact)


def record_is_current(record, registry, representation_hashes):
    """True iff every listed input hash still matches, with no unresolved input."""
    for inp in record.get("inputs", []):
        current = resolve(inp["artifact"], registry, representation_hashes)
        if current is None:
            return False  # fail closed: cannot verify => not current
        if current != inp["hash"]:
            return False
    return True


def layer_status(records, registry, representation_hashes):
    """Derive a single layer status from its records. Returns (status, detail)."""
    if not records:
        return "none", {"current": 0, "stale": 0, "negative": 0}
    current = [r for r in records if record_is_current(r, registry, representation_hashes)]
    stale = [r for r in records if r not in current]
    detail = {
        "current": len(current),
        "stale": len(stale),
        "negative": sum(1 for r in current if r.get("outcome") in NEGATIVE),
    }
    if current:
        if any(r.get("outcome") in NEGATIVE for r in current):
            return "fail", detail
        if any(r.get("outcome") in POSITIVE for r in current):
            return "pass", detail
        return "in_progress", detail
    return "stale", detail


def block_status(records_by_layer, registry, representation_hashes):
    out = {}
    for layer, records in records_by_layer.items():
        status, detail = layer_status(records, registry, representation_hashes)
        out[layer] = {"status": status, **detail}
    return out


def group_by_block_layer(records):
    grouped = {}
    for r in records:
        grouped.setdefault(r["block"], {}).setdefault(r["layer"], []).append(r)
    return grouped


def hash_file(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("--evidence-dir", default="evidence")
    ap.add_argument("--registry", default="blocks/registry.json")
    ap.add_argument("--representation")
    ap.add_argument("--representation-name", default="encoding")
    ap.add_argument("--block")
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args(argv)

    registry = load_registry(args.registry)
    rep = {}
    if args.representation:
        rep[args.representation_name] = hash_file(args.representation)
    records = load_evidence(args.evidence_dir)
    grouped = group_by_block_layer(records)
    if args.block:
        grouped = {args.block: grouped.get(args.block, {})}

    report = {}
    for block, layers in sorted(grouped.items()):
        report[block] = block_status(layers, registry, rep)

    # Blocks with no records at all.
    if not args.block:
        missing = [b for b in registry if b not in report]
    else:
        missing = []

    if args.json:
        print(json.dumps({"blocks": report, "no_records": missing}, indent=2, sort_keys=True))
        return 0

    print(f"status: {len(records)} evidence record(s), {len(report)} block(s) with evidence")
    for block, layers in report.items():
        for layer, st in layers.items():
            print(
                f"  {block:10s} {layer:14s} {st['status']:12s} "
                f"(current={st['current']} stale={st['stale']} negative={st['negative']})"
            )
    if missing:
        print(f"status: {len(missing)} block(s) have no evidence at all")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
