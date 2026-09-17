#!/usr/bin/env python3
"""Tests for goal-directed ranking (Architecture.md Sections 12.1, 17.1).

Run:
    python3 scripts/ranking_test.py
"""
from __future__ import annotations

import hashlib
import json
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import ranking  # noqa: E402

FAILURES = []


def check(name, condition, detail=""):
    print(f"[{'PASS' if condition else 'FAIL'}] {name}" + (f" -- {detail}" if detail and not condition else ""))
    if not condition:
        FAILURES.append(name)


def jwrite(path, obj):
    Path(path).write_text(json.dumps(obj), encoding="utf-8")


def fixture(tmp):
    """A tiny project: a goal, a ready prerequisite, a blocked one, and an
    out-of-closure block."""
    reg = {"blocks": [
        {"id": "B-D000", "kind": "definition", "status": "confirmed"},
        {"id": "B-D001", "kind": "definition", "status": "confirmed"},
        {"id": "B-D002", "kind": "definition", "status": "confirmed"},
        {"id": "B-P003", "kind": "proposition", "status": "confirmed"},
        {"id": "B-P009", "kind": "proposition", "status": "confirmed"},
    ]}
    graph = {"edges": [
        {"from": "B-P003", "to": "B-D001", "kind": "uses_definition", "source": "explicit"},
        {"from": "B-P003", "to": "B-D002", "kind": "uses_definition", "source": "symbol"},
        {"from": "B-D002", "to": "B-D000", "kind": "uses_definition", "source": "symbol"},
        {"from": "B-P009", "to": "B-D001", "kind": "uses_definition", "source": "explicit"},
        {"from": "B-P009", "to": "B-D000", "kind": "uses_definition", "source": "explicit"},
        {"from": "B-P009", "to": "B-P003", "kind": "uses_definition", "source": "explicit"},
        {"from": "B-P003", "to": "B-Z999", "kind": "uses_definition", "source": "symbol"},
    ]}
    reg_p = Path(tmp) / "registry.json"
    graph_p = Path(tmp) / "graph.json"
    disc_p = Path(tmp) / "disc.json"
    decl_p = Path(tmp) / "decl.json"
    store_p = Path(tmp) / "ranking.json"
    jwrite(reg_p, reg)
    jwrite(graph_p, graph)
    jwrite(disc_p, {"note": "t", "dispositions": {}})
    jwrite(decl_p, {"note": "t", "blocks": {"B-D001": {}}})
    jwrite(store_p, {"note": "t", "goals": {}})
    return reg_p, graph_p, disc_p, decl_p, store_p


def digest_dir(path):
    h = hashlib.sha256()
    for p in sorted(Path(path).rglob("*")):
        if p.is_file():
            h.update(str(p).encode())
            h.update(p.read_bytes())
    return h.hexdigest()


