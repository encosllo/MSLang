#!/usr/bin/env python3
"""TeX ingestion importer for the manuscript (Architecture.md Section 14).

Produces the initial project snapshot from the main TeX source:

  1. source inventory                     -> reports/inventory.md
  2. symbol registry                      -> blocks/symbols.json
  3. lazy block registry                  -> blocks/registry.json
  4. initial dependency graph (candidates)-> blocks/graph.json
  5. gap report                           -> reports/gap_report.md
  6. suggested pilot milestone            -> reports/pilot_candidates.md

Design constraints (Architecture.md Sections 12.1, 13.3, 14):

* Block identities are read from ``\\blockid{...}`` annotations already present
  in the source.  The importer does **not** mint IDs: for a theorem-like
  environment with no ``\\blockid`` it records a *proposal* (kind + line) only,
  because minting is an author decision (Section 16.4).
* Dependency edges from explicit ``\\ref``/``\\uses`` and from number-cited
  prose are recorded as *candidates* (``confirmed: false``) for the author to
  accept; rejected edges are remembered elsewhere.
* Hashing reuses ``scripts/hash_blocks.py`` normalization so the registry hashes
  agree with ``blocks/hashes.json`` anchors by construction.
* The source is latin1 (declared by ``\\usepackage[latin1]{inputenc}``), so it is
  read as latin1 throughout, like the other scripts.

Usage:
    python3 scripts/ingest.py manuscript/MSEilenberg.tex
    python3 scripts/ingest.py --dry-run manuscript/MSEilenberg.tex
    python3 scripts/ingest.py --aux manuscript/MSEilenberg.aux FILE
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import hash_blocks as hb  # noqa: E402  (normalization shared with the hasher)

# --- Environments -----------------------------------------------------------

# Theorem-like environments (Section 14 block candidates).  Kept in sync with
# the \newtheorem declarations in the manuscript preamble.
NUMBERED_ENVS = ("theorem", "proposition", "corollary", "lemma", "definition")
UNNUMBERED_ENVS = ("example", "examples", "remark", "assumption", "notation")
BLOCK_ENVS = NUMBERED_ENVS + UNNUMBERED_ENVS
PROOF_ENV = "proof"

# Blocks whose proof is expected when they are `full` scope.  Definitions and
# remarks do not carry proofs.
PROOF_EXPECTED = ("theorem", "proposition", "corollary", "lemma")

SECTION_RE = re.compile(r"\\section\*?\{((?:[^{}]|\{[^{}]*\})*)\}")
BLOCKID_RE = re.compile(r"\\blockid\{([^}]*)\}")
BLOCKSCOPE_RE = re.compile(r"\\blockscope\{([^}]*)\}")
LABEL_RE = re.compile(r"\\label\{([^}]*)\}")
REF_RE = re.compile(r"\\(?:c?ref|eqref|autoref|nameref)\{([^}]*)\}")
USES_RE = re.compile(r"\\uses\{([^}]*)\}")
TERM_RE = re.compile(r"\\emph\{((?:[^{}]|\{[^{}]*\})*)\}")
NEWLABEL_RE = re.compile(r"\\newlabel\{([^}]*)\}\{\{([^}]*)\}")
PROSE_NUM_RE = re.compile(
    r"\b(Theorem|Proposition|Lemma|Corollary|Definition|Remark|Example)s?"
    r"~?\s*(\d+(?:\.\d+)?)\b"
)


def iter_envs(text: str, name: str):
    """Yield (start, end, body) for each ``name`` environment, handling self-nesting.

    ``start`` is the offset of ``\\begin{name}`` and ``end`` is the offset just
    after the matching ``\\end{name}``.  Optional ``[...]`` on the ``\\begin``
    is tolerated.
    """
    begin = re.compile(r"\\begin\{" + re.escape(name) + r"\}(?:\[[^\]]*\])?")
    end_re = re.compile(r"\\end\{" + re.escape(name) + r"\}")
    pos = 0
    while True:
        m = begin.search(text, pos)
        if not m:
            return
        depth = 1
        scan = m.end()
        while depth:
            nb = begin.search(text, scan)
            ne = end_re.search(text, scan)
            if ne is None:
                return
            if nb is not None and nb.start() < ne.start():
                depth += 1
                scan = nb.end()
            else:
                depth -= 1
                if depth == 0:
                    yield m.start(), ne.end(), text[m.end() : ne.start()]
                    pos = ne.end()
                else:
                    scan = ne.end()


def line_of(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def section_at(sections, offset):
    name = "<preamble>"
    for start, title in sections:
        if start <= offset:
            name = title
        else:
            break
    return name


def preceding_blockid(text: str, start: int):
    """Return the ``\\blockid`` immediately preceding ``start``, ignoring space."""
    m = re.search(r"\\blockid\{([^}]*)\}\s*$", text[:start])
    return m.group(1) if m else None


# --- Blocks -----------------------------------------------------------------


def collect_env_instances(clean: str):
    """Ordered theorem-like environments, each with its trailing proof if any."""
    blocks = []
    for name in BLOCK_ENVS:
        for start, end, body in iter_envs(clean, name):
            blocks.append({"kind": name, "start": start, "end": end, "body": body})
    blocks.sort(key=lambda b: b["start"])

    proofs = list(iter_envs(clean, PROOF_ENV))
    for i, b in enumerate(blocks):
        next_start = blocks[i + 1]["start"] if i + 1 < len(blocks) else len(clean)
        b["proof"] = None
        for ps, pe, pbody in proofs:
            if b["end"] <= ps < next_start:
                b["proof"] = {"start": ps, "end": pe, "body": pbody}
                break
    return blocks


def collect_blocks(clean: str, sections, explanations_dir=None):
    """Return the block registry for every theorem-like environment.

    ``explanations_dir`` (conventionally ``blocks/explanations``) may hold one
    ``<block-id>.md`` per reconstructed proof; its hash is recorded as the
    block's ``explanation`` facet (Architecture.md Sections 6, 11a.5).
    """
    blocks = collect_env_instances(clean)
    registry = []
    used_ids = set()
    for b in blocks:
        bid = preceding_blockid(clean, b["start"])
        label_m = LABEL_RE.search(b["body"])
        label = label_m.group(1) if label_m else None
        scope_m = BLOCKSCOPE_RE.search(b["body"])
        term_m = TERM_RE.search(b["body"])
        body_norm = hb.normalize(b["body"])
        digest = hashlib.sha256(body_norm.encode("utf-8")).hexdigest()
        proof_hash = None
        proof_anchor = None
        if b["proof"] is not None:
            proof_norm = hb.normalize(b["proof"]["body"])
            proof_hash = hashlib.sha256(proof_norm.encode("utf-8")).hexdigest()
            plabel = LABEL_RE.search(b["proof"]["body"])
            proof_anchor = plabel.group(1) if plabel else f"proof@{line_of(clean, b['proof']['start'])}"

        explanation = None
        if bid and explanations_dir:
            exp_path = Path(explanations_dir) / f"{bid}.md"
            if exp_path.exists():
                explanation = {
                    "hash": hashlib.sha256(exp_path.read_bytes()).hexdigest(),
                    "path": f"blocks/explanations/{bid}.md",
                }

        if bid:
            if bid in used_ids:
                bid = f"{bid}#dup{len(used_ids)}"
            used_ids.add(bid)

        registry.append(
            {
                "id": bid,
                "status": "confirmed" if bid else "proposed",
                "kind": b["kind"],
                "section": section_at(sections, b["start"]),
                "line": line_of(clean, b["start"]),
                "label": label,
                "scope": scope_m.group(1) if scope_m else None,
                "term": term_m.group(1) if term_m else None,
                "has_proof": b["proof"] is not None,
                "proof_line": line_of(clean, b["proof"]["start"]) if b["proof"] else None,
                "body_hash": digest,
                "body_length": len(body_norm),
                "facets": {
                    "informal_statement": {"hash": digest},
                    "informal_proof": (
                        {"hash": proof_hash, "anchor": proof_anchor}
                        if proof_hash
                        else None
                    ),
                    "explanation": explanation,
                },
            }
        )
    return registry


# --- Symbols ----------------------------------------------------------------


def collect_symbols(preamble: str):
    """Best-effort symbol/macro registry from the preamble."""
    symbols = []
    patterns = [
        ("newcommand", re.compile(
            r"\\(new|provide|renew)command\*?\s*\{?\\([A-Za-z@]+)\}?"
            r"\s*((?:\[[^\]]*\]){0,2})\s*\{((?:[^{}]|\{(?:[^{}]|\{[^{}]*\})*\})*)\}"
        )),
        ("mathoperator", re.compile(
            r"\\DeclareMathOperator\*?\s*\{?\\([A-Za-z@]+)\}?\s*"
            r"\{((?:[^{}]|\{[^{}]*\})*)\}"
        )),
        ("savedbox", re.compile(r"\\savebox\s*\{\\([A-Za-z@]+)\}\s*\{")),
        ("newsavebox", re.compile(r"\\newsavebox\s*\{\\([A-Za-z@]+)\}")),
        ("newdir", re.compile(r"\\newdir\s*\{([^}]*)\}\s*\{")),
    ]
    for m in patterns[0][1].finditer(preamble):
        symbols.append(
            {
                "name": m.group(2),
                "kind": m.group(1) + "command",
                "arity": m.group(3),
                "definition": m.group(4).strip(),
                "defining_block": "<preamble>",
                "lean": None,
            }
        )
    for m in patterns[1][1].finditer(preamble):
        symbols.append(
            {
                "name": m.group(1),
                "kind": "DeclareMathOperator",
                "arity": "",
                "definition": m.group(2).strip(),
                "defining_block": "<preamble>",
                "lean": None,
            }
        )
    for kind, pat in patterns[2:]:
        for m in pat.finditer(preamble):
            symbols.append(
                {
                    "name": m.group(1),
                    "kind": kind,
                    "arity": "",
                    "definition": "",
                    "defining_block": "<preamble>",
                    "lean": None,
                }
            )
    # Deduplicate by name, keeping the first (most specific) record.
    seen = {}
    for s in symbols:
        seen.setdefault(s["name"], s)
    return sorted(seen.values(), key=lambda s: s["name"])


def collect_theorems(preamble: str):
    """Record the \\newtheorem declarations as part of the source inventory."""
    out = []
    pat = re.compile(
        r"\\newtheorem\{?\*?\}?\s*\{([^}]*)\}\s*(?:\[([^\]]*)\])?\s*\{([^}]*)\}"
        r"\s*(?:\[([^\]]*)\])?"
    )
    for m in pat.finditer(preamble):
        out.append(
            {
                "env": m.group(1),
                "counter": m.group(2) or "own",
                "title": m.group(3).strip(),
                "within": m.group(4) or None,
            }
        )
    return out


# --- Dependency graph -------------------------------------------------------


def parse_aux(aux_path):
    """label -> theorem number, from a LaTeX .aux file (optional)."""
    if not aux_path or not Path(aux_path).exists():
        return {}
    text = Path(aux_path).read_text(encoding="latin1", errors="replace")
    return {m.group(1): m.group(2) for m in NEWLABEL_RE.finditer(text)}


def load_decisions(path):
    """Load ``blocks/edge_decisions.json`` -> {from|to|kind: decision}."""
    if not path or not Path(path).exists():
        return {}
    doc = json.loads(Path(path).read_text(encoding="utf-8"))
    return doc.get("decisions", doc)


def load_notation_resolutions(path):
    """Load ``blocks/notation.json`` -> {identity: resolution entry}."""
    if not path or not Path(path).exists():
        return {}
    doc = json.loads(Path(path).read_text(encoding="utf-8"))
    return doc.get("resolutions", doc)


# --- Notation identities (Architecture.md Section 12.1) ---------------------

# A notation identity is the full compound form: a ``\mathrm{...}`` base plus a
# chain of ``\mathrm{...}`` subscript qualifiers (``\mathrm{Sub}_{\mathrm{f}}``
# -> ``Sub_f``), or a bare macro (``\delta``, ``\Omega``).  A qualifier is part
# of the identity, never a standalone token, so a base and its qualified form are
# distinct and subscript letters (``f``, ``fi``) cannot become phantom tokens.
# A definition owns a notation only when it introduces it as a definee, not when
# it merely mentions it.

_MATHBF_RE = re.compile(r"\\mathrm\{")
_MACRO_NOTATION_RE = re.compile(r"\\(delta|Omega|nabla|Delta|Theta|Lambda)\b")

_INTRO_VERB_RE = re.compile(r"\b(denote[sd]?|call(?:ed|s)?|write[s]?|stand(?:s)?)\b", re.I)
_DEFINEE_BEFORE_RE = re.compile(
    r"(?:denote[sd]?|call(?:ed|s)?|write[s]?)\s+by\s*$"
    r"|(?:denote[sd]?|call(?:ed|s)?|write[s]?)\s*$"
    r"|and\s+by\s*$",
    re.I,
)
_DEFINEE_AFTER_RE = re.compile(r"^(?:stands?\s+for|denotes?)\b", re.I)


def _subscript_end(text, pos):
    """End offset of the balanced ``{...}`` group opening at ``pos``, or None."""
    if pos >= len(text) or text[pos] != "{":
        return None
    depth = 0
    for i in range(pos, len(text)):
        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
            if depth == 0:
                return i + 1
    return None


def _letters(text):
    return re.sub(r"[^A-Za-z]", "", text)


class NotationError(ValueError):
    """A notation declaration that cannot be parsed (fail closed)."""


def _qualifier_identity(inner):
    """Identity of a subscript's content, or "" when it is not a name.

    ``\\mathrm{Lang_{r}}`` -> ``Lang_r``; ``\\mathrm{Cgr}_{\\mathrm{fi}}`` ->
    ``Cgr_fi``; a bare letter run (``f``, ``r``) is itself; an argument-like
    command subscript (``\\Sigma``, ``\\mathbf{A}``) is not part of the identity.
    """
    inner = inner.strip()
    if inner.startswith("\\mathrm{"):
        identity, end = _mathrm_identity(inner, 0)
        if end == len(inner):
            return identity
    if re.fullmatch(r"[A-Za-z]{1,24}", inner):
        return inner
    return ""


def _content_identity(content):
    """Identity from a ``\\mathrm{...}`` brace content, folding subscripts."""
    idx = content.find("_")
    if idx == -1:
        return _letters(content)
    identity = _letters(content[:idx])
    i = idx
    while i < len(content):
        if content[i] == "_" and i + 1 < len(content) and content[i + 1] == "{":
            close = _subscript_end(content, i + 1)
            if close is None:
                break
            qualifier = _qualifier_identity(content[i + 2 : close - 1])
            if qualifier:
                identity = f"{identity}_{qualifier}"
            i = close
        else:
            i += 1
    return identity


def _mathrm_identity(text, pos):
    """Identity and end offset of the ``\\mathrm{...}`` beginning at ``pos``.

    Fails closed: an unbalanced declaration raises ``NotationError`` rather than
    yielding a partial notation map.
    """
    close = _subscript_end(text, pos + len("\\mathrm"))
    if close is None:
        raise NotationError(f"unbalanced \\mathrm declaration at offset {pos}")
    identity = _content_identity(text[pos + len("\\mathrm{") : close - 1])
    end = close
    n = len(text)
    while True:
        j = end
        while j < n and text[j] in " \t\n":
            j += 1
        if j < n and text[j] == "_" and j + 1 < n and text[j + 1] == "{":
            sub_close = _subscript_end(text, j + 1)
            if sub_close is None:
                raise NotationError(f"unbalanced subscript at offset {j}")
            qualifier = _qualifier_identity(text[j + 2 : sub_close - 1])
            if qualifier:
                identity = f"{identity}_{qualifier}"
            end = sub_close
            continue
        break
    return identity, end


def parse_notations(text):
    """Ordered ``[(identity, start, end)]`` compound notation occurrences.

    ``\\mathrm{X}_{\\mathrm{Y}}`` is the single identity ``X_Y``; the qualifier
    is consumed with the base, so it is never emitted on its own.  Nesting such
    as ``\\mathrm{Form}_{\\mathrm{Lang_{r}}}`` folds to ``Form_Lang_r``.
    """
    out = []
    i, n = 0, len(text)
    while i < n:
        m = _MATHBF_RE.search(text, i)
        macro = _MACRO_NOTATION_RE.search(text, i)
        if m is None and macro is None:
            break
        if macro is None or (m is not None and m.start() <= macro.start()):
            identity, end = _mathrm_identity(text, m.start())
            start = m.start()
        else:
            identity, end = macro.group(1), macro.end()
            start = macro.start()
        if identity:
            out.append((identity, start, end))
        i = max(end, start + 1)
    return out


def _clean_window(text):
    text = re.sub(r"\\[A-Za-z]+", " ", text)
    text = re.sub(r"\\[^A-Za-z]", " ", text)
    text = re.sub(r"[^A-Za-z\s]", " ", text)
    return re.sub(r"\s+", " ", text).strip()


def _definee_after(body, end):
    """Text after the notation, skipping a parenthesised argument.

    ``\\mathrm{H}(\\mathcal{F})$ stands for`` must read ``stands for``; the
    argument between the definee and the cue is not part of the check.
    """
    j = end
    if j < len(body) and body[j] == "(":
        depth = 0
        for k in range(j, len(body)):
            if body[k] == "(":
                depth += 1
            elif body[k] == ")":
                depth -= 1
                if depth == 0:
                    j = k + 1
                    break
    return _clean_window(body[j : j + 40])


def _sentence_bounds(body, pos):
    start = 0
    for m in re.finditer(r"[.!?]\s", body[:pos]):
        start = m.end()
    m = re.search(r"[.!?](?:\s|$)", body[pos:])
    return start, pos + m.end() if m else len(body)


def is_definee(body, start, end):
    """True when the notation at ``[start,end)`` is introduced, not mentioned.

    An introduction places the definee next to a cue: after ``denote by`` /
    ``call`` / ``write`` / a coordinated ``and by``, or before ``stands for``.
    The cue must sit in the same sentence and the notation adjacent to it; a
    mention elsewhere in the sentence -- or a non-introduction passive such as
    ``determined by`` -- is not an introduction.
    """
    s0, s1 = _sentence_bounds(body, start)
    if not _INTRO_VERB_RE.search(body[s0:s1]):
        return False
    before = _clean_window(body[max(0, start - 48) : start])
    after = _definee_after(body, end)
    return bool(_DEFINEE_BEFORE_RE.search(before) or _DEFINEE_AFTER_RE.match(after))


def notation_owners(registry, bodies):
    """identity -> sorted defining blocks that *introduce* it (definees only)."""
    by_id = {b["id"]: b for b in registry if b["id"]}
    owners = {}
    for bid, (body, _proof) in bodies.items():
        if by_id.get(bid, {}).get("kind") != "definition":
            continue
        for identity, start, end in parse_notations(body):
            if is_definee(body, start, end):
                owners.setdefault(identity, set()).add(bid)
    return {k: sorted(v) for k, v in owners.items()}


def notation_term_owners(registry, bodies):
    """identity -> sorted defining blocks whose stated term matches the base.

    Fallback for an introduction phrased with a term rather than a definee cue
    (``delta of Kronecker in`` for ``\\delta``).
    """
    by_id = {b["id"]: b for b in registry if b["id"]}
    owners = {}
    for bid, (body, _proof) in bodies.items():
        b = by_id.get(bid, {})
        if b.get("kind") != "definition" or not b.get("term"):
            continue
        for identity, _start, _end in parse_notations(body):
            if _term_matches(identity.split("_", 1)[0], b["term"]):
                owners.setdefault(identity, set()).add(bid)
    return {k: sorted(v) for k, v in owners.items()}


def resolve_notations(registry, bodies, resolutions=None, identities=None):
    """Resolve notation identities: store first, then mechanical, else none.

    Returns ``{identity: {state, target, owners, term_owners}}`` with ``state``
    one of ``block``, ``ambient`` or ``unresolved``.  A recorded resolution wins,
    so an author can override the heuristic; otherwise an identity with exactly
    one introducer resolves to it (term-match as fallback), and anything else is
    left unresolved and reportable rather than assigned a default owner.
    """
    resolutions = resolutions or {}
    intro = notation_owners(registry, bodies)
    term = notation_term_owners(registry, bodies)
    pool = set(identities) if identities is not None else (set(intro) | set(term))
    out = {}
    for identity in sorted(pool):
        entry = resolutions.get(identity)
        kind = entry.get("resolution") if isinstance(entry, dict) else entry
        if kind in ("block", "ambient"):
            out[identity] = {
                "state": kind,
                "target": entry.get("target") if kind == "block" else None,
                "owners": intro.get(identity, []),
                "term_owners": term.get(identity, []),
            }
            continue
        owners = intro.get(identity, [])
        if len(owners) == 1:
            out[identity] = {"state": "block", "target": owners[0],
                             "owners": owners, "term_owners": term.get(identity, [])}
        elif not owners and len(term.get(identity, [])) == 1:
            out[identity] = {"state": "block", "target": term[identity][0],
                             "owners": [], "term_owners": term[identity]}
        else:
            out[identity] = {"state": "unresolved", "target": None,
                             "owners": owners or term.get(identity, []),
                             "term_owners": term.get(identity, [])}
    return out


def edges_for(clean, registry, aux_numbers, decisions=None, notation_resolutions=None):
    """Compute candidate dependency edges from statements *and* proofs.

    Sources (Architecture.md Section 12.1):
      * ``explicit``  -- ``\\uses{...}`` and ``\\ref{...}`` to a labelled block;
      * ``prose``     -- a number-cited environment ("Proposition 3.2");
      * ``symbol``    -- reuse of a compound notation identity introduced by a
        definition, resolved through ``blocks/notation.json`` first and the
        mechanical introducer heuristic otherwise.

    ``decisions`` (from ``blocks/edge_decisions.json``) carries author/agent
    confirmations and rejections keyed ``from|to|kind``.  A confirmed edge is
    emitted with ``confirmed: true``; a rejected edge is dropped; an undecided
    edge is emitted with ``confirmed: false``.
    """
    decisions = decisions or {}
    notation_resolutions = notation_resolutions or {}
    instances = collect_env_instances(clean)

    # id -> (statement body, proof body or "")
    bodies = {}
    for b in instances:
        bid = preceding_blockid(clean, b["start"])
        if bid:
            bodies[bid] = (
                b["body"],
                b["proof"]["body"] if b["proof"] else "",
            )

    label_to_block = {
        b["label"]: b["id"] for b in registry if b["label"] and b["id"]
    }
    number_to_block = {}
    for b in registry:
        if b["label"] and b["label"] in aux_numbers:
            number_to_block[aux_numbers[b["label"]]] = b["id"]

    # Notation resolution: the compound-identity store (``blocks/notation.json``)
    # wins over the mechanical introducer/term-match heuristic.  A resolved
    # identity yields symbol edges; an ``ambient`` identity yields none; an
    # unresolved identity yields none and is reported with its candidate owners
    # and the blocks that use it.
    symbol_uses = {
        bid: sorted(
            {ident for ident, _s, _e in parse_notations(body + "\n" + proof)}
        )
        for bid, (body, proof) in bodies.items()
    }
    used_ids = {ident for idents in symbol_uses.values() for ident in idents}
    notation_state = resolve_notations(
        registry, bodies, notation_resolutions, identities=used_ids
    )
    for entry in notation_state.values():
        entry["uses"] = []

    edges = []
    seen = set()

    def add_edge(src, dst, kind, source, detail=""):
        if not src or not dst or src == dst:
            return
        key = (src, dst, kind)
        if key in seen:
            return
        seen.add(key)
        decision = decisions.get(f"{src}|{dst}|{kind}")
        if decision is not None and not decision.get("confirmed", False):
            return  # remembered rejection: do not re-propose
        edges.append(
            {
                "from": src,
                "to": dst,
                "kind": kind,
                "source": source,
                "confirmed": bool(decision and decision.get("confirmed")),
                "detail": detail,
            }
        )

    for bid, (body, proof) in bodies.items():
        text = body + "\n" + proof
        # explicit \uses
        for m in USES_RE.finditer(text):
            for target in re.split(r"[,\s]+", m.group(1).strip()):
                tid = label_to_block.get(target, target if target.startswith("B-") else None)
                add_edge(bid, tid, "uses_statement", "explicit", f"\\uses{{{target}}}")
        # \ref / \cref
        for m in REF_RE.finditer(text):
            target = m.group(1)
            tid = label_to_block.get(target)
            if tid:
                kind = "uses_definition" if registry_kind(registry, tid) == "definition" else "uses_statement"
                add_edge(bid, tid, kind, "explicit", f"\\ref{{{target}}}")
        # prose number citations
        for m in PROSE_NUM_RE.finditer(text):
            number = m.group(2)
            tid = number_to_block.get(number)
            if tid:
                add_edge(
                    bid,
                    tid,
                    "uses_statement",
                    "prose",
                    f"prose {m.group(1)} {number}",
                )
        # symbol usage (compound notation identities)
        for ident in symbol_uses.get(bid, []):
            entry = notation_state.get(ident)
            if entry is None or entry["state"] == "ambient":
                continue
            if bid not in entry["uses"]:
                entry["uses"].append(bid)
            if entry["state"] == "block":
                add_edge(
                    bid, entry["target"], "uses_definition", "symbol", f"\\{ident}"
                )

    # Confirmed edges the extractor did not propose (recorded manually).
    for key, dec in decisions.items():
        if not dec.get("confirmed"):
            continue
        parts = key.split("|")
        if len(parts) != 3:
            continue
        src, dst, kind = parts
        if (src, dst, kind) not in seen:
            seen.add((src, dst, kind))
            edges.append(
                {
                    "from": src,
                    "to": dst,
                    "kind": kind,
                    "source": dec.get("source", "manual"),
                    "confirmed": True,
                    "detail": dec.get("rationale", "confirmed manually"),
                }
            )
    return (
        edges,
        bodies,
        label_to_block,
        number_to_block,
        symbol_uses,
        notation_state,
    )


def registry_kind(registry, bid):
    for b in registry:
        if b["id"] == bid:
            return b["kind"]
    return None


def _term_matches(token, term):
    """True if a notation token matches a definition's stated term.

    The token must equal a term word (ignoring a trailing plural ``s``) or be a
    prefix of one of length >= 4, so short substring coincidences such as
    ``alg`` inside ``algebras`` do not count.
    """
    token = token.lower()
    for word in re.findall(r"[A-Za-z]+", term or ""):
        word = word.lower().rstrip("s")
        if token == word or (len(token) >= 4 and word.startswith(token)):
            return True
    return False


# --- Reports ----------------------------------------------------------------


def inventory_report(path, clean, preamble, sections, registry, symbols, theorems):
    kinds = {}
    for b in registry:
        kinds[b["kind"]] = kinds.get(b["kind"], 0) + 1
    confirmed = sum(1 for b in registry if b["status"] == "confirmed")
    proposed = len(registry) - confirmed
    lines = [
        "# Source inventory\n",
        f"Source: `{path}` ({len(clean)} chars, {clean.count(chr(10)) + 1} lines, latin1)\n",
        "## Sections\n",
    ]
    for _start, title in sections:
        lines.append(f"- {title}")
    lines += [
        "\n## Theorem-like environments\n",
        "| kind | count |",
        "|---|---|",
    ]
    for k in sorted(kinds):
        lines.append(f"| {k} | {kinds[k]} |")
    lines += [
        f"\nBlocks with a `\\blockid`: **{confirmed}** confirmed, "
        f"**{proposed}** proposed (no id).\n",
        "## Theorem declarations\n",
        "| env | counter | title | within |",
        "|---|---|---|---|",
    ]
    for t in theorems:
        lines.append(
            f"| {t['env']} | {t['counter']} | {t['title']} | {t['within'] or ''} |"
        )
    lines += [
        f"\n## Symbol registry\n",
        f"{len(symbols)} preamble macros/notations. See `blocks/symbols.json`.\n",
    ]
    return "\n".join(lines) + "\n"


def gap_report(path, clean, registry, edges, label_to_block, undefined_refs, notation_state=None):
    notation_state = notation_state or {}
    confirmed = [b for b in registry if b["status"] == "confirmed"]
    no_scope = [b for b in confirmed if not b["scope"]]
    no_label = [b for b in confirmed if not b["label"]]
    expected_proof = [b for b in confirmed if b["kind"] in PROOF_EXPECTED]
    no_proof = [b for b in expected_proof if not b["has_proof"]]
    unannotated = [b for b in registry if b["status"] == "proposed"]

    from collections import Counter

    outdeg = Counter(e["from"] for e in edges)
    indeg = Counter(e["to"] for e in edges)
    isolated = [
        b["id"] for b in confirmed if outdeg[b["id"]] == 0 and indeg[b["id"]] == 0
    ]

    lines = [
        "# Gap report\n",
        f"Generated by `scripts/ingest.py` from `{path}`.\n",
        "## 1. Theorem-like environments with no `\\blockid`\n",
        f"{len(unannotated)} environment(s). No ID is minted here "
        "(Architecture.md Section 16.4); these are proposals only.\n",
        "| kind | line | first term |",
        "|---|---|---|",
    ]
    for b in unannotated:
        lines.append(f"| {b['kind']} | {b['line']} | {b['term'] or ''} |")
    lines += [
        "\n## 2. Blocks with no `\\blockscope`\n",
        f"{len(no_scope)} of {len(confirmed)} confirmed blocks declare no scope.\n",
        "\n## 3. Blocks with no `\\label` (not citable by `\\ref`)\n",
        f"{len(no_label)} confirmed block(s).\n",
        "| id | kind | line | term |",
        "|---|---|---|---|",
    ]
    for b in no_label:
        lines.append(f"| {b['id']} | {b['kind']} | {b['line']} | {b['term'] or ''} |")
    lines += [
        "\n## 4. Proof-expected blocks with no following proof\n",
        f"{len(no_proof)} of {len(expected_proof)} proof-expected block(s) "
        "(candidate `M-gap` / omitted-proof blocks; Section 11a.5).\n",
        "| id | kind | line | label | term |",
        "|---|---|---|---|---|",
    ]
    for b in no_proof:
        lines.append(
            f"| {b['id']} | {b['kind']} | {b['line']} | {b['label'] or ''} | {b['term'] or ''} |"
        )
    lines += [
        "\n## 5. Undefined `\\ref` targets\n",
        f"{len(undefined_refs)} target(s).\n",
    ]
    for t in sorted(undefined_refs):
        lines.append(f"- `{t}`")
    lines += [
        "\n## 6. Blocks with no detected dependency edges\n",
        f"{len(isolated)} isolated block(s) (no candidate in- or out-edge). "
        "Extraction is incomplete -- symbol-usage and full prose-name detection "
        "are only heuristically seeded (Section 12.1) -- so absence of an edge "
        "is not evidence of independence.\n",
    ]
    for bid in sorted(isolated):
        lines.append(f"- `{bid}`")
    lines += [
        "\n## 7. Notation resolution\n",
        "A compound notation identity (base plus subscript chain) is owned by "
        "the definition that introduces it (Section 12.1). A resolved identity "
        "yields symbol edges; an `ambient` identity yields none; an unresolved "
        "identity yields none and is listed here rather than silently dropped. "
        "Resolutions live in `blocks/notation.json` (author-reserved).\n",
    ]
    notation_state = notation_state or {}
    resolved = sorted(i for i, st in notation_state.items() if st["state"] == "block")
    ambient = sorted(i for i, st in notation_state.items() if st["state"] == "ambient")
    unresolved = sorted(
        i for i, st in notation_state.items() if st["state"] == "unresolved"
    )
    with_owners = [i for i in unresolved if notation_state[i]["owners"]]
    ownerless = [i for i in unresolved if not notation_state[i]["owners"]]
    lines += [
        f"- resolved to a defining block: {len(resolved)}",
        f"- ambient: {len(ambient)}",
        f"- unresolved: {len(unresolved)} ({len(with_owners)} with candidate "
        "owners, resolved by the author via `blocks/notation.json`)\n",
        "| notation | candidate owners | uses | candidate edges |",
        "|---|---|---|---|",
    ]
    for ident in with_owners:
        st = notation_state[ident]
        owners = ", ".join(f"`{o}`" for o in st["owners"])
        lines.append(f"| `\\{ident}` | {owners} | {len(st['uses'])} | {len(st['uses'])} |")
    if not with_owners:
        lines.append("| _none_ | | | |")
    lines += [
        "\nNotation identities with no candidate owner (not introduced by any "
        "definition, so no edge is expected): "
        + (", ".join(f"`\\{i}`" for i in ownerless) if ownerless else "_none_")
        + "\n",
    ]
    return "\n".join(lines) + "\n"


def pilot_report(registry, edges, max_closure=12):
    """Propose pilot milestones: dependency-closed sets around a target block.

    A milestone is `target` plus the *upstream* closure (everything the target
    depends on, recursively), which is the set that must be formalized first.
    We rank proof-bearing statements by closure size so the pilot is small, and
    also list the most-referenced definitions (the likely encoding-sensitive
    core).  Candidate edges only; author confirmation is required.
    """
    by_id = {b["id"]: b for b in registry if b["id"]}
    deps = {}
    indeg = {}
    for e in edges:
        deps.setdefault(e["from"], set()).add(e["to"])
        indeg[e["to"]] = indeg.get(e["to"], 0) + 1

    def upstream(seed):
        seen, stack = set(), [seed]
        while stack:
            cur = stack.pop()
            for nxt in deps.get(cur, ()):
                if nxt not in seen and nxt != seed:
                    seen.add(nxt)
                    stack.append(nxt)
        return seen

    targets = [
        b
        for b in registry
        if b["status"] == "confirmed"
        and b["kind"] in ("proposition", "corollary", "lemma", "theorem")
    ]
    scored = []
    for t in targets:
        up = upstream(t["id"])
        scored.append((len(up), t["id"], sorted(up)))
    scored.sort()

    top_defs = sorted(
        (b for b in registry if b["status"] == "confirmed" and b["kind"] == "definition"),
        key=lambda b: (-indeg.get(b["id"], 0), b["id"]),
    )[:10]

    lines = [
        "# Suggested pilot milestone\n",
        "Generated from the dependency edges in `blocks/graph.json`; "
        "confirmations/rejections live in `blocks/edge_decisions.json` "
        "(Architecture.md Sections 12.1, 14, 21 Phase 0).\n",
        "## A. Smallest dependency-closed targets\n",
        "A target plus its transitive upstream closure (its dependencies). "
        "Pick one to hand-build the Phase-0 vertical slice.\n",
    ]
    shown = 0
    for size, tid, up in scored:
        if size < 1 or size > max_closure:
            continue
        b = by_id.get(tid, {})
        members = [tid] + up
        defs = [m for m in members if by_id.get(m, {}).get("kind") == "definition"]
        lines += [
            f"\n### `{tid}` — {b.get('kind')} (closure size {size + 1})\n",
            f"- {b.get('section', '')} (line {b.get('line', '?')})",
            f"- definitions in closure: {', '.join('`'+d+'`' for d in defs) or 'none'}",
            f"- members: {', '.join('`'+m+'`' for m in members)}",
        ]
        shown += 1
        if shown >= 6:
            break
    if shown == 0:
        lines.append("\n_No target has a nonempty closure within the size cap._\n")

    lines += [
        "\n## B. Most-referenced definitions (encoding-sensitive core)\n",
        "In-degree counts candidate incoming edges; high in-degree means a "
        "change here has the largest blast radius.\n",
        "| id | term | in-degree |",
        "|---|---|---|",
    ]
    for b in top_defs:
        lines.append(
            f"| {b['id']} | {b.get('term') or ''} | {indeg.get(b['id'], 0)} |"
        )
    lines += [
        "\n---\n",
        "Known limitation: only `\\ref`/`\\uses`, number-cited prose, and a "
        "definition-cue notation extractor seed edges. Symbol and prose-name "
        "coverage is still incomplete (Architecture.md Section 12.1), so real "
        "closures are probably larger.\n",
    ]
    return "\n".join(lines) + "\n"


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("file", help="main TeX source (latin1)")
    ap.add_argument("--aux", help="optional .aux file for prose-number resolution")
    ap.add_argument(
        "--decisions",
        help="edge decisions JSON (default blocks/edge_decisions.json if present)",
    )
    ap.add_argument(
        "--notation",
        help="notation resolutions JSON (default blocks/notation.json if present)",
    )
    ap.add_argument("--dry-run", action="store_true", help="do not write artifacts")
    ap.add_argument(
        "--check",
        action="store_true",
        help="verify committed artifacts are up to date; do not write; exit 1 on drift",
    )
    args = ap.parse_args(argv)

    path = Path(args.file)
    root = path.resolve().parent.parent
    decisions_path = args.decisions or str(root / "blocks" / "edge_decisions.json")
    notation_path = args.notation or str(root / "blocks" / "notation.json")

    def rel(p):
        try:
            return str(Path(p).resolve().relative_to(root))
        except ValueError:
            return str(p)

    src_rel = rel(path)
    decisions_rel = rel(decisions_path)
    text = path.read_text(encoding="latin1")
    clean = hb.strip_comments(text)
    preamble = clean.split("\\begin{document}", 1)[0]
    sections = [(m.start(), m.group(1).strip()) for m in SECTION_RE.finditer(clean)]

    registry = collect_blocks(clean, sections, explanations_dir=root / "blocks" / "explanations")
    symbols = collect_symbols(preamble)
    theorems = collect_theorems(preamble)
    aux_numbers = parse_aux(args.aux)
    decisions = load_decisions(decisions_path)
    resolutions = load_notation_resolutions(notation_path)
    try:
        (
            edges,
            bodies,
            label_to_block,
            number_to_block,
            symbol_uses,
            notation_state,
        ) = edges_for(clean, registry, aux_numbers, decisions, resolutions)
    except NotationError as exc:
        print(f"ingest: notation parse error: {exc}", file=sys.stderr)
        return 1

    # Undefined refs: every \ref target with no \label definition anywhere.
    all_labels = set(LABEL_RE.findall(clean))
    undefined_refs = {
        m.group(1) for m in REF_RE.finditer(clean) if m.group(1) not in all_labels
    }

    registry_doc = {
        "source": src_rel,
        "blocks": registry,
        "counts": {
            "confirmed": sum(1 for b in registry if b["status"] == "confirmed"),
            "proposed": sum(1 for b in registry if b["status"] == "proposed"),
        },
    }
    graph_doc = {
        "source": src_rel,
        "note": "candidate edges; confirmed=false means awaiting author confirmation",
        "decisions_source": decisions_rel,
        "labels": label_to_block,
        "numbers": number_to_block,
        "symbols_used": symbol_uses,
        "ambiguous_symbols": {
            ident: st["owners"]
            for ident, st in notation_state.items()
            if st["state"] == "unresolved"
        },
        "edges": edges,
    }
    symbols_doc = {
        "source": src_rel,
        "symbols": symbols,
        "notations": [
            {
                "identity": ident,
                "state": st["state"],
                "target": st["target"],
                "owners": st["owners"],
                "uses": len(st["uses"]),
                "candidate_edges": (
                    len(st["uses"]) if st["state"] == "unresolved" else 0
                ),
            }
            for ident, st in sorted(notation_state.items())
        ],
    }
    gap_text = gap_report(
        path, clean, registry, edges, label_to_block, undefined_refs, notation_state
    )

    if args.dry_run:
        nconf = sum(1 for e in edges if e["confirmed"])
        nresolve = sum(1 for st in notation_state.values() if st["state"] == "block")
        print(
            f"ingest: {registry_doc['counts']['confirmed']} confirmed, "
            f"{registry_doc['counts']['proposed']} proposed blocks; "
            f"{len(symbols)} symbols; {len(edges)} edges "
            f"({nconf} confirmed); {len(notation_state)} notation identities "
            f"({nresolve} resolved); {len(undefined_refs)} undefined refs (dry run)"
        )
        return 0

    if args.check:
        drift = 0
        for target, doc in (
            (root / "blocks" / "registry.json", registry_doc),
            (root / "blocks" / "symbols.json", symbols_doc),
            (root / "blocks" / "graph.json", graph_doc),
        ):
            expected = json.dumps(doc, indent=2, sort_keys=True) + "\n"
            existing = target.read_text(encoding="utf-8") if target.exists() else None
            if existing != expected:
                print(f"ingest --check: DRIFT in {target.relative_to(root)}", file=sys.stderr)
                drift += 1
        gap_target = root / "reports" / "gap_report.md"
        if (gap_target.read_text(encoding="utf-8") if gap_target.exists() else None) != gap_text:
            print(f"ingest --check: DRIFT in {gap_target.relative_to(root)}", file=sys.stderr)
            drift += 1
        if drift:
            return 1
        print(
            "ingest --check: registry, symbols, graph, gap report are up to date",
            file=sys.stderr,
        )
        return 0

    (root / "blocks").mkdir(exist_ok=True)
    (root / "reports").mkdir(exist_ok=True)
    (root / "blocks" / "registry.json").write_text(
        json.dumps(registry_doc, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    (root / "blocks" / "symbols.json").write_text(
        json.dumps(symbols_doc, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    (root / "blocks" / "graph.json").write_text(
        json.dumps(graph_doc, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    (root / "reports" / "inventory.md").write_text(
        inventory_report(path, clean, preamble, sections, registry, symbols, theorems),
        encoding="utf-8",
    )
    (root / "reports" / "gap_report.md").write_text(gap_text, encoding="utf-8")
    (root / "reports" / "pilot_candidates.md").write_text(
        pilot_report(registry, edges), encoding="utf-8"
    )

    print(
        f"ingest: wrote registry ({registry_doc['counts']['confirmed']} confirmed, "
        f"{registry_doc['counts']['proposed']} proposed), {len(symbols)} symbols, "
        f"{len(edges)} candidate edges"
    )
    print(
        f"ingest: wrote reports/inventory.md, reports/gap_report.md, "
        f"reports/pilot_candidates.md"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
