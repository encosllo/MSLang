#!/usr/bin/env python3
"""Trust boundary: representation residuals propagated to covered blocks.

Architecture.md Sections 6, 7.5, 11.5.  A representation audited
``faithful-with-caveat`` imposes its residual caveats on every block it covers,
and the architecture requires those residuals to be visible in the block's
trust boundary (Section 11.5: "the caveat is propagated into every dependent
block's trust boundary, so the compromise is visible where a reader will see it
rather than buried in a source comment").

This module derives that boundary mechanically from the representation-layer
evidence records and a declared coverage map.  It never authors evidence; it
only reads records and resolves hashes, mirroring ``scripts/status.py``.

Residual convention.  The encoding auditor's verdict finding must enumerate the
retained residuals, e.g. ``Verdict: faithful-with-caveat with residuals D1, D2,
D4.``  The residual set is parsed from that verdict, not from the bounded
findings (D3/D5/D6/D7 are declared non-residual and must not leak in).

Usage:
    python3 scripts/trust.py --representation representation/pilot-encoding.md
    python3 scripts/trust.py --json
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import status  # noqa: E402

RESIDUAL_WORD_RE = re.compile(r"residual", re.IGNORECASE)
RESIDUAL_LIST_RE = re.compile(r"residuals?\s*:?\s*([^.]+)", re.IGNORECASE)
SPLIT_RE = re.compile(r"\s*(?:,|\band\b)\s*")
LABEL_RE = re.compile(r"[A-Za-z0-9][A-Za-z0-9_-]*")
OUTCOMES_WITH_RESIDUALS = {"faithful-with-caveat"}


def load_coverage(path: Path):
    """Load the declared representation -> covered-blocks map."""
    return json.loads(Path(path).read_text(encoding="utf-8"))


def hash_file(path: Path) -> str:
    return status.hash_file(path)


def _labels(text):
    """Residual tags following ``residual(s)``, accepting D1, R-carrier, ..."""
    m = RESIDUAL_LIST_RE.search(text)
    if not m:
        return []
    out = []
    for tok in SPLIT_RE.split(m.group(1)):
        tok = tok.strip().strip(".").strip()
        if tok and LABEL_RE.fullmatch(tok):
            out.append(tok)
    return out


def residuals_from_record(record):
    """Extract the residual labels from an encoding-audit record.

    Prefers the authoritative ``Verdict: ... residuals D1, D2, ...`` finding;
    falls back to the union of every finding that mentions "residual".
    """
    findings = record.get("findings", [])
    verdicts = [
        f for f in findings
        if RESIDUAL_WORD_RE.search(f) and f.strip().lower().startswith("verdict")
    ]
    if verdicts:
        return sorted(set(_labels(verdicts[-1])))
    labels = set()
    for f in findings:
        if RESIDUAL_WORD_RE.search(f):
            labels.update(_labels(f))
    return sorted(labels)


def representation_boundary(name, records, representation_hashes):
    """Derive one representation's audit outcome, currency, and residual set."""
    reps = [r for r in records if r.get("block") == f"representation/{name}"]
    reps.sort(key=lambda r: r.get("evidence_id", ""))
    base = {
        "name": name,
        "audited": False,
        "record": None,
        "outcome": None,
        "current": False,
        "residuals": [],
    }
    if not reps:
        return base
    current = [
        r for r in reps
        if status.record_is_current(r, {}, representation_hashes)
    ]
    chosen = current[-1] if current else reps[-1]
    outcome = chosen.get("outcome")
    residuals = (
        residuals_from_record(chosen)
        if outcome in OUTCOMES_WITH_RESIDUALS
        else []
    )
    return {
        "name": name,
        "audited": True,
        "record": chosen.get("evidence_id"),
        "outcome": outcome,
        "current": bool(current),
        "residuals": residuals,
    }


def compute(registry, coverage, records, representation_hashes):
    """Return (representations, boundary).

    ``representations`` maps representation name -> its derived audit summary.
    ``boundary`` maps block id -> list of representation entries imposing a
    residual (or a stale/unfaithful audit) on that block.
    """
    representations = {}
    boundary = {bid: [] for bid in registry}
    for name, entry in sorted(coverage.items()):
        rb = representation_boundary(name, records, representation_hashes)
        representations[name] = {**rb, "file": entry.get("file"),
                                 "covers": list(entry.get("blocks", [])),
                                 "bridge_obligations": list(
                                     entry.get("bridge_obligations", []))}
        for bid in entry.get("blocks", []):
            boundary.setdefault(bid, [])
            if rb["audited"]:
                boundary[bid].append(rb)
    return representations, boundary


def block_residuals(boundary_entry):
    """The residual labels visible in a block's trust boundary."""
    labels = set()
    for rb in boundary_entry:
        if rb["current"] and rb["outcome"] in OUTCOMES_WITH_RESIDUALS:
            labels.update(rb["residuals"])
    return sorted(labels)


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("--registry", default="blocks/registry.json")
    ap.add_argument("--evidence-dir", default="evidence")
    ap.add_argument("--coverage", default="representation/coverage.json")
    ap.add_argument("--representation")
    ap.add_argument("--representation-name", default="encoding")
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args(argv)

    registry = status.load_registry(args.registry)
    coverage = load_coverage(Path(args.coverage))
    records = status.load_evidence(args.evidence_dir)
    rep = {}
    if args.representation:
        rep[args.representation_name] = hash_file(Path(args.representation))

    representations, boundary = compute(registry, coverage, records, rep)
    out = {
        "representations": representations,
        "boundary": {
            bid: {
                "representations": [rb["name"] for rb in rbs],
                "residuals": block_residuals(rbs),
            }
            for bid, rbs in boundary.items()
        },
    }
    if args.json:
        print(json.dumps(out, indent=2, sort_keys=True))
        return 0
    for name, rb in representations.items():
        state = "current" if rb["current"] else "stale/unaudited"
        print(
            f"{name}: {rb['outcome']} ({state}, {rb['record']}), "
            f"residuals={rb['residuals']}, covers={len(rb['covers'])} block(s)"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
