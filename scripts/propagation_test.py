#!/usr/bin/env python3
"""Seeded propagation tests for the evidence engine (Architecture.md Sections
13, 18, 22; roadmap Phase 2 exit criterion).

These tests seed changes directly into facet hashes and check that computed
closures (``scripts/closure.py``) respond soundly:

* soundness   -- a statement or representation change alters every closure that
  depends on it;
* proof irrelevance -- a dependency's proof change alters no dependent closure;
* fail closed -- an unresolved edge or a missing required facet blocks;
* determinism -- the same graph and facets yield the same input list.

Run:
    python3 scripts/propagation_test.py
Exits non-zero if any test fails.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import closure  # noqa: E402

ROOT = HERE.parent
REGISTRY = closure.load_registry(ROOT / "blocks" / "registry.json")
EDGES = closure.load_edges(ROOT / "blocks" / "graph.json", confirmed_only=True)
REP = "r" * 64

FAILURES = []


def check(name, condition, detail=""):
    status = "PASS" if condition else "FAIL"
    print(f"[{status}] {name}" + (f" -- {detail}" if detail and not condition else ""))
    if not condition:
        FAILURES.append(name)


def inputs(result):
    return {i["artifact"]: i["hash"] for i in result.get("inputs", [])}


def run():
    # A proposition with a proof that depends on definition B-D014.
    base = closure.compute_closure(
        "B-P002", "review", REGISTRY, EDGES, representation_hash=REP
    )
    check("B-P002 review closure resolves", not base.get("blocked"), base.get("reason"))

    # Determinism.
    again = closure.compute_closure(
        "B-P002", "review", REGISTRY, EDGES, representation_hash=REP
    )
    check("deterministic", inputs(base) == inputs(again))

    # Dependency statement change propagates.
    changed = closure.compute_closure(
        "B-P002",
        "review",
        REGISTRY,
        EDGES,
        representation_hash=REP,
        overrides={("B-D014", "informal_statement"): "a" * 64},
    )
    check(
        "dependency statement change alters closure",
        inputs(changed)["B-D014/informal_statement"] == "a" * 64
        and inputs(changed) != inputs(base),
    )

    # Dependency PROOF change is irrelevant (proof irrelevance).
    dep_proof = closure.compute_closure(
        "B-P002",
        "review",
        REGISTRY,
        EDGES,
        representation_hash=REP,
        overrides={("B-D014", "informal_proof"): "b" * 64},
    )
    check(
        "dependency proof change does NOT alter closure",
        inputs(dep_proof) == inputs(base),
    )

    # Own proof change does alter the block's own review closure.
    own_proof = closure.compute_closure(
        "B-P002",
        "review",
        REGISTRY,
        EDGES,
        representation_hash=REP,
        overrides={("B-P002", "informal_proof"): "c" * 64},
    )
    check(
        "own proof change alters closure",
        inputs(own_proof)["B-P002/informal_proof"] == "c" * 64
        and inputs(own_proof) != inputs(base),
    )

    # Representation change (class C6) stales statement-dependent closures.
    rep2 = closure.compute_closure(
        "B-P002", "review", REGISTRY, EDGES, representation_hash="d" * 64
    )
    check(
        "representation change alters closure",
        inputs(rep2)["representation/encoding"] == "d" * 64
        and inputs(rep2) != inputs(base),
    )

    # Fail closed: missing representation.
    no_rep = closure.compute_closure("B-P002", "review", REGISTRY, EDGES)
    check("missing representation blocks", no_rep.get("blocked") is True)

    # Fail closed: unresolved edge.
    bad_edges = EDGES + [
        {
            "from": "B-P002",
            "to": "B-ZZZ",
            "kind": "uses_statement",
            "source": "explicit",
            "confirmed": True,
            "detail": "seeded",
        }
    ]
    unresolved = closure.compute_closure(
        "B-P002", "review", REGISTRY, bad_edges, representation_hash=REP
    )
    check(
        "unresolved edge blocks",
        unresolved.get("blocked") is True and "unresolved" in unresolved.get("reason", ""),
    )

    # Fail closed: own missing proof (omitted-proof block with no explanation).
    # B-P001 is a proposition the manuscript states without proof and with no
    # Explanation facet.
    no_proof = closure.compute_closure(
        "B-P001", "review", REGISTRY, EDGES, representation_hash=REP
    )
    check("missing own proof blocks", no_proof.get("blocked") is True)

    # An explanation substitutes for an absent informal proof (Section 11a.5).
    explained = closure.compute_closure(
        "B-C001", "review", REGISTRY, EDGES, representation_hash=REP
    )
    check(
        "explanation substitutes for missing proof",
        not explained.get("blocked")
        and "B-C001/explanation" in inputs(explained),
        explained.get("reason", ""),
    )

    # Fail closed: unconfirmed edges excluded by default.
    unconfirmed = closure.load_edges(ROOT / "blocks" / "graph.json", confirmed_only=False)
    check(
        "unconfirmed edge set is a superset",
        len(unconfirmed) >= len(EDGES),
    )

    # Transitive statement closure: B-P035 -> ... -> B-D014.
    chain = closure.compute_closure(
        "B-P035", "review", REGISTRY, EDGES, representation_hash=REP
    )
    check(
        "transitive dependency statement present",
        not chain.get("blocked") and "B-D014/informal_statement" in inputs(chain),
        chain.get("reason", "B-D014 not in closure"),
    )

    print()
    if FAILURES:
        print(f"propagation_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("propagation_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(run())
