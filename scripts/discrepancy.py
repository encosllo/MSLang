#!/usr/bin/env python3
"""Graph discrepancy report (Architecture.md Sections 12.2, 19).

Two dependency graphs exist: the informal one (``blocks/graph.json``, confirmed
`uses_statement`/`uses_definition` edges) and the formal one
(``blocks/formal_graph.json``, `formal_uses`). Their differences are the
concrete mechanism behind "formalization improves the mathematics":

* a **formal-only** edge -- a formal proof uses a fact the informal proof does
  not cite: a possible hidden dependency or unstated step;
* an **informal-only** edge (both endpoints mapped) -- the informal text cites a
  block the formal proof never uses: a possible superfluous hypothesis or an
  argument that can be simplified.

Every row carries a *disposition* (Section 12.2): a typed review verdict drawn
from ``blocks/discrepancy_decisions.json``, or a documented default for a
structural pattern (an edge whose target is the type carrier). The report
enumerates only **undecided** rows and collapses default-classified rows into
counts, so the review queue is countable. A disposition is not an evidence
record and changes no layer status.

Only blocks with a formal counterpart (the mapped universe) are compared;
unmapped informal edges are reported separately as "not yet mapped".

Usage:
    python3 scripts/discrepancy.py
    python3 scripts/discrepancy.py --report
    python3 scripts/discrepancy.py --check-report
    python3 scripts/discrepancy.py --check-dispositions
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEPENDENCY_KINDS = {"uses_statement", "uses_definition"}
REPORT = ROOT / "reports" / "discrepancy.md"
DISPOSITIONS = {
    "real-hidden-dependency",
    "type-carrier",
    "simplification",
    "expected",
    "corrected",
}
# Structural patterns with a known benign class (Section 12.2). An edge whose
# target is the S-sorted-set carrier is a type-carrier edge: the Lean signature
# mentions the type while the prose names it.
CARRIER_TARGETS = {"B-D002"}


def load_edges(path, kinds=None):
    doc = json.loads(Path(path).read_text(encoding="utf-8"))
    out = []
    for e in doc.get("edges", []):
        if kinds and e.get("kind") not in kinds:
            continue
        if e.get("confirmed") is False:
            continue
        out.append((e["from"], e["to"]))
    return out


def compare(informal, formal):
    universe = {b for e in formal for b in e}
    fset = set(formal)
    iset = {(a, b) for (a, b) in informal if a in universe and b in universe}
    unmapped = sorted({(a, b) for (a, b) in informal if a not in universe or b not in universe})
    return {
        "universe": sorted(universe),
        "formal_only": sorted(fset - iset),
        "informal_only": sorted(iset - fset),
        "agree": sorted(fset & iset),
        "unmapped": unmapped,
    }


def load_decisions(path, legacy_notes=None):
    """Load typed dispositions, migrating legacy free-text notes if needed."""
    decisions = {}
    p = Path(path)
    if p.exists():
        doc = json.loads(p.read_text(encoding="utf-8"))
        decisions = doc.get("dispositions", doc) if isinstance(doc, dict) else doc
    elif legacy_notes and Path(legacy_notes).exists():
        notes = json.loads(Path(legacy_notes).read_text(encoding="utf-8")).get("notes", {})
        for key, note in notes.items():
            decisions[key] = {
                "disposition": "expected",
                "note": note,
                "decided_by": "migrated:discrepancy_notes.json",
            }
    return decisions


def validate_decisions(decisions):
    errors = []
    for key, entry in sorted(decisions.items()):
        if "->" not in key:
            errors.append(f"{key}: key must be FROM->TO")
        value = entry.get("disposition") if isinstance(entry, dict) else entry
        if value not in DISPOSITIONS:
            errors.append(f"{key}: invalid disposition {value!r}")
    return errors


def default_disposition(a, b):
    if b in CARRIER_TARGETS:
        return "type-carrier"
    return None


def disposition_of(a, b, decisions):
    key = f"{a}->{b}"
    entry = decisions.get(key)
    if entry:
        value = entry.get("disposition") if isinstance(entry, dict) else entry
        return value, "recorded"
    value = default_disposition(a, b)
    if value:
        return value, "default"
    return None, "undecided"


def classify(d, decisions):
    """Split every discrepancy row into undecided, default, and reviewed."""
    undecided, defaults, reviewed = [], {}, []
    for a, b in d["formal_only"] + d["informal_only"]:
        value, source = disposition_of(a, b, decisions)
        if source == "undecided":
            undecided.append((a, b))
        elif source == "default":
            defaults[value] = defaults.get(value, 0) + 1
        else:
            reviewed.append((a, b, value))
    return undecided, defaults, reviewed


def render_report(d, decisions=None):
    decisions = decisions or {}
    undecided, defaults, reviewed = classify(d, decisions)
    lines = [
        "# Dependency-graph discrepancy report (Sections 12.2, 19)",
        "",
        "Generated by `scripts/discrepancy.py`. Compared over the blocks with a",
        "formal counterpart (the mapped universe); `formal_uses` edges are",
        "extracted from Lean source, informal edges are confirmed `\\ref`/`\\uses`",
        "and symbol/prose edges.",
        "",
        f"Mapped blocks: {', '.join('`'+b+'`' for b in d['universe']) or 'none'}",
        "",
        f"## Undecided edges ({len(undecided)})",
        "",
        "These rows have neither a recorded disposition nor a default; they are",
        "the review queue.",
        "",
        "| from | to |",
        "|---|---|",
    ]
    for a, b in undecided:
        lines.append(f"| `{a}` | `{b}` |")
    if not undecided:
        lines.append("| _none_ | |")
    lines += [
        "",
        "## Default-classified edges (collapsed)",
        "",
        "| disposition | count |",
        "|---|---|",
    ]
    for value in sorted(defaults):
        lines.append(f"| {value} | {defaults[value]} |")
    if not defaults:
        lines.append("| _none_ | 0 |")
    lines += ["", "## Reviewed dispositions", ""]
    if reviewed:
        for a, b, value in reviewed:
            entry = decisions.get(f"{a}->{b}", {})
            note = entry.get("note", "") if isinstance(entry, dict) else ""
            by = entry.get("decided_by", "") if isinstance(entry, dict) else ""
            suffix = f" ({by})" if by else ""
            lines.append(f"- `{a} -> {b}`: {value}{suffix}. {note}".rstrip())
    else:
        lines.append("- none recorded")
    lines += ["", "## Agreeing edges", "", "| from | to |", "|---|---|"]
    for a, b in d["agree"]:
        lines.append(f"| `{a}` | `{b}` |")
    if not d["agree"]:
        lines.append("| _none_ | |")
    lines += [
        "",
        "## Not yet mapped (informal edges with no formal counterpart)",
        "",
        f"{len(d['unmapped'])} edge(s); these blocks have no Lean declaration in "
        "`lean/declarations.json`, so no formal edge can exist yet.",
        "",
    ]
    return "\n".join(lines)


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("--informal", default=str(ROOT / "blocks" / "graph.json"))
    ap.add_argument("--formal", default=str(ROOT / "blocks" / "formal_graph.json"))
    ap.add_argument("--decisions", default=str(ROOT / "blocks" / "discrepancy_decisions.json"))
    ap.add_argument("--legacy-notes", default=str(ROOT / "blocks" / "discrepancy_notes.json"))
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--report", action="store_true")
    ap.add_argument("--check-report", action="store_true")
    ap.add_argument("--check-dispositions", action="store_true")
    args = ap.parse_args(argv)

    informal = load_edges(args.informal, DEPENDENCY_KINDS)
    formal = load_edges(args.formal)
    d = compare(informal, formal)
    decisions = load_decisions(args.decisions, args.legacy_notes)
    errors = validate_decisions(decisions)

    if args.check_dispositions:
        for e in errors:
            print(f"ERROR {e}")
        if errors:
            return 1
        print(f"discrepancy: {len(decisions)} disposition(s) valid")
        return 0

    undecided, defaults, reviewed = classify(d, decisions)

    if args.json:
        print(json.dumps({
            "undecided": undecided,
            "defaults": defaults,
            "reviewed": reviewed,
        }, indent=2))
        return 0

    print(f"discrepancy over {len(d['universe'])} mapped block(s):")
    print(f"  agree: {len(d['agree'])}  formal-only: {len(d['formal_only'])}  "
          f"informal-only: {len(d['informal_only'])}  unmapped: {len(d['unmapped'])}")
    print(f"  undecided: {len(undecided)}  default-classified: "
          f"{sum(defaults.values())}  reviewed: {len(reviewed)}")

    if args.report or args.check_report:
        text = render_report(d, decisions)
        if args.check_report:
            actual = REPORT.read_text(encoding="utf-8") if REPORT.exists() else None
            if actual != text:
                print(f"discrepancy: report drift in {REPORT.relative_to(ROOT)}")
                return 1
            print("discrepancy: report current")
        else:
            REPORT.parent.mkdir(parents=True, exist_ok=True)
            REPORT.write_text(text, encoding="utf-8")
            print(f"discrepancy: wrote {REPORT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
