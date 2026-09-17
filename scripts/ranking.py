#!/usr/bin/env python3
"""Goal-directed ranking of the formalization frontier (Architecture.md
Sections 12.1, 17.1, 19).

Two stages, both advisory:

1. **Goal proposal (reverse rank).** PageRank on the *impact* graph
   (dependency -> user) with restart mass over result-bearing blocks. On a DAG
   this concentrates on sinks, so the shortlist is "the results with the largest
   supporting foundation" - a size proxy, not a value judgement. The author
   designates the goal in ``blocks/ranking.json`` (author-reserved).
2. **Next step (forward rank).** Restricted to the goal's transitive ancestor
   set, PageRank conditioned on the goal; the recommendation is the highest
   ranked prerequisite that is undone and ready. The goal itself is never
   recommended.

The ranking consumes *all* edges (confirmed and candidate), weighted by source
(an author-written citation above extracted symbol usage), minus edges disposed
``type-carrier`` or ``simplification``. It is advisory: it changes no closure,
layer status, or evidence record, and it sets no scope or tier.

Usage:
    python3 scripts/ranking.py --report
    python3 scripts/ranking.py --check-report
    python3 scripts/ranking.py --list
    python3 scripts/ranking.py --check
    python3 scripts/ranking.py --set-goal --block B-P035 \
        --decided-by author:session83 --rationale "second Eilenberg theorem"
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_STORE = ROOT / "blocks" / "ranking.json"
DEFAULT_GRAPH = ROOT / "blocks" / "graph.json"
DEFAULT_REGISTRY = ROOT / "blocks" / "registry.json"
DEFAULT_DISCREPANCY = ROOT / "blocks" / "discrepancy_decisions.json"
DEFAULT_DECLARATIONS = ROOT / "lean" / "declarations.json"
REPORT = ROOT / "reports" / "ranking.md"

RESULT_KINDS = ("theorem", "proposition", "corollary", "lemma")
KIND_SEED = {"theorem": 1.2, "corollary": 1.2, "proposition": 1.0, "lemma": 1.0}
SOURCE_WEIGHT = {"explicit": 1.0, "manual": 1.0, "prose": 0.5, "symbol": 0.3}
DEFAULT_WEIGHT = 0.5
EXCLUDED_DISPOSITIONS = {"type-carrier", "simplification"}
DEPENDENCY_KINDS = {"uses_statement", "uses_definition"}
DAMPING = 0.85
ITERS = 200
SHORTLIST = 12
BLOCK_RE = re.compile(r"^B-[A-Za-z0-9]+$")


# --- Store (author-reserved goal) -------------------------------------------


def load_store(path):
    p = Path(path)
    if not p.exists():
        return {}
    doc = json.loads(p.read_text(encoding="utf-8"))
    return doc.get("goals", doc) if isinstance(doc, dict) else doc


def save_store(path, goals):
    doc = json.loads(Path(path).read_text(encoding="utf-8"))
    doc["goals"] = goals
    Path(path).write_text(json.dumps(doc, indent=2, sort_keys=True) + "\n",
                          encoding="utf-8")


def validate(goals):
    errors = []
    if len(goals) > 1:
        errors.append(f"at most one goal is supported; found {len(goals)}")
    for block, entry in sorted(goals.items()):
        if not BLOCK_RE.match(block):
            errors.append(f"{block}: not a block id")
        if not isinstance(entry, dict):
            errors.append(f"{block}: entry must be an object")
            continue
        if not check_author(entry.get("decided_by")):
            errors.append(
                f"{block}: decided_by must begin with 'author:' "
                f"(got {entry.get('decided_by')!r})"
            )
    return errors


def check_author(name):
    return bool(name) and name.startswith("author:")


# --- Graph and predicates ----------------------------------------------------


def load_json(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def load_dispositions(path):
    doc = load_json(path)
    out = {}
    for key, entry in doc.get("dispositions", {}).items():
        out[key] = entry.get("disposition") if isinstance(entry, dict) else entry
    return out


def edge_weight(edge, dispositions):
    """Weight of an edge in the ranking walk, or None when excluded."""
    if edge.get("kind") not in DEPENDENCY_KINDS:
        return None
    key = f"{edge.get('from')}->{edge.get('to')}"
    if dispositions.get(key) in EXCLUDED_DISPOSITIONS:
        return None
    return SOURCE_WEIGHT.get(edge.get("source"), DEFAULT_WEIGHT)


def build_graph(graph_path, discrepancy_path, registry_ids):
    """Return (dep_adj, impact_adj, excluded, unresolved).

    ``dep_adj`` maps user -> {used: weight}; ``impact_adj`` maps used -> {user:
    weight}. ``excluded`` names disposition-excluded edges; ``unresolved`` names
    edges with an endpoint outside the registry (surfaced, never dropped
    silently).
    """
    dispositions = load_dispositions(discrepancy_path)
    dep, impact, excluded, unresolved = {}, {}, [], []
    for edge in load_json(graph_path).get("edges", []):
        weight = edge_weight(edge, dispositions)
        key = f"{edge.get('from')}->{edge.get('to')}"
        if weight is None:
            if dispositions.get(key) in EXCLUDED_DISPOSITIONS:
                excluded.append(key)
            continue
        if edge["from"] not in registry_ids or edge["to"] not in registry_ids:
            unresolved.append(key)
            continue
        if edge["from"] == edge["to"]:
            continue
        dep.setdefault(edge["from"], {})[edge["to"]] = weight
        impact.setdefault(edge["to"], {})[edge["from"]] = weight
    return dep, impact, sorted(set(excluded)), sorted(set(unresolved))


def done_set(declarations_path):
    doc = load_json(declarations_path)
    return set(doc.get("blocks", doc))


def is_ready(block, dep, done):
    return all(target in done for target in dep.get(block, {}))


# --- Ranking -----------------------------------------------------------------


def pagerank(nodes, adj, seed, damping=DAMPING, iters=ITERS):
    """Personalized PageRank with weighted edges; deterministic.

    ``nodes`` is a sorted list. Dangling mass is redistributed by the
    personalization vector so the result is a proper distribution.
    """
    n = len(nodes)
    if n == 0:
        return {}
    total = sum(seed.get(x, 0.0) for x in nodes)
    if total <= 0:
        personal = {x: 1.0 / n for x in nodes}
    else:
        personal = {x: seed.get(x, 0.0) / total for x in nodes}
    pr = {x: 1.0 / n for x in nodes}
    for _ in range(iters):
        new = {x: (1.0 - damping) * personal[x] for x in nodes}
        dangling = 0.0
        for x in nodes:
            outs = adj.get(x, {})
            total_w = sum(outs.values())
            if total_w > 0 and pr[x]:
                for m in sorted(outs):
                    new[m] += damping * pr[x] * outs[m] / total_w
            else:
                dangling += damping * pr[x]
        if dangling:
            for x in nodes:
                new[x] += dangling * personal[x]
        pr = new
    return pr


def reverse_rank(registry, impact, nodes):
    seed = {
        b["id"]: KIND_SEED.get(b.get("kind"), 0.0)
        for b in registry
        if b.get("id") and b.get("status") == "confirmed"
        and b.get("kind") in RESULT_KINDS
    }
    return pagerank(nodes, impact, seed)


def ancestors(goal, dep):
    seen, stack = set(), [goal]
    while stack:
        cur = stack.pop()
        for nxt in dep.get(cur, {}):
            if nxt not in seen and nxt != goal:
                seen.add(nxt)
                stack.append(nxt)
    return seen


def forward_rank(goal, dep):
    """Rank the goal's ancestors conditioned on the goal (goal excluded)."""
    anc = ancestors(goal, dep)
    if not anc:
        return {}, []
    nodes = sorted(anc | {goal})
    sub = {
        x: {m: w for m, w in dep.get(x, {}).items() if m in nodes}
        for x in nodes
    }
    pr = pagerank(nodes, sub, {goal: 1.0})
    return {x: pr[x] for x in anc}, sorted(anc)


