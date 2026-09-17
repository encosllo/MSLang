#!/usr/bin/env python3
"""Evidence record writer (Architecture.md Sections 7.2, 12.3; P13).

Builds an evidence record whose ``inputs`` are **computed** from the dependency
graph via ``scripts/closure.py`` -- never typed by hand -- validates it against
``schemas/evidence.schema.json``, and (only with ``--write``) persists it under
``evidence/`` as an immutable ``E-XXXXXX.json``. If closure generation fails
closed, no record is produced.

This tool does not perform audits; it only records the outcome of one that
actually happened. It defaults to printing the record and never writing unless
``--write`` is given.

Usage:
    python3 scripts/evidence.py new --block B-C001 --layer review \
        --representation representation/pilot-encoding.md \
        --producer-role adversarial_reader --outcome pass --strength R1 \
        --protocol "adversarial read" --finding "..." [--write]

The ``independence`` classification and the ``independence_caveat`` text are
**computed** from the producer and protocol (Architecture.md Section 9); neither
is a hand-entered field.
"""
from __future__ import annotations

import argparse
import datetime as _dt
import json
import os
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import closure  # noqa: E402
import models  # noqa: E402
import status  # noqa: E402
import validate_records  # noqa: E402

ROOT = HERE.parent


def parse_stages(specs):
    stages = []
    for spec in specs or []:
        role, _, model = spec.partition("=")
        if not role.strip() or not model.strip():
            raise SystemExit(f"evidence: --stage expects ROLE=MODEL, got {spec!r}")
        stages.append({"role": role.strip(), "model": model.strip()})
    return stages


def build_independence(args):
    """Compute the record's independence object (Architecture.md Section 9).

    Explicit ``--stage`` declarations win; otherwise an agent record is routed
    with ``scripts/models.py`` (cross-family where the registry offers one), and
    a build/human record is classified from its producer.
    """
    if args.stage:
        stages = parse_stages(args.stage)
        return {"class": status.classify_stages(stages), "stages": stages}
    if args.producer_kind == "agent":
        registry = models.load_registry(args.models)
        if args.model not in registry:
            raise SystemExit(
                f"evidence: model {args.model!r} is not declared in {args.models}"
            )
        chosen = models.choose_stages(registry, args.model, [args.producer_role])
        return {"class": chosen["class"], "stages": chosen["stages"]}
    return status.derive_independence(
        {"producer": {"kind": args.producer_kind, "role": args.producer_role}}
    )


def next_evidence_id(evidence_dir):
    mx = 0
    for path in Path(evidence_dir).glob("E-*.json"):
        m = re.match(r"E-(\d{6})\.json$", path.name)
        if m:
            mx = max(mx, int(m.group(1)))
    return f"E-{mx + 1:06d}"


def new_record(args):
    registry = closure.load_registry(ROOT / "blocks" / "registry.json")
    edges = closure.load_edges(ROOT / "blocks" / "graph.json", confirmed_only=True)
    rep = (
        status.hash_file(args.representation) if args.representation else None
    )
    environment = {
        "lean": os.environ.get("LEAN_VERSION", "leanprover/lean4:v4.33.1"),
        "mathlib": os.environ.get(
            "MATHLIB_REV", "0df444a360eaa60ab8c11dca51a86af692955474"
        ),
    }
    result = closure.compute_closure(
        args.block,
        args.layer,
        registry,
        edges,
        representation_hash=rep,
        representation_name=args.representation_name,
        environment=environment if args.layer == "verification" else None,
    )
    if result.get("blocked"):
        print(f"evidence: closure blocked, no record: {result['reason']}", file=sys.stderr)
        return 1
    record = {
        "evidence_id": args.evidence_id or next_evidence_id(args.evidence_dir),
        "layer": args.layer,
        "block": args.block,
        "inputs": result["inputs"],
        "environment": environment,
        "producer": {
            "kind": args.producer_kind,
            "role": args.producer_role,
            "model": args.model,
            "prompt_rev": args.prompt_rev,
        },
        "outcome": args.outcome,
        "timestamp": args.timestamp
        or _dt.datetime.now(_dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }
    if args.strength:
        record["strength"] = args.strength
    record["independence"] = build_independence(args)
    record["independence_caveat"] = status.derive_caveat(
        record, protocol=args.protocol, residuals=args.residual or None
    )
    if args.finding:
        record["findings"] = args.finding
    if args.supersedes:
        record["supersedes"] = args.supersedes
    if args.reissue_reason:
        record["reissue_reason"] = args.reissue_reason

    schema = json.loads(
        (ROOT / "schemas" / "evidence.schema.json").read_text(encoding="utf-8")
    )
    errors = validate_records.validate(record, schema)
    if errors:
        print("evidence: record failed schema validation:", file=sys.stderr)
        for e in errors:
            print(f"  {e}", file=sys.stderr)
        return 1

    payload = json.dumps(record, indent=2, sort_keys=True) + "\n"
    if args.write:
        if Path(ROOT / "evidence" / f"{record['evidence_id']}.json").exists():
            print("evidence: refusing to overwrite an existing record", file=sys.stderr)
            return 2
        (ROOT / "evidence" / f"{record['evidence_id']}.json").write_text(
            payload, encoding="utf-8"
        )
        print(f"evidence: wrote evidence/{record['evidence_id']}.json", file=sys.stderr)
    else:
        print(payload)
    return 0


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("new")
    p.add_argument("--block", required=True)
    p.add_argument("--layer", required=True, choices=sorted(closure.LAYER_SELF_FACETS))
    p.add_argument("--representation")
    p.add_argument("--representation-name", default="encoding")
    p.add_argument("--evidence-id")
    p.add_argument("--evidence-dir", default=str(ROOT / "evidence"))
    p.add_argument("--producer-kind", default="agent")
    p.add_argument("--producer-role", required=True)
    p.add_argument("--model", default="deepseek-v4.1-flash")
    p.add_argument("--models", default=str(ROOT / "calibration" / "models.json"),
                   help="model registry used to route independence stages")
    p.add_argument("--stage", action="append",
                   help="explicit audit stage as ROLE=MODEL (repeatable)")
    p.add_argument("--prompt-rev", default="")
    p.add_argument("--outcome", required=True)
    p.add_argument("--strength")
    p.add_argument("--protocol", help="audit protocol name used to derive the caveat")
    p.add_argument("--residual", action="append",
                   help="representation residual inherited by this audit (repeatable)")
    p.add_argument("--finding", action="append")
    p.add_argument("--supersedes")
    p.add_argument(
        "--reissue-reason",
        choices=["hash-move", "env-bump", "remap", "facet-split", "other"],
    )
    p.add_argument("--timestamp")
    p.add_argument("--write", action="store_true")
    args = ap.parse_args(argv)
    if args.cmd == "new":
        return new_record(args)
    return 2


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
