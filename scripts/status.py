#!/usr/bin/env python3
"""Evidence validity and layer status (Architecture.md Sections 7.2, 8).

An evidence record is *current* iff every input hash equals the artifact's
current hash; otherwise it is *stale*.  Stale evidence is not false -- it
remains a true statement about the recorded inputs -- it is simply no longer
evidence about the current block.  This module implements that rule and derives
each layer's status from the records:

    none | in_progress | pass | fail | stale | blocked | provisional

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

INDEPENDENCE_CLASSES = {"cross_model", "same_model", "human", "build"}
INDEPENDENT_CLASSES = {"cross_model", "human", "build"}
TIER_STORE = "blocks/treatment_tiers.json"


def family_of(model):
    """Model family of a model identifier (Architecture.md Section 9).

    Uses the first hyphen-separated segment deterministically: the registry
    (``calibration/models.json``) may declare families explicitly, but this
    fallback keeps classification well-defined for legacy records that predate
    the registry. An empty model has no family (fail closed: not independent).
    """
    if not model:
        return ""
    return model.split("-")[0].strip()


def derive_independence(record):
    """Classify a record from its producer and protocol (Section 9).

    Legacy records (no ``independence`` object) classify as ``same_model`` when
    agent-produced, ``build`` for a build, and ``human`` for a human role. The
    derivation is read-only: it never rewrites a committed record.
    """
    producer = record.get("producer") or {}
    kind = producer.get("kind")
    role = producer.get("role") or "coordinator"
    if kind == "build":
        return {"class": "build", "stages": [{"role": role, "model": "build"}]}
    if kind == "human":
        return {"class": "human", "stages": [{"role": role, "model": "human"}]}
    model = producer.get("model") or ""
    return {"class": "same_model", "stages": [{"role": role, "model": model or "unknown"}]}


def classify_stages(stages):
    """Classify from explicit stage models: >1 model family is cross_model."""
    families = {family_of(s.get("model", "")) for s in stages if s.get("model")}
    families.discard("")
    if not families:
        return "same_model"
    return "cross_model" if len(families) > 1 else "same_model"


def classify_record(record):
    """Return the record's independence classification (explicit or derived)."""
    ind = record.get("independence")
    if isinstance(ind, dict) and ind.get("class") in INDEPENDENCE_CLASSES:
        return ind
    return derive_independence(record)


def independence_of(record):
    return classify_record(record).get("class", "same_model")


def derive_caveat(record, protocol=None, residuals=None):
    """Generate the human-readable independence caveat from structured fields.

    Deterministic: the same record, protocol, and residual set always produce
    byte-identical text. ``protocol`` names the audit protocol; ``residuals``
    are representation residuals the audit inherits.
    """
    independence = classify_record(record)
    klass = independence["class"]
    bits = []
    if klass == "build":
        bits.append("Verification is the local pinned build only.")
    elif klass == "human":
        bits.append("Produced by a human role, not an agent.")
    else:
        proto = protocol or "two-stage blind"
        if proto == "two-stage blind":
            bits.append(
                "Two-stage blind protocol (Section 11.2): stage 1 (read-back) "
                "saw only the Lean declarations and definitions; stage 2 "
                "(comparison) saw only the read-back and the contract."
            )
        elif proto == "adversarial read":
            bits.append(
                "Independent adversarial read (Section 11a.2): a fresh reader "
                "reconstructed the argument from the definitions and proof "
                "alone, with no project history."
            )
        elif proto == "encoding audit":
            bits.append("Representation encoding audit (Section 11.5).")
        elif proto == "self-check":
            bits.append(
                "Same-session self-check against the manuscript "
                "(Section 16.3 step 2)."
            )
        else:
            bits.append(f"Audit protocol: {proto}.")
        families = sorted(
            {family_of(s.get("model", "")) for s in independence.get("stages", [])}
            - {""}
        )
        label = ", ".join(families) if families else "unknown"
        if klass == "same_model":
            bits.append(
                f"All stages share the model family {label}, so common blind "
                "spots are not excluded."
            )
        else:
            bits.append(
                f"Stages ran on distinct model families ({label}); independence "
                "is measured across models."
            )
    if residuals:
        bits.append(
            "Inherits representation residuals " + ", ".join(sorted(residuals)) + "."
        )
    return " ".join(bits)


def load_tiers(path):
    """Explicit treatment tiers (Section 8.3).

    A block absent from this store has **no recorded tier** and is *not*
    treated as ``light``: the independence requirement applies until the author
    records a ``light`` designation.
    """
    p = Path(path)
    if not p.exists():
        return {}
    doc = json.loads(p.read_text(encoding="utf-8"))
    return doc.get("tiers", doc) if isinstance(doc, dict) else {}