# --- Report ------------------------------------------------------------------


def _fmt(x):
    return f"{x:.4f}"


def render(store_path, graph_path, discrepancy_path, registry_path, declarations_path):
    registry = load_json(registry_path)
    blocks = {b["id"]: b for b in registry.get("blocks", []) if b.get("id")}
    nodes = sorted(blocks)
    ids = set(nodes)
    dep, impact, excluded, unresolved = build_graph(graph_path, discrepancy_path, ids)
    done = done_set(declarations_path)
    goals = load_store(store_path)

    rev = reverse_rank(registry.get("blocks", []), impact, nodes)
    shortlist = sorted(rev.items(), key=lambda kv: (-kv[1], kv[0]))[:SHORTLIST]

    lines = [
        "# Ranking report (Architecture.md Sections 12.1, 17.1, 19)",
        "",
        "Generated by `scripts/ranking.py`. **Advisory only**: it sets no scope "
        "disposition, treatment tier, or priority, and changes no closure, layer "
        "status, or evidence record.",
        "",
        "## Predicate",
        "",
        "- **done(a):** `a` is mapped in `lean/declarations.json` (formalized).",
        "- **ready(b):** every dependency target of `b` is done.",
        "- **edges:** all confirmed and candidate edges, weighted by source "
        f"(explicit {SOURCE_WEIGHT['explicit']}, prose {SOURCE_WEIGHT['prose']}, "
        f"symbol {SOURCE_WEIGHT['symbol']}); edges disposed "
        f"`type-carrier`/`simplification` are excluded.",
        "- **reverse rank:** PageRank on the impact graph (dependency -> user), "
        "restart mass over result-bearing blocks. On a DAG it concentrates on "
        "sinks, so the shortlist is *largest supporting foundation* - a size "
        "proxy, not a value judgement.",
        "",
        "## Goal shortlist (reverse rank)",
        "",
        "| rank | block | kind | mapped | score |",
        "|---|---|---|---|---|",
    ]
    for i, (block, score) in enumerate(shortlist, 1):
        b = blocks[block]
        lines.append(
            f"| {i} | `{block}` | {b.get('kind', '')} | "
            f"{'yes' if block in done else 'no'} | {_fmt(score)} |"
        )

    lines += ["", "## Designated goal", ""]
    if not goals:
        lines += [
            "**Undecided.** The author designates the goal from the shortlist "
            "above; no goal is adopted automatically. Record one with "
            "`python3 scripts/ranking.py --set-goal --block B-... "
            "--decided-by author:... --rationale \"...\"`.",
        ]
    else:
        goal = sorted(goals)[0]
        entry = goals[goal]
        kind = blocks.get(goal, {}).get("kind", "")
        lines += [
            f"`{goal}` ({kind}) - {entry.get('rationale', '')} "
            f"[{entry.get('decided_by', '')}]",
        ]
        if goal not in blocks:
            lines += ["", "**Goal is not a registry block; no ranking produced.**"]
        else:
            ranks, anc = forward_rank(goal, dep)
            undone = [b for b in anc if b not in done]
            ranked = sorted(undone, key=lambda b: (-ranks.get(b, 0.0), b))
            ready = [b for b in ranked if is_ready(b, dep, done)]
            rec = ready[0] if ready else None
            lines += [
                "",
                "## Next step (target-conditioned forward rank)",
                "",
                f"- goal ancestors (transitive prerequisites): {len(anc)}",
                f"- undone: {len(undone)}; ready: {len(ready)}",
                "",
            ]
            if rec:
                b = blocks[rec]
                lines += [
                    f"**Recommended next step: `{rec}`** ({b.get('kind', '')}, "
                    f"score {_fmt(ranks[rec])}).",
                ]
            else:
                lines += [
                    "**No ready undone prerequisite** (either all done, or every "
                    "undone prerequisite still has an undone dependency).",
                ]
            lines += [
                "",
                "| rank | block | kind | ready | score |",
                "|---|---|---|---|---|",
            ]
            for i, block in enumerate(ranked, 1):
                b = blocks[block]
                lines.append(
                    f"| {i} | `{block}` | {b.get('kind', '')} | "
                    f"{'yes' if is_ready(block, dep, done) else 'no'} | "
                    f"{_fmt(ranks.get(block, 0.0))} |"
                )
            if not ranked:
                lines.append("| _none_ | | | | |")

    if excluded or unresolved:
        lines += ["", "## Notes", ""]
    if excluded:
        lines += [
            "- excluded by disposition "
            f"(`type-carrier`/`simplification`): {len(excluded)} edge(s)",
        ]
        for key in excluded:
            lines.append(f"  - `{key}`")
    if unresolved:
        lines += [
            "- **unresolved** (endpoint outside the registry; not ranked): "
            f"{len(unresolved)} edge(s)",
        ]
        for key in unresolved:
            lines.append(f"  - `{key}`")
    lines.append("")
    return "\n".join(lines)


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("--store", default=str(DEFAULT_STORE))
    ap.add_argument("--graph", default=str(DEFAULT_GRAPH))
    ap.add_argument("--registry", default=str(DEFAULT_REGISTRY))
    ap.add_argument("--discrepancy", default=str(DEFAULT_DISCREPANCY))
    ap.add_argument("--declarations", default=str(DEFAULT_DECLARATIONS))
    ap.add_argument("--set-goal", action="store_true")
    ap.add_argument("--block")
    ap.add_argument("--decided-by", default="")
    ap.add_argument("--rationale", default="")
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--report", action="store_true")
    ap.add_argument("--check-report", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args(argv)

    goals = load_store(args.store)

    if args.check:
        errors = validate(goals)
        for e in errors:
            print(f"ERROR {e}")
        if errors:
            return 1
        print(f"ranking: {len(goals)} goal(s) valid")
        return 0

    if args.list:
        for block, entry in sorted(goals.items()):
            print(f"{block:10s} {entry.get('decided_by', '')}")
        return 0

    if args.set_goal:
        if not check_author(args.decided_by):
            print(
                "ranking: refusing to set a goal without an author decision "
                "(--decided-by author:...)",
                file=sys.stderr,
            )
            return 1
        if not args.block or not BLOCK_RE.match(args.block):
            print("ranking: --block must be a B-... id", file=sys.stderr)
            return 1
        save_store(args.store, {
            args.block: {"decided_by": args.decided_by, "rationale": args.rationale}
        })
        print(f"ranking: goal = {args.block}")
        return 0

    text = render(args.store, args.graph, args.discrepancy, args.registry,
                  args.declarations)

    if args.check_report:
        existing = REPORT.read_text(encoding="utf-8") if REPORT.exists() else None
        if existing != text:
            print("ranking: report drift in reports/ranking.md", file=sys.stderr)
            return 1
        print("ranking: report current", file=sys.stderr)
        return 0

    if args.dry_run:
        goals_n = len(goals)
        print(f"ranking: {goals_n} goal(s); report rendered ({len(text)} chars, dry run)")
        return 0

    if args.report:
        REPORT.parent.mkdir(parents=True, exist_ok=True)
        REPORT.write_text(text, encoding="utf-8")
        print("ranking: wrote reports/ranking.md")
        return 0

    print(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