def main():
    # Store validation and author reservation.
    check("the real store loads", isinstance(ranking.load_store(ranking.DEFAULT_STORE), dict))
    check("the real store validates", ranking.validate(ranking.load_store(ranking.DEFAULT_STORE)) == [])
    check("an invalid goal target is rejected",
          ranking.validate({"nope": {"decided_by": "author:x"}}) != [])
    check("an agent cannot set a goal", not ranking.check_author("agent:opencode"))
    check("multiple goals validate",
          ranking.validate({"B-D000": {"decided_by": "author:x"},
                            "B-D001": {"decided_by": "author:x"}}) == [])
    with tempfile.TemporaryDirectory() as tmp:
        store = Path(tmp) / "ranking.json"
        jwrite(store, {"note": "t", "goals": {}})
        rc = ranking.main(["--store", str(store), "--set-goal", "--block", "B-P003",
                           "--decided-by", "agent:opencode"])
        check("the CLI refuses an agent goal", rc == 1)
        check("the refused goal changed nothing", ranking.load_store(store) == {})
        rc2 = ranking.main(["--store", str(store), "--set-goal", "--block", "B-P003",
                            "--decided-by", "author:test", "--rationale", "r"])
        check("the CLI accepts an author goal", rc2 == 0)
        check("the goal survives a reload",
              "B-P003" in ranking.load_store(store))
        ranking.main(["--store", str(store), "--set-goal", "--block", "B-D000",
                      "--decided-by", "author:test"])
        check("a second goal is added, not replacing the first",
              set(ranking.load_store(store)) == {"B-P003", "B-D000"})
        rc3 = ranking.main(["--store", str(store), "--remove-goal", "--block", "B-D000",
                            "--decided-by", "agent:opencode"])
        check("an agent cannot remove a goal",
              rc3 == 1 and "B-D000" in ranking.load_store(store))
        rc4 = ranking.main(["--store", str(store), "--remove-goal", "--block", "B-D000",
                            "--decided-by", "author:test"])
        check("an author can remove a goal",
              rc4 == 0 and set(ranking.load_store(store)) == {"B-P003"})

    # Edge weighting and disposition exclusion.
    explicit = ranking.edge_weight({"kind": "uses_definition", "source": "explicit"}, {})
    symbol = ranking.edge_weight({"kind": "uses_definition", "source": "symbol"}, {})
    prose = ranking.edge_weight({"kind": "uses_definition", "source": "prose"}, {})
    check("explicit outweighs symbol", explicit > prose > symbol > 0, f"{explicit} {prose} {symbol}")
    check("a type-carrier edge is excluded",
          ranking.edge_weight({"kind": "uses_definition", "source": "symbol",
                               "from": "B-D000", "to": "B-D001"},
                              {"B-D000->B-D001": "type-carrier"}) is None)
    check("a non-dependency edge is excluded",
          ranking.edge_weight({"kind": "formal_uses", "source": "explicit"}, {}) is None)

    with tempfile.TemporaryDirectory() as tmp:
        reg_p, graph_p, disc_p, decl_p, store_p = fixture(tmp)
        args = (str(store_p), str(graph_p), str(disc_p), str(reg_p), str(decl_p))

        # Determinism.
        check("ranking is deterministic",
              ranking.render(*args) == ranking.render(*args))

        # Goal required.
        text = ranking.render(*args)
        check("no goal -> undecided, not the top candidate",
              "Undecided" in text and "adopted automatically" in text)

        # Forward rank: prerequisite, goal excluded, readiness, closure.
        jwrite(store_p, {"note": "t", "goals": {"B-P003": {"decided_by": "author:test"}}})
        text = ranking.render(*args)
        check("the recommendation is a prerequisite, not the goal",
              "Recommended next step: `B-D000`" in text, text)
        check("a block with an undone dependency is not ready",
              "| 1 | `B-D002` | definition | no |" in text, text)
        forward = text.split("## Next step")[1] if "## Next step" in text else ""
        check("a block outside the ancestor set is not ranked",
              "`B-P009`" not in forward, forward)

        # Goal set: shared prerequisite recommended, per-goal breakdown.
        jwrite(store_p, {"note": "t", "goals": {
            "B-P003": {"decided_by": "author:test"},
            "B-P009": {"decided_by": "author:test"}}})
        text = ranking.render(*args)
        check("multi-goal recommends a shared prerequisite",
              "Recommended next step: `B-D000`" in text, text)
        check("per-goal column names both goals for a shared block",
              "B-P003, B-P009" in text, text)
        forward = text.split("## Next step")[1] if "## Next step" in text else ""
        check("a terminal goal is not recommended or ranked",
              "Recommended next step: `B-P009`" not in forward
              and "| `B-P009` |" not in forward, forward)
        check("an unresolved edge is named, not dropped",
              "B-P003->B-Z999" in text)

        # Advisory: running the dry run writes nothing.
        before = digest_dir(HERE.parent / "evidence")
        ranking.main(["--dry-run", "--store", str(store_p), "--graph", str(graph_p),
                      "--registry", str(reg_p), "--discrepancy", str(disc_p),
                      "--declarations", str(decl_p)])
        after = digest_dir(HERE.parent / "evidence")
        check("running the ranking changes no evidence", before == after)

    # Prerequisite goal: a goal that another designated goal depends on may be
    # recommended, unlike a terminal goal.
    with tempfile.TemporaryDirectory() as tmp:
        jwrite(Path(tmp) / "registry.json", {"blocks": [
            {"id": "B-D001", "kind": "definition", "status": "confirmed"},
            {"id": "B-P003", "kind": "proposition", "status": "confirmed"},
            {"id": "B-P009", "kind": "proposition", "status": "confirmed"},
        ]})
        jwrite(Path(tmp) / "graph.json", {"edges": [
            {"from": "B-P003", "to": "B-D001", "kind": "uses_definition", "source": "explicit"},
            {"from": "B-P009", "to": "B-D001", "kind": "uses_definition", "source": "explicit"},
            {"from": "B-P009", "to": "B-P003", "kind": "uses_definition", "source": "explicit"},
        ]})
        jwrite(Path(tmp) / "disc.json", {"dispositions": {}})
        jwrite(Path(tmp) / "decl.json", {"blocks": {"B-D001": {}}})
        jwrite(Path(tmp) / "ranking.json", {"goals": {
            "B-P003": {"decided_by": "author:t"},
            "B-P009": {"decided_by": "author:t"}}})
        text = ranking.render(str(Path(tmp) / "ranking.json"),
                              str(Path(tmp) / "graph.json"), str(Path(tmp) / "disc.json"),
                              str(Path(tmp) / "registry.json"), str(Path(tmp) / "decl.json"))
        check("a prerequisite goal may be recommended",
              "Recommended next step: `B-P003`" in text, text)

    # Real corpus: the shortlist surfaces the headline results.
    real = ranking.render(str(ranking.DEFAULT_STORE), str(ranking.DEFAULT_GRAPH),
                          str(ranking.DEFAULT_DISCREPANCY), str(ranking.DEFAULT_REGISTRY),
                          str(ranking.DEFAULT_DECLARATIONS))
    check("shortlist contains headline results",
          "`B-P035`" in real and "`B-P038`" in real)

    print()
    if FAILURES:
        print(f"ranking_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("ranking_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