def load_default_tiers():
    """The committed treatment-tier store (``blocks/treatment_tiers.json``)."""
    return load_tiers(HERE.parent / TIER_STORE)


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


def superseded_ids(records, registry, representation_hashes):
    """Stale records whose (block, layer) still has current evidence.

    A stale record is *superseded* when the same block and layer already has a
    current record - the work it described has been redone - and *awaiting* only
    when its layer has no current evidence at all. The optional
    ``supersedes``/``reissue_reason`` fields (Section 7.2) record which record
    replaced it and why; the classification itself does not depend on them, so
    legacy re-issues made before the fields existed still classify correctly.
    """
    scopes_with_current = {
        (r.get("block"), r.get("layer"))
        for r in records
        if record_is_current(r, registry, representation_hashes)
    }
    return {
        r.get("evidence_id")
        for r in records
        if (r.get("block"), r.get("layer")) in scopes_with_current
        and not record_is_current(r, registry, representation_hashes)
    }


def layer_status(records, registry, representation_hashes, tier=None, gate=True):
    """Derive a single layer status from its records. Returns (status, detail).

    A stale record is *superseded* when its layer still has current evidence,
    and *awaiting* re-audit otherwise (Section 7.2). The two are reported
    separately so a run of content-preserving re-issues does not read as a
    backlog of unverified claims.

    A current positive layer whose every positive record is ``same_model`` is
    ``provisional`` rather than ``pass``, unless the block is explicitly
    ``light``-tier (Section 9). An unclassified block is not exempt.
    """
    if not records:
        return "none", {"current": 0, "stale": 0, "superseded": 0, "awaiting": 0, "negative": 0}
    current = [r for r in records if record_is_current(r, registry, representation_hashes)]
    stale = [r for r in records if r not in current]
    detail = {
        "current": len(current),
        "stale": len(stale),
        "superseded": len(stale) if current else 0,
        "awaiting": 0 if current else len(stale),
        "negative": sum(1 for r in current if r.get("outcome") in NEGATIVE),
    }
    if current:
        if any(r.get("outcome") in NEGATIVE for r in current):
            return "fail", detail
        positive = [r for r in current if r.get("outcome") in POSITIVE]
        if positive:
            if gate and tier != "light" and not any(
                independence_of(r) in INDEPENDENT_CLASSES for r in positive
            ):
                return "provisional", detail
            return "pass", detail
        return "in_progress", detail
    return "stale", detail


def tier_of(tiers, block):
    """The tier string for a block from the store, or None if unclassified."""
    entry = (tiers or {}).get(block)
    value = entry.get("tier") if isinstance(entry, dict) else entry
    return value if value in ("light", "cabinet") else None


def block_status(records_by_layer, registry, representation_hashes, tiers=None,
                 block=None, gate=True):
    out = {}
    tier = tier_of(tiers, block) if block else None
    for layer, records in records_by_layer.items():
        status, detail = layer_status(
            records, registry, representation_hashes, tier=tier, gate=gate
        )
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
    ap.add_argument("--tiers", default=str(HERE.parent / TIER_STORE))
    ap.add_argument("--shadow-independence", action="store_true",
                    help="report pass, but also count what would be provisional")
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
    tiers = load_tiers(args.tiers)
    gate = not args.shadow_independence

    report = {}
    for block, layers in sorted(grouped.items()):
        report[block] = block_status(layers, registry, rep, tiers=tiers,
                                     block=block, gate=gate)

    would_flip = []
    if args.shadow_independence:
        for block, layers in sorted(grouped.items()):
            gated = block_status(layers, registry, rep, tiers=tiers,
                                 block=block, gate=True)
            for layer, st in sorted(gated.items()):
                if st["status"] == "provisional":
                    would_flip.append((block, layer))

    # Blocks with no records at all.
    if not args.block:
        missing = [b for b in registry if b not in report]
    else:
        missing = []

    if args.json:
        payload = {"blocks": report, "no_records": missing}
        if args.shadow_independence:
            payload["would_be_provisional"] = [
                {"block": b, "layer": l} for b, l in would_flip
            ]
        print(json.dumps(payload, indent=2, sort_keys=True))
        return 0

    print(f"status: {len(records)} evidence record(s), {len(report)} block(s) with evidence")
    for block, layers in report.items():
        for layer, st in layers.items():
            print(
                f"  {block:10s} {layer:14s} {st['status']:12s} "
                f"(current={st['current']} stale={st['stale']} "
                f"superseded={st['superseded']} awaiting={st['awaiting']} "
                f"negative={st['negative']})"
            )
    if missing:
        print(f"status: {len(missing)} block(s) have no evidence at all")
    if args.shadow_independence:
        print(
            f"status: shadow independence -- {len(would_flip)} layer(s) would be "
            f"provisional once the gate is enabled"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
