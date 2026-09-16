#!/usr/bin/env python3
"""Formal (Lean) facet extraction and hashing (Architecture.md Sections 6,
7.2, 12.3).

A Lean declaration contributes two independently hashed facets:

    formal_statement   the declared signature (the claim)
    formal_proof       the term or tactic script (the argument)

so that a proof rewrite stales only that block's verification, never the
correspondence of blocks that use its statement (Section 7.2, proof
irrelevance).

The block -> declaration map lives in ``lean/declarations.json``.  This tool
extracts each declaration from its source file, splits it at the first
top-level ``:=``, normalizes (Lean comments removed, whitespace collapsed), and
writes the hashes to ``blocks/formal.json``.  ``scripts/closure.py`` and
``scripts/status.py`` merge that file into the registry's facets, so evidence
closures and status see the formal facets while ``ingest.py --check`` still
covers the TeX-derived registry alone.

Honest limitation: this is a *source-level* facet, not the elaborated signature.
It is stable under the edits the architecture cares about (statement vs proof)
but does not yet normalize equivalent surface syntaxes.

Usage:
    python3 scripts/lean_facets.py
    python3 scripts/lean_facets.py --check
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

DECL_RE = re.compile(
    r"(?m)^(?:(?:noncomputable|private|protected|unsafe)\s+)*"
    r"(theorem|lemma|def|abbrev|opaque|inductive)\s+([A-Za-z_][A-Za-z0-9_'.]*)"
)
BOUNDARY_RE = re.compile(r"(?m)^(?:end|namespace|section|variable|open)\b|^@\[")


def strip_lean_comments(text: str) -> str:
    """Remove nested block comments and line comments."""
    out = []
    depth = 0
    i = 0
    n = len(text)
    while i < n:
        if text.startswith("/-", i):
            depth += 1
            i += 2
        elif text.startswith("-/", i) and depth:
            depth -= 1
            i += 2
        elif depth:
            i += 1
        elif text.startswith("--", i):
            j = text.find("\n", i)
            i = n if j == -1 else j
        else:
            out.append(text[i])
            i += 1
    return "".join(out)


def normalize(text: str) -> str:
    text = strip_lean_comments(text)
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def split_top_level(text: str) -> int:
    """Index of the first ``:=`` at bracket depth 0, or -1."""
    depth = 0
    i = 0
    n = len(text)
    while i < n - 1:
        c = text[i]
        if c in "([{":
            depth += 1
        elif c in ")]}":
            depth -= 1
        elif text.startswith(":=", i) and depth == 0:
            return i
        i += 1
    return -1


def extract_declarations(source: str):
    """Return {short_name: {"statement", "proof"}} for top-level declarations."""
    text = strip_lean_comments(source)
    matches = list(DECL_RE.finditer(text))
    decls = {}
    for idx, m in enumerate(matches):
        name = m.group(2)
        start = m.start()
        end = matches[idx + 1].start() if idx + 1 < len(matches) else len(text)
        block = text[start:end]
        boundary = BOUNDARY_RE.search(block, m.end() - start)
        if boundary:
            block = block[: boundary.start()]
        block = block.strip()
        cut = split_top_level(block)
        if cut == -1:
            statement, proof = block, ""
        else:
            statement, proof = block[:cut].strip(), block[cut:].strip()
        decls[name] = {"statement": statement, "proof": proof}
    return decls


def hash_text(text: str) -> str:
    return hashlib.sha256(normalize(text).encode("utf-8")).hexdigest()


def load_map(path: Path):
    return json.loads(Path(path).read_text(encoding="utf-8")).get("blocks", {})


def declaration_names(spec):
    """The full declaration names for a block (``decl`` or ``decls``)."""
    if "decls" in spec:
        return list(spec["decls"])
    return [spec["decl"]]


def word_present(name: str, text: str) -> bool:
    """Whole-identifier occurrence of ``name`` in Lean ``text``."""
    return (
        re.search(r"(?<![A-Za-z0-9_'])" + re.escape(name) + r"(?![A-Za-z0-9_'])", text)
        is not None
    )


def compute(decl_map, root: Path = ROOT):
    """Return (blocks/formal.json content, blocks/formal_graph.json content).

    A block may map to several declarations (``decls``). Each declaration
    contributes two independently hashed facets:

    * ``formal_statement`` -- the declaration's own signature only;
    * ``formal_proof`` -- its term or script.

    and the block's ``definition_closure`` is a third facet: the statements of
    the declarations it transitively uses, together with the *declaration names*
    of that closure. The closure is keyed on declaration identity, not on block
    membership, so re-registering a declaration under a different block (a
    bookkeeping edit, Section 13.2 class C5) changes no dependent's closure.
    Proofs are excluded from the closure, so proof irrelevance is preserved,
    while a definition change still moves its dependents' closure (Section 6).
    """
    cache = {}
    raw = {}
    blocks = {}
    decl_info = {}
    for bid in sorted(decl_map):
        spec = decl_map[bid]
        path = root / spec["file"]
        if path not in cache:
            cache[path] = (
                extract_declarations(path.read_text(encoding="utf-8"))
                if path.exists()
                else {}
            )
        names = declaration_names(spec)
        shorts = [n.split(".")[-1] for n in names]
        missing = [n for n, s in zip(names, shorts) if s not in cache[path]]
        if missing:
            blocks[bid] = {
                "decls": names,
                "file": spec["file"],
                "error": f"declaration(s) {missing} not found in {spec['file']}",
            }
            continue
        stmts, proofs = [], []
        for n, s in zip(names, shorts):
            d = cache[path][s]
            stmts.append(d["statement"])
            proofs.append(d["proof"])
            decl_info[s] = {
                "full": n, "block": bid,
                "statement": d["statement"], "proof": d["proof"],
            }
        raw[bid] = {
            "decls": names, "file": spec["file"],
            "shorts": shorts, "stmts": stmts, "proofs": proofs,
        }

    # Declaration-level formal_uses: whole-identifier occurrence of another
    # mapped declaration's short name anywhere in this declaration's text.
    decls_sorted = sorted(decl_info)
    decl_adj = {s: set() for s in decls_sorted}
    for s in decls_sorted:
        text = decl_info[s]["statement"] + "\n" + decl_info[s]["proof"]
        for t in decls_sorted:
            if t != s and word_present(t, text):
                decl_adj[s].add(t)

    def decl_closure(bid):
        own = set(raw[bid]["shorts"])
        seen, stack = set(), [t for s in own for t in decl_adj.get(s, ())]
        while stack:
            cur = stack.pop()
            if cur in seen or cur in own:
                continue
            seen.add(cur)
            stack.extend(decl_adj.get(cur, ()))
        return sorted(seen)

    # Block-level formal graph, derived from the declaration edges (used by the
    # discrepancy and impact views; not an evidence input).
    edge_pairs = set()
    for s in decls_sorted:
        for t in decl_adj[s]:
            b1, b2 = decl_info[s]["block"], decl_info[t]["block"]
            if b1 != b2:
                edge_pairs.add((b1, b2))
    edges = [
        {"from": a, "to": b, "kind": "formal_uses"} for a, b in sorted(edge_pairs)
    ]

    for bid, r in raw.items():
        deps = decl_closure(bid)
        dep_stmts = "\n".join(decl_info[s]["statement"] for s in deps)
        blocks[bid] = {
            "decls": r["decls"],
            "file": r["file"],
            "definition_closure": {
                "decls": sorted(decl_info[s]["full"] for s in deps),
                "hash": hash_text(dep_stmts),
            },
            "formal_statement": {"hash": hash_text("\n".join(r["stmts"]))},
            "formal_proof": (
                {"hash": hash_text("\n".join(r["proofs"]))}
                if any(r["proofs"])
                else None
            ),
        }
    graph = {
        "note": "Declared (formal) dependencies among mapped blocks, extracted from "
        "source by whole-identifier occurrence (Architecture.md Section 12.1).",
        "edges": edges,
    }
    return {"source": "lean/declarations.json", "blocks": blocks}, graph


def render(formal) -> str:
    return json.dumps(formal, indent=2, sort_keys=True) + "\n"


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("--declarations", default=str(ROOT / "lean" / "declarations.json"))
    ap.add_argument("--out", default=str(ROOT / "blocks" / "formal.json"))
    ap.add_argument("--graph-out", default=str(ROOT / "blocks" / "formal_graph.json"))
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args(argv)

    formal, graph = compute(load_map(Path(args.declarations)))
    payload = render(formal)
    gpayload = render(graph)

    errors = [
        f"{bid}: {entry['error']}"
        for bid, entry in formal["blocks"].items()
        if entry.get("error")
    ]
    if errors:
        for e in errors:
            print(f"lean_facets: ERROR {e}", file=sys.stderr)
        return 1

    outputs = [(Path(args.out), payload), (Path(args.graph_out), gpayload)]
    if args.check:
        for out, text in outputs:
            existing = out.read_text(encoding="utf-8") if out.exists() else None
            if existing != text:
                print(f"lean_facets: drift in {out}", file=sys.stderr)
                return 1
        print(
            f"lean_facets: {len(formal['blocks'])} declaration(s), "
            f"{len(graph['edges'])} formal edge(s) current"
        )
        return 0

    for out, text in outputs:
        out.write_text(text, encoding="utf-8")
        print(f"lean_facets: wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
