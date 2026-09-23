#!/usr/bin/env python3
"""Tests for the multi-manuscript project registry (OpenSpec change
``add-mscong-project``; Architecture.md Sections 10.4, 10.5).

Run:
    python3 scripts/projects_test.py
"""
from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import projects  # noqa: E402

FAILURES = []


def check(name, condition, detail=""):
    print(
        f"[{'PASS' if condition else 'FAIL'}] {name}"
        + (f" -- {detail}" if detail and not condition else "")
    )
    if not condition:
        FAILURES.append(name)


def main():
    # Enumeration and default selection.
    ids = projects.list_projects()
    check("registry enumerates both projects", ids == ["mscong", "mslang"], str(ids))
    check("default project is mslang", projects.default_project() == "mslang")

    # Lookup resolves paths to absolute locations under the repo root.
    mslang = projects.get("mslang")
    check("mslang source resolves",
          mslang["source"] == (projects.ROOT / "manuscript" / "MSEilenberg.tex").resolve())
    check("mslang registry resolves",
          mslang["registry"] == (projects.ROOT / "blocks" / "registry.json").resolve())
    check("mslang is ingested", mslang["ingested"] is True)
    check("mslang namespace", mslang["lean_namespace"] == "Mslang")

    mscong = projects.get("mscong")
    check("mscong is a scaffold (not ingested)", mscong["ingested"] is False)
    check("mscong has no provenance source yet", mscong["source"] is None)
    check("mscong manuscript resolves",
          mscong["manuscript"] == (projects.ROOT / "manuscript" / "MSCong.tex").resolve())
    check("mscong blocks are namespaced",
          mscong["blocks_dir"] == (projects.ROOT / "blocks" / "mscong").resolve())

    # Unknown id is an error.
    try:
        projects.get("does-not-exist")
        check("unknown project id raises", False)
    except KeyError:
        check("unknown project id raises", True)

    # Registry validity, including no cross-project path collision.
    problems = projects.check()
    check("registry is valid", not problems, "; ".join(problems))

    # A path field is not shared across projects.
    shared = [
        key
        for key in projects.PATH_KEYS
        if mslang.get(key) is not None and mslang.get(key) == mscong.get(key)
    ]
    check("no path collides across projects", not shared, str(shared))

    # Identifier spaces do not collide (task 4.3).
    collisions, per_project = projects.cross_project_id_collisions()
    check("no block/evidence/journal id collision across projects", not collisions,
          str(collisions))
    check("mscong has no identifiers yet",
          all(not s for s in per_project["mscong"].values()),
          str(per_project["mscong"]))

    # The default project's artifacts are byte-identical to the recorded baseline.
    problems, _extra = projects.check_baseline()
    check("golden baseline current", not problems, "; ".join(problems))

    # The YAML subset parser fails closed on malformed input.
    check("parser reads a nested map",
          projects.parse_yaml("a:\n  b: 1\n") == {"a": {"b": "1"}})
    check("parser reads booleans and null",
          projects.parse_yaml("x: true\ny: false\nz: null\n")
          == {"x": True, "y": False, "z": None})
    try:
        projects.parse_yaml("bad line without colon\n")
        check("parser fails closed on a non-mapping line", False)
    except projects.RegistryError:
        check("parser fails closed on a non-mapping line", True)

    # A fixture registry with a collision is rejected (detector actually fires).
    import tempfile

    with tempfile.TemporaryDirectory() as tmp:
        fixture = Path(tmp) / "projects.yaml"
        fixture.write_text(
            "default: a\n"
            "projects:\n"
            "  a:\n"
            "    lean_namespace: A\n"
            "    manuscript: m/a.tex\n"
            "    source: m/a.tex\n"
            "    aux: null\n"
            "    blocks_dir: blocks\n"
            "    hashes: blocks/hashes.json\n"
            "    registry: blocks/registry.json\n"
            "    graph: blocks/graph.json\n"
            "    symbols: blocks/symbols.json\n"
            "    evidence_dir: evidence\n"
            "    journal: journal/events.jsonl\n"
            "    reports_dir: reports\n"
            "    lean_declarations: lean/declarations.json\n"
            "    ingested: true\n"
            "  b:\n"
            "    lean_namespace: B\n"
            "    manuscript: m/b.tex\n"
            "    source: m/b.tex\n"
            "    aux: null\n"
            "    blocks_dir: blocks\n"
            "    hashes: blocks/hashes.json\n"
            "    registry: blocks/registry.json\n"
            "    graph: blocks/graph.json\n"
            "    symbols: blocks/symbols.json\n"
            "    evidence_dir: evidence\n"
            "    journal: journal/events.jsonl\n"
            "    reports_dir: reports\n"
            "    lean_declarations: lean/declarations.json\n"
            "    ingested: true\n",
            encoding="utf-8",
        )
        fixture_problems = projects.check(fixture)
        check("colliding fixture is rejected", bool(fixture_problems),
              str(fixture_problems))
        check("collision names the shared path",
              any("collides" in p for p in fixture_problems), str(fixture_problems))

    # A deliberately broken ingested project fails its per-project anchor check,
    # and the check is resolved from the registry (task 6.1 verification).
    import subprocess
    import tempfile

    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        src = tmp / "broken.tex"
        src.write_text(
            "\\blockid{B-D001}\n\\begin{definition}\nfoo\n\\end{definition}\n",
            encoding="latin1",
        )
        hashes = tmp / "hashes.json"
        hashes.write_text('{\n  "B-D001": "00"\n}\n', encoding="utf-8")
        fixture = tmp / "projects.yaml"
        fixture.write_text(
            "default: broken\n"
            "projects:\n"
            "  broken:\n"
            "    lean_namespace: Broken\n"
            f"    manuscript: {src}\n"
            f"    source: {src}\n"
            "    aux: null\n"
            f"    hashes: {hashes}\n"
            "    ingested: true\n",
            encoding="utf-8",
        )
        proc = subprocess.run(
            [sys.executable, str(HERE / "hash_blocks.py"),
             "--registry", str(fixture), "--project", "broken", "--check"],
            capture_output=True, text=True,
        )
        check("a broken ingested project fails its anchor check",
              proc.returncode != 0, proc.stderr)
        check("the failure names the stale anchor",
              "STALE" in proc.stderr, proc.stderr)

    print()
    if FAILURES:
        print(f"projects_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("projects_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
