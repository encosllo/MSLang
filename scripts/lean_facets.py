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
    r"(theorem|lemma|def|abbrev|opaque)\s+([A-Za-z_][A-Za-z0-9_'.]*)"
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

    A block may map to several declarations (``decls``); their statements and
    proofs are concatenated before hashing.  Per Section 6, ``formal_statement``
    is the declaration's own signature **together with its definition closure**
    (the transitive ``formal_uses`` dependencies' statements), so a definition
    change propagates to its dependents; proofs are excluded from the closure,
    so proof irrelevance is preserved.
    """
    cache = {}
    raw = {}
    blocks = {}
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
        stmts, proofs, pieces = [], [], []
        for s in shorts:
            d = cache[path][s]
            stmts.append(d["statement"])
            proofs.append(d["proof"])
            pieces.append(d["statement"] + "\n" + d["proof"])
        raw[bid] = {
            "decls": names, "file": spec["file"],
            "stmts": stmts, "proofs": proofs, "text": "\n".join(pieces),
        }

    shorts_by_block = {
        bid: [n.split(".")[-1] for n in raw[bid]["decls"]] for bid in raw
    }
    edges = []
    adjacency = {}
    for bid in sorted(raw):
        for other in sorted(raw):
            if other == bid:
                continue
            if any(word_present(n, raw[bid]["text"]) for n in shorts_by_block[other]):
                edges.append({"from": bid, "to": other, "kind": "formal_uses"})
                adjacency.setdefault(bid, set()).add(other)

    def closure(bid):
        seen, stack = set(), list(adjacency.get(bid, ()))
        while stack:
            cur = stack.pop()
            if cur in seen:
                continue
            seen.add(cur)
            stack.extend(adjacency.get(cur, ()))
        return sorted(seen)

    for bid, r in raw.items():
        deps = closure(bid)
        dep_stmts = "\n".join("\n".join(raw[o]["stmts"]) for o in deps)
        blocks[bid] = {
            "decls": r["decls"],
            "file": r["file"],
            "definition_closure": deps,
            "formal_statement": {
                "hash": hash_text("\n".join(r["stmts"]) + "\n" + dep_stmts)
            },
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
