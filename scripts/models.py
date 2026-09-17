#!/usr/bin/env python3
"""Model registry and independence routing (Architecture.md Section 9).

The repository cannot call a model, so routing is a *coordinator* duty that this
tool makes explicit and checkable:

* ``calibration/models.json`` declares the models available for audit stages,
  each with an identifier and a family;
* ``choose_stages()`` assigns a model to each stage so that an
  independence-requiring stage runs on a different family from the producer
  whenever the registry offers one, and records ``same_model`` (never a claim of
  independence) when it does not;
* ``--check`` validates that every recorded stage model is declared.

Usage:
    python3 scripts/models.py --list
    python3 scripts/models.py --check
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import status  # noqa: E402

ROOT = HERE.parent
DEFAULT_REGISTRY = ROOT / "calibration" / "models.json"
INDEPENDENCE_STAGES = {
    "comparator",
    "adversarial_reader",
    "encoding_auditor",
}


def load_registry(path):
    """Return {model_id: {"family": str, "available": bool}}."""
    doc = json.loads(Path(path).read_text(encoding="utf-8"))
    entries = doc.get("models", doc) if isinstance(doc, dict) else doc
    registry = {}
    for entry in entries:
        mid = entry.get("id")
        if not mid or not entry.get("family"):
            raise ValueError(f"model entry missing id/family: {entry!r}")
        declared = entry["family"]
        derived = status.family_of(mid)
        if declared != derived:
            raise ValueError(
                f"model {mid!r}: declared family {declared!r} disagrees with the "
                f"derived family {derived!r} (status.family_of)"
            )
        registry[mid] = {
            "family": declared,
            "available": bool(entry.get("available", True)),
        }
    return registry


def choose_stages(registry, producer_model, roles):
    """Assign a model to each role, routing independence stages cross-family.

    Returns ``{"stages": [...], "class": <classification>}``. With a single
    family the result is ``same_model``; this is the honest outcome, not an
    error.
    """
    producer_family = status.family_of(producer_model)
    others = sorted(
        mid for mid, v in registry.items()
        if v["available"] and status.family_of(mid) != producer_family
    )
    stages = []
    for role in roles:
        if role in INDEPENDENCE_STAGES and others:
            stages.append({"role": role, "model": others[0]})
        else:
            stages.append({"role": role, "model": producer_model})
    return {"stages": stages, "class": status.classify_stages(stages)}


def check_records(registry, evidence_dir):
    """Return a list of recorded stage/producer models absent from the registry."""
    unknown = []
    for path in sorted(Path(evidence_dir).glob("*.json")):
        try:
            record = json.loads(path.read_text(encoding="utf-8"))
        except Exception:
            continue
        models = set()
        producer = record.get("producer") or {}
        if producer.get("model"):
            models.add(producer["model"])
        for stage in (record.get("independence") or {}).get("stages", []):
            if stage.get("model"):
                models.add(stage["model"])
        for model in sorted(models):
            if model in ("build", "human", "unknown"):
                continue
            if model not in registry:
                unknown.append(f"{path.name}: undeclared model {model!r}")
    return unknown


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("--registry", default=str(DEFAULT_REGISTRY))
    ap.add_argument("--evidence-dir", default=str(ROOT / "evidence"))
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args(argv)

    registry = load_registry(args.registry)

    if args.list:
        for mid, entry in sorted(registry.items()):
            print(f"{mid:28s} family={entry['family']:10s} available={entry['available']}")
        return 0

    if args.check:
        unknown = check_records(registry, args.evidence_dir)
        print(f"models: {len(registry)} declared model(s)")
        for u in unknown:
            print(f"ERROR {u}")
        if unknown:
            return 1
        print("models: all recorded models are declared")
        return 0

    for mid, entry in sorted(registry.items()):
        print(f"{mid} {entry['family']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
