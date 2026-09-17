#!/usr/bin/env python3
"""Tests for notation extraction and resolution (Architecture.md Section 12.1).

Run:
    python3 scripts/ingest_test.py
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import hash_blocks as hb  # noqa: E402
import ingest  # noqa: E402

ROOT = HERE.parent
FAILURES = []


def check(name, condition, detail=""):
    print(f"[{'PASS' if condition else 'FAIL'}] {name}" + (f" -- {detail}" if detail and not condition else ""))
    if not condition:
        FAILURES.append(name)


def corpus():
    text = (ROOT / "manuscript" / "MSEilenberg.tex").read_text(encoding="latin1")
    clean = hb.strip_comments(text)
    sections = [(m.start(), m.group(1).strip()) for m in ingest.SECTION_RE.finditer(clean)]
    registry = ingest.collect_blocks(clean, sections)
    return clean, registry


def mini_edges(clean, resolutions=None, decisions=None):
    registry = ingest.collect_blocks(clean, [])
    return ingest.edges_for(clean, registry, {}, decisions or {}, resolutions or {})


MINI = (
    "\\blockid{B-D001}\n"
    "\\begin{definition}\n"
    "We denote by $\\mathrm{Foo}$ the set of foos.\n"
    "\\end{definition}\n"
    "\\blockid{B-D002}\n"
    "\\begin{definition}\n"
    "We denote by $\\mathrm{Foo}$ the other set of foos.\n"
    "\\end{definition}\n"
    "\\blockid{B-P003}\n"
    "\\begin{proposition}\n"
    "Every $\\mathrm{Foo}$ is a bar.\n"
    "\\end{proposition}\n"
)


def main():
    # Compound notation identity.
    ids = {i for i, _s, _e in ingest.parse_notations(
        "\\mathrm{Alg}_{\\mathrm{f}} \\mathrm{Alg} \\mathrm{Cgr}_{\\mathrm{fi}} "
        "\\mathrm{Cgr} \\mathrm{Sub}_{\\mathrm{f}} \\mathrm{Sub} "
        "\\mathrm{Form}_{\\mathrm{Alg}} \\mathrm{Form}_{\\mathrm{Cgr}_{\\mathrm{fi}}}"
    )}
    check("Alg and Alg_f are distinct",
          {"Alg", "Alg_f"} <= ids and "Alg_f" in ids)
    check("Cgr, Cgr_fi, Sub, Sub_f are distinct",
          {"Cgr", "Cgr_fi", "Sub", "Sub_f"} <= ids)
    check("Form compounds are folded and distinct",
          {"Form_Alg", "Form_Cgr_fi"} <= ids)
    check("subscript qualifiers are not standalone tokens",
          "f" not in ids and "fi" not in ids)

    # Introducer detection on the real corpus.
    clean, registry = corpus()
    inst = ingest.collect_env_instances(clean)
    bodies = {}
    for b in inst:
        bid = ingest.preceding_blockid(clean, b["start"])
        if bid:
            bodies[bid] = (b["body"], b["proof"]["body"] if b["proof"] else "")
    intro = ingest.notation_owners(registry, bodies)
    check("Alg is owned by its introducer B-D017", intro.get("Alg") == ["B-D017"], str(intro.get("Alg")))
    check("Alg is not attributed to mere mentions",
          not ({"B-D031", "B-D032", "B-D034", "B-D042", "B-D043"} & set(intro.get("Alg", []))))
    check("Hom is owned by B-D002 only", intro.get("Hom") == ["B-D002"], str(intro.get("Hom")))
    check("Hom mention in the translation definitions is not ownership",
          not ({"B-D035", "B-D036"} & set(intro.get("Hom", []))))
    check("genuine overloads stay ambiguous",
          len(intro.get("Omega", [])) > 1 and len(intro.get("supp_S", [])) > 1)
    check("no phantom subscript tokens on the real corpus",
          "f" not in intro and "fi" not in intro)

    # Determinism.
    again = {i for i, _s, _e in ingest.parse_notations(
        "\\mathrm{Form}_{\\mathrm{Cgr}_{\\mathrm{fi}}} \\mathrm{Alg}_{\\mathrm{f}}"
    )}
    check("parsing is deterministic", again == {"Form_Cgr_fi", "Alg_f"})
    decisions = ingest.load_decisions(ROOT / "blocks" / "edge_decisions.json")
    aux = ingest.parse_aux(ROOT / "manuscript" / "MSEilenberg.aux")
    e1 = ingest.edges_for(clean, registry, aux, decisions, {})[0]
    e2 = ingest.edges_for(clean, registry, aux, decisions, {})[0]
    check("edge extraction is deterministic",
          json.dumps(e1, sort_keys=True) == json.dumps(e2, sort_keys=True))

    # Fail closed.
    try:
        ingest.parse_notations("\\mathrm{Broken")
        check("an unparsable declaration fails closed", False)
    except ingest.NotationError:
        check("an unparsable declaration fails closed", True)

    # Resolution order and staging.
    store_target = {"Foo": {"resolution": "block", "target": "B-D001",
                            "decided_by": "author:test"}}
    edges, _b, _l, _n, _su, state = mini_edges(MINI, store_target)
    foo = [e for e in edges if e["to"] == "B-D001" and e["source"] == "symbol"]
    check("an author resolution wins over the heuristic",
          any(e["from"] == "B-P003" for e in foo), str(edges))
    check("a recovered edge is an unconfirmed candidate",
          all(not e["confirmed"] for e in foo))
    check("the store resolution state is recorded", state["Foo"]["state"] == "block")

    edges, _b, _l, _n, _su, state = mini_edges(
        MINI, {"Foo": {"resolution": "ambient", "target": None, "decided_by": "author:test"}})
    check("an ambient notation yields no symbol edge",
          not [e for e in edges if e["source"] == "symbol"])
    check("the ambient state is recorded", state["Foo"]["state"] == "ambient")

    # Confirmed edges the extractor no longer proposes survive.
    decisions = {"B-P003|B-D002|uses_definition": {"confirmed": True, "source": "symbol"}}
    edges, _b, _l, _n, _su, _st = mini_edges(MINI, None, decisions)
    kept = [e for e in edges if e["from"] == "B-P003" and e["to"] == "B-D002"]
    check("a previously confirmed edge is preserved across reassignment",
          kept and kept[0]["confirmed"], str(edges))

    print()
    if FAILURES:
        print(f"ingest_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("ingest_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
