#!/usr/bin/env python3
"""Anchor-based block hasher for the manuscript.

Architecture.md Section 13.3 item 1: hashing must be keyed to stable anchors
(LaTeX labels, ``\\begin{proof}``/``\\end{proof}`` pairs, or an explicit
``\\blockid{}`` macro), never to raw line ranges, so that an edit cannot
silently desync every hash below it.

This is the Phase-0/1 tool: it scans the manuscript for theorem-like
environments and for proof environments, assigns each a stable anchor
(preferring ``\\blockid{...}``, then a ``\\label{...}`` inside it, then a
positional fallback), and prints a ``anchor -> sha256`` map.

Normalization before hashing: comments (unescaped ``%``) are removed and
whitespace is collapsed. Macro expansion is NOT done yet -- that is the
Section 14 importer's job (Section 13.1 says macros are treated as C4 unless
shown display-only), so a macro change will change these hashes.

Usage:
    python3 scripts/hash_blocks.py FILE                 # print JSON map
    python3 scripts/hash_blocks.py --out blocks/hashes.json FILE
    python3 scripts/hash_blocks.py --check blocks/hashes.json FILE
"""
from __future__ import annotations

import hashlib
import json
import re
import sys

THEOREM_ENVS = (
    "thm",
    "prop",
    "lem",
    "cor",
    "dfn",
    "rmk",
    "notation",
    "theorem",
    "lemma",
    "proposition",
    "corollary",
    "definition",
    "remark",
    "example",
    "examples",
    "assumption",
)
ENV_ALT = "|".join(THEOREM_ENVS)

BEGIN_RE = re.compile(r"\\begin\{(?P<name>[A-Za-z*]+)\}")
LABEL_RE = re.compile(r"\\label\{([^}]*)\}")
BLOCKID_RE = re.compile(r"\\blockid\{([^}]*)\}")
COMMENT_RE = re.compile(r"(?<!\\)%.*")


def strip_comments(text: str) -> str:
    return "\n".join(COMMENT_RE.sub("", line) for line in text.splitlines())


def normalize(text: str) -> str:
    text = strip_comments(text)
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def find_env_spans(text: str, name: str):
    """Yield (begin_start, content_start, content_end, body) for each env ``name``.

    ``begin_start`` is the offset of ``\\begin{name}``; ``content_start`` is
    just after it. Handles nesting of the *same* environment name by tracking
    depth.
    """
    begin = re.compile(r"\\begin\{" + re.escape(name) + r"\}")
    end = re.compile(r"\\end\{" + re.escape(name) + r"\}")
    pos = 0
    while True:
        m = begin.search(text, pos)
        if not m:
            return
        depth = 1
        scan = m.end()
        while depth:
            nb = begin.search(text, scan)
            ne = end.search(text, scan)
            if ne is None:
                return  # malformed; give up on this env
            if nb is not None and nb.start() < ne.start():
                depth += 1
                scan = nb.end()
            else:
                depth -= 1
                if depth == 0:
                    yield m.start(), m.end(), ne.start(), text[m.end() : ne.start()]
                    pos = ne.end()
                else:
                    scan = ne.end()


def preceding_blockid(text: str, begin_start: int):
    """``\\blockid{...}`` placed immediately before ``\\begin{...}``, if any.

    The manuscript annotates blocks as ``\\blockid{B-...}`` on the line *before*
    the environment (Architecture.md Section 14); an in-body ``\\blockid`` is
    also accepted by ``extract`` for robustness.
    """
    m = re.search(
        r"\\blockid\{([^}]*)\}\s*$",
        text[:begin_start],
    )
    return m.group(1) if m else None


def extract(text: str):
    """Return ordered list of (anchor, body)."""
    text = strip_comments(text)
    found = []
    for name in THEOREM_ENVS:
        for begin_start, start, _end, body in find_env_spans(text, name):
            bid = BLOCKID_RE.search(body)
            lab = LABEL_RE.search(body)
            pre = preceding_blockid(text, begin_start)
            if pre:
                anchor = pre
            elif bid:
                anchor = bid.group(1)
            elif lab:
                anchor = lab.group(1)
            else:
                anchor = f"env:{name}:{len(found)}"
            found.append((start, name, anchor, body))
    for begin_start, start, _end, body in find_env_spans(text, "proof"):
        lab = LABEL_RE.search(body)
        anchor = lab.group(1) if lab else f"proof:{len(found)}"
        found.append((start, "proof", anchor, body))

    found.sort(key=lambda t: t[0])
    anchors = {}
    for _start, _name, anchor, body in found:
        if anchor in anchors:
            sys.stderr.write(f"hash_blocks: duplicate anchor {anchor!r}\n")
            anchor = f"{anchor}#dup{len(anchors)}"
        anchors[anchor] = normalize(body)
    return anchors


def hash_map(text: str):
    return {a: hashlib.sha256(b.encode("utf-8")).hexdigest() for a, b in extract(text).items()}


def main(argv: list[str]) -> int:
    out = None
    check = None
    files = []
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == "--out":
            i += 1
            out = argv[i]
        elif a == "--check":
            i += 1
            check = argv[i]
        else:
            files.append(a)
        i += 1
    if not files:
        print(__doc__.strip(), file=sys.stderr)
        return 2

    with open(files[0], "r", encoding="latin1") as fh:
        current = hash_map(fh.read())

    if check:
        with open(check, "r", encoding="utf-8") as fh:
            recorded = json.load(fh)
        stale = []
        for anchor, digest in recorded.items():
            if anchor not in current:
                stale.append((anchor, "missing"))
            elif current[anchor] != digest:
                stale.append((anchor, "changed"))
        added = [a for a in current if a not in recorded]
        for anchor, why in stale:
            print(f"STALE {anchor}: {why}", file=sys.stderr)
        for anchor in added:
            print(f"NEW   {anchor}", file=sys.stderr)
        if stale:
            return 1
        print(f"hash_blocks: {len(recorded)} anchors current", file=sys.stderr)
        return 0

    payload = json.dumps(current, indent=2, sort_keys=True)
    if out:
        with open(out, "w", encoding="utf-8") as fh:
            fh.write(payload + "\n")
        print(f"hash_blocks: wrote {len(current)} anchors to {out}", file=sys.stderr)
    else:
        print(payload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
