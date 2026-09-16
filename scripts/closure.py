#!/usr/bin/env python3
"""Computed evidence-input closures (Architecture.md Section 12.3, P13).

Given a block and an evidence layer, compute the *input closure*: the facets
that layer examines, plus the **statements** (never the proofs) of every block
in the transitive dependency closure, plus the representation hash for the
review and correspondence layers.

Properties required by the architecture:

* **Computed, never authored.** The input list is derived from
  ``blocks/graph.json`` (confirmed edges) and ``blocks/registry.json``; it is
  not typed by whoever runs a check.
* **Transitive, statement-only.** A dependency contributes its statement
  facet; its own proof is never pulled in, so a proof rewrite cannot stale a
  dependent's review (proof irrelevance, Section 13.1).
* **Fail closed.** If an edge is unresolved, or a required facet hash is
  missing (for example a formal statement before Lean exists, or the
  representation record before it has been written), closure generation fails
  and names the blocker. A partial closure is never emitted.
* **Deterministic.** The same graph and facets yield the same sorted input
  list, so the resulting evidence record is reproducible (Section 22).

Usage:
    python3 scripts/closure.py --block B-C001 --layer review
    python3 scripts/closure.py --block B-C001 --layer review \
        --representation representation/encoding.json
    python3 scripts/closure.py --block B-D001 --layer verification
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
from pathlib import Path

# Facets a layer examines for the block itself (Section 12.3 "Layer selects
# facets"), before the transitive statement closure is added.
LAYER_SELF_FACETS = {
    "review": ["informal_statement", "informal_proof", "explanation"],
    "correspondence": [
        "informal_statement",
        "formal_statement",
        "definition_closure",
    ],
    "verification": ["formal_proof"],
    "representation": [],
}
STATEMENT_LAYERS = {"review", "correspondence"}  # need representation hash
DEPENDENCY_EDGE_KINDS = {"uses_statement", "uses_definition"}


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_registry(path: Path):
    doc = json.loads(Path(path).read_text(encoding="utf-8"))
    blocks = {b["id"]: b for b in doc["blocks"] if b.get("id")}
    _merge_formal(path, blocks)
    return blocks


def _merge_formal(registry_path, blocks):
    """Merge Lean formal facets from ``blocks/formal.json`` (if present).

    Kept out of the registry file so ``ingest.py --check`` still reproduces the
    TeX-derived registry alone (Architecture.md Sections 6, 12.3).
    """
    formal = Path(registry_path).parent / "formal.json"
    if not formal.exists():
        return
    try:
        doc = json.loads(formal.read_text(encoding="utf-8"))
    except Exception:
        return
    for bid, entry in doc.get("blocks", {}).items():
        block = blocks.get(bid)
        if not block or entry.get("error"):
            continue
        facets = block.setdefault("facets", {})
        for facet in ("formal_statement", "formal_proof", "definition_closure"):
            if entry.get(facet):
                facets[facet] = entry[facet]


def load_edges(path: Path, confirmed_only: bool = True):
    doc = json.loads(Path(path).read_text(encoding="utf-8"))
    edges = doc["edges"]
    if confirmed_only:
        edges = [e for e in edges if e.get("confirmed")]
    return edges


def facet_hash(block_id, facet, registry, overrides=None):
    """Resolve a facet hash, or None if the facet does not exist."""
    if overrides and (block_id, facet) in overrides:
        return overrides[(block_id, facet)]
    block = registry.get(block_id)
    if not block:
        return None
    facets = block.get("facets", {})
    entry = facets.get(facet)
    if entry is None:
        return None
    return entry.get("hash")


def compute_closure(
    block_id,
    layer,
    registry,
    edges,
    representation_hash=None,
    representation_name="encoding",
    overrides=None,
    environment=None,
):
    """Return {"block","layer","inputs":[...]} or a fail-closed blocker dict.

    ``overrides`` maps ``(block_id, facet) -> hash`` and exists so propagation
    tests can seed changes; production callers leave it None.
    """
    if layer not in LAYER_SELF_FACETS:
        return {"blocked": True, "reason": f"unknown layer {layer!r}"}

    # The representation layer audits the representation artifact itself
    # (Section 11.5); it is not a registry block and has a single input.
    if layer == "representation":
        if not representation_hash:
            return {
                "blocked": True,
                "reason": "representation layer requires the representation hash",
                "block": block_id,
                "layer": layer,
            }
        return {
            "block": block_id,
            "layer": layer,
            "inputs": [
                {
                    "artifact": f"representation/{representation_name}",
                    "hash": representation_hash,
                }
            ],
            "environment": None,
        }

    if block_id not in registry:
        return {"blocked": True, "reason": f"block {block_id!r} not in registry"}

    if layer in STATEMENT_LAYERS and not representation_hash:
        return {
            "blocked": True,
            "reason": "representation not resolved (Section 11.5): no "
            "representation hash supplied for a statement-dependent layer",
            "block": block_id,
            "layer": layer,
        }
    if layer == "verification" and not environment:
        return {
            "blocked": True,
            "reason": "verification layer requires the pinned environment "
            "(lean, mathlib)",
            "block": block_id,
            "layer": layer,
        }

    inputs = {}

    def add(bid, facet):
        h = facet_hash(bid, facet, registry, overrides)
        if h is None:
            return (bid, facet)
        inputs[f"{bid}/{facet}"] = h
        return None

    # Own facets. For review, an `explanation` (Section 11a.5) substitutes for
    # an absent informal proof: a reconstructed proof is a legitimate object of
    # review. Its absence is otherwise not a blocker.
    for facet in LAYER_SELF_FACETS[layer]:
        if facet == "explanation":
            h = facet_hash(block_id, facet, registry, overrides)
            if h:
                inputs[f"{block_id}/{facet}"] = h
            continue
        missing = add(block_id, facet)
        if missing:
            if layer == "review" and facet == "informal_proof":
                exp = facet_hash(block_id, "explanation", registry, overrides)
                if exp:
                    inputs[f"{block_id}/explanation"] = exp
                    continue
            return {
                "blocked": True,
                "reason": f"missing facet {missing[1]!r} on {missing[0]}",
                "block": block_id,
                "layer": layer,
            }

    # Transitive statement closure over confirmed dependency edges.
    if layer in STATEMENT_LAYERS:
        adjacency = {}
        for e in edges:
            if e["kind"] in DEPENDENCY_EDGE_KINDS:
                adjacency.setdefault(e["from"], set()).add(e["to"])
        seen, stack = set(), list(adjacency.get(block_id, ()))
        while stack:
            cur = stack.pop()
            if cur in seen or cur == block_id:
                continue
            seen.add(cur)
            if cur not in registry:
                return {
                    "blocked": True,
                    "reason": f"unresolved dependency edge -> {cur}",
                    "block": block_id,
                    "layer": layer,
                }
            missing = add(cur, "informal_statement")
            if missing:
                return {
                    "blocked": True,
                    "reason": f"missing dependency statement {missing[0]}/"
                    f"{missing[1]}",
                    "block": block_id,
                    "layer": layer,
                }
            stack.extend(adjacency.get(cur, ()))
        if representation_hash:
            inputs[f"representation/{representation_name}"] = representation_hash

    if layer == "verification":
        # Environment is recorded separately, not a hashed input.
        pass

    ordered = [
        {"artifact": k, "hash": inputs[k]} for k in sorted(inputs)
    ]
    return {
        "block": block_id,
        "layer": layer,
        "inputs": ordered,
        "environment": environment if layer == "verification" else None,
    }


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("--block", required=True)
    ap.add_argument("--layer", required=True, choices=sorted(LAYER_SELF_FACETS))
    ap.add_argument("--registry", default="blocks/registry.json")
    ap.add_argument("--graph", default="blocks/graph.json")
    ap.add_argument(
        "--representation",
        help="file to hash as the representation artifact (Section 11.5)",
    )
    ap.add_argument(
        "--representation-name",
        default="encoding",
        help="name used for the representation input (default: encoding)",
    )
    ap.add_argument(
        "--include-unconfirmed",
        action="store_true",
        help="use unconfirmed candidate edges (default: confirmed only)",
    )
    args = ap.parse_args(argv)

    registry = load_registry(Path(args.registry))
    edges = load_edges(Path(args.graph), confirmed_only=not args.include_unconfirmed)
    rep = sha256_file(Path(args.representation)) if args.representation else None
    environment = None
    if args.layer == "verification":
        environment = {
            "lean": os.environ.get("LEAN_VERSION", ""),
            "mathlib": os.environ.get("MATHLIB_REV", ""),
        }
    result = compute_closure(
        args.block,
        args.layer,
        registry,
        edges,
        representation_hash=rep,
        representation_name=args.representation_name,
        environment=environment,
    )
    print(json.dumps(result, indent=2, sort_keys=True))
    return 1 if result.get("blocked") else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
