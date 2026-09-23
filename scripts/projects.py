#!/usr/bin/env python3
"""Multi-manuscript project registry (Architecture.md Sections 10.4, 10.5;
OpenSpec change ``add-mscong-project``).

The workspace can carry more than one manuscript formalization at once.  A
single root ``projects.yaml`` names each project and its artifact locations, so
the ingestion, hashing, gate, evidence, and bundle tooling operate per project
instead of against a hardwired manuscript.

The existing MSEilenberg formalization is the **default** project and keeps its
current top-level paths (``blocks/``, ``evidence/``, ``journal/events.jsonl``,
``reports/``, ``lean/declarations.json``); a second project is namespaced (e.g.
``blocks/mscong/``, ``evidence/mscong/``).

The environment has no YAML parser (``PyYAML`` is not installed), so a small
parser for the *mapping-only* subset this file uses lives here.  It is
deliberately narrow: mappings of scalars, nested by indentation, with ``#``
comments, quoted strings, and ``true``/``false``/``null``.  It fails closed on
anything it does not understand.

Usage:
    python3 scripts/projects.py --list
    python3 scripts/projects.py --default
    python3 scripts/projects.py --show mslang
    python3 scripts/projects.py --field mslang source
    python3 scripts/projects.py --env mslang          # `export` lines for bash
    python3 scripts/projects.py --check
"""
from __future__ import annotations

import argparse
import hashlib
import json
import shlex
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REGISTRY = ROOT / "projects.yaml"
BASELINE = ROOT / "projects.baseline.json"

# Keys whose values are paths relative to the repository root.  ``source`` and
# ``aux`` may be ``null`` (a project whose provenance has not been ingested yet).
PATH_KEYS = (
    "manuscript",
    "source",
    "aux",
    "blocks_dir",
    "hashes",
    "registry",
    "graph",
    "symbols",
    "evidence_dir",
    "journal",
    "reports_dir",
    "explanations_dir",
    "edge_decisions",
    "notation",
    "representation",
    "lean_declarations",
    "lean_formal",
    "lean_formal_graph",
    "lean_audit",
)

SCALAR_KEYS = ("lean_namespace", "notes", "ingested")

REQUIRED_KEYS = (
    "manuscript",
    "blocks_dir",
    "hashes",
    "registry",
    "graph",
    "symbols",
    "evidence_dir",
    "journal",
    "reports_dir",
    "lean_declarations",
    "lean_namespace",
    "ingested",
)

DEFAULT_FALLBACK = "mslang"


# --- Minimal YAML (mapping-only subset) -------------------------------------


class RegistryError(ValueError):
    """A registry that cannot be parsed or is malformed (fail closed)."""


def _strip_comment(line: str) -> str:
    out = []
    quote = None
    for ch in line:
        if quote:
            out.append(ch)
            if ch == quote:
                quote = None
        elif ch in "'\"":
            quote = ch
            out.append(ch)
        elif ch == "#":
            break
        else:
            out.append(ch)
    return "".join(out)


def _scalar(text: str):
    text = text.strip()
    if text == "" or text in ("~", "null", "Null", "NULL"):
        return None
    if text in ("true", "True"):
        return True
    if text in ("false", "False"):
        return False
    if len(text) >= 2 and text[0] == text[-1] and text[0] in "'\"":
        return text[1:-1]
    return text


def parse_yaml(text: str) -> dict:
    """Parse the mapping-only YAML subset used by ``projects.yaml``."""
    root: dict = {}
    stack = [(-1, root)]
    for lineno, raw in enumerate(text.splitlines(), 1):
        line = _strip_comment(raw).rstrip()
        if not line.strip():
            continue
        indent = len(line) - len(line.lstrip(" "))
        if "\t" in line[:indent]:
            raise RegistryError(f"line {lineno}: tab indentation is not allowed")
        content = line.strip()
        while len(stack) > 1 and indent <= stack[-1][0]:
            stack.pop()
        if indent <= stack[-1][0] and len(stack) == 1 and indent != 0:
            raise RegistryError(f"line {lineno}: unexpected indentation")
        if content.endswith(":"):
            key = content[:-1].strip()
            if not key:
                raise RegistryError(f"line {lineno}: empty mapping key")
            node: dict = {}
            stack[-1][1][key] = node
            stack.append((indent, node))
        else:
            key, sep, value = content.partition(":")
            if not sep:
                raise RegistryError(f"line {lineno}: expected 'key: value'")
            stack[-1][1][key.strip()] = _scalar(value)
    return root


# --- Loading ----------------------------------------------------------------


def load(path: Path = REGISTRY):
    """Return ``(default_id, {id: raw_entry})``."""
    path = Path(path)
    if not path.exists():
        raise RegistryError(f"registry not found: {path}")
    data = parse_yaml(path.read_text(encoding="utf-8"))
    projects = data.get("projects")
    if not isinstance(projects, dict) or not projects:
        raise RegistryError("registry has no 'projects' mapping")
    default = data.get("default") or DEFAULT_FALLBACK
    return str(default), projects


def list_projects(path: Path = REGISTRY):
    return sorted(load(path)[1])


def default_project(path: Path = REGISTRY) -> str:
    return load(path)[0]


def _resolve(root: Path, value):
    if value is None:
        return None
    return (root / str(value)).resolve()


def get(project_id: str, path: Path = REGISTRY, root: Path = ROOT) -> dict:
    """Return a project entry with ``PATH_KEYS`` resolved to absolute ``Path``.

    Raises ``KeyError`` for an unknown project id (the caller names it).
    """
    _default, projects = load(path)
    if project_id not in projects:
        raise KeyError(project_id)
    raw = dict(projects[project_id])
    entry = {"id": project_id, "root": Path(root)}
    for key, value in raw.items():
        if key in PATH_KEYS:
            entry[key] = _resolve(root, value)
        else:
            entry[key] = value
    return entry


def field(project_id: str, key: str, path: Path = REGISTRY, root: Path = ROOT):
    entry = get(project_id, path=path, root=root)
    if key not in entry:
        raise KeyError(key)
    return entry[key]


def _as_text(value) -> str:
    if value is None:
        return ""
    if isinstance(value, bool):
        return "true" if value else "false"
    return str(value)


# --- Validation -------------------------------------------------------------


def check(path: Path = REGISTRY, root: Path = ROOT):
    """Return a list of problems with the registry (empty means valid)."""
    problems = []
    default, projects = load(path)
    if default not in projects:
        problems.append(f"default project {default!r} is not registered")
    for pid, raw in sorted(projects.items()):
        for key in REQUIRED_KEYS:
            if key not in raw:
                problems.append(f"{pid}: missing required key {key!r}")
        if not isinstance(raw.get("ingested"), bool):
            problems.append(f"{pid}: 'ingested' must be true or false")
    # Path fields must not coincide across projects (provenance isolation).
    resolved = {}
    for pid in sorted(projects):
        entry = get(pid, path=path, root=root)
        resolved[pid] = entry
    ids = sorted(resolved)
    for i, a in enumerate(ids):
        for b in ids[i + 1 :]:
            for key in PATH_KEYS:
                va, vb = resolved[a].get(key), resolved[b].get(key)
                if va is not None and vb is not None and va == vb:
                    problems.append(
                        f"{a} and {b}: path {key!r} collides ({va})"
                    )
    return problems


def cross_project_id_collisions(path: Path = REGISTRY, root: Path = ROOT):
    """Return ``(collisions, per_project)`` for block/evidence/journal ids.

    ``per_project`` maps a project id to ``{"blocks": set, "evidence": set,
    "journal": set}``.  ``collisions`` lists ``(kind, id, pid_a, pid_b)`` for any
    id that two projects both define.
    """
    per_project = {}
    for pid in list_projects(path):
        entry = get(pid, path=path, root=root)
        blocks = set()
        registry = entry.get("registry")
        if registry is not None and registry.exists():
            doc = json.loads(registry.read_text(encoding="utf-8"))
            for b in doc.get("blocks", []):
                if b.get("id"):
                    blocks.add(b["id"])
        evidence = set()
        evid = entry.get("evidence_dir")
        if evid is not None and evid.is_dir():
            for p in evid.glob("*.json"):
                try:
                    evidence.add(
                        json.loads(p.read_text(encoding="utf-8")).get("evidence_id", p.stem)
                    )
                except json.JSONDecodeError:
                    evidence.add(p.stem)
        journal = set()
        jpath = entry.get("journal")
        if jpath is not None and jpath.exists():
            for line in jpath.read_text(encoding="utf-8").splitlines():
                if line.strip():
                    try:
                        event = json.loads(line)
                        if event.get("event_id"):
                            journal.add(event["event_id"])
                    except json.JSONDecodeError:
                        pass
        per_project[pid] = {"blocks": blocks, "evidence": evidence, "journal": journal}
    collisions = []
    for i, a in enumerate(sorted(per_project)):
        for b in sorted(per_project)[i + 1 :]:
            for kind in ("blocks", "evidence", "journal"):
                for shared in sorted(per_project[a][kind] & per_project[b][kind]):
                    collisions.append((kind, shared, a, b))
    return collisions, per_project


# --- Golden baseline (default-project preservation) -------------------------


def sha256(path: Path) -> str:
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def baseline_artifacts(project_id: str = DEFAULT_FALLBACK, path: Path = REGISTRY,
                       root: Path = ROOT):
    """The artifact paths the golden check covers for ``project_id``."""
    entry = get(project_id, path=path, root=root)
    out = {"registry": entry["registry"], "hashes": entry["hashes"]}
    reports_dir = entry.get("reports_dir")
    if reports_dir is not None:
        out["bundle"] = reports_dir / "bundle.md"
    return out


def check_baseline(path: Path = REGISTRY, baseline_path: Path = BASELINE,
                   root: Path = ROOT):
    """Compare the default project's artifacts to the recorded golden hashes.

    Returns ``(problems, extra)``: ``problems`` is a list of drift messages and
    ``extra`` a dict of computed hashes for reporting.
    """
    doc = json.loads(Path(baseline_path).read_text(encoding="utf-8"))
    pid = doc.get("project", DEFAULT_FALLBACK)
    recorded = doc.get("artifacts", {})
    computed = {}
    problems = []
    for rel, expected in sorted(recorded.items()):
        p = (root / rel).resolve()
        if not p.exists():
            problems.append(f"{rel}: missing")
            continue
        digest = sha256(p)
        computed[rel] = digest
        if digest != expected:
            problems.append(
                f"{rel}: drifted (recorded {expected[:12]}, now {digest[:12]})"
            )
    return problems, {"project": pid, "computed": computed}


# --- CLI --------------------------------------------------------------------


def _env_lines(project_id: str, path: Path = REGISTRY, root: Path = ROOT):
    entry = get(project_id, path=path, root=root)

    def ex(name, value):
        return f"export {name}={shlex.quote(_as_text(value))}"

    lines = [
        ex("MSLANG_PROJECT", entry["id"]),
        ex("MSLANG_ROOT", entry["root"]),
        ex("MSLANG_MANUSCRIPT", entry.get("manuscript")),
        ex("MSLANG_PROJECT_SOURCE", entry.get("source")),
        ex("MSLANG_AUX", entry.get("aux")),
        ex("MSLANG_BLOCKS_DIR", entry.get("blocks_dir")),
        ex("MSLANG_HASHES", entry.get("hashes")),
        ex("MSLANG_REGISTRY", entry.get("registry")),
        ex("MSLANG_GRAPH", entry.get("graph")),
        ex("MSLANG_SYMBOLS", entry.get("symbols")),
        ex("MSLANG_EVIDENCE_DIR", entry.get("evidence_dir")),
        ex("MSLANG_JOURNAL", entry.get("journal")),
        ex("MSLANG_REPORTS_DIR", entry.get("reports_dir")),
        ex("MSLANG_LEAN_DECLARATIONS", entry.get("lean_declarations")),
        ex("MSLANG_REPRESENTATION", entry.get("representation")),
        ex("MSLANG_LEAN_NAMESPACE", entry.get("lean_namespace")),
        ex("MSLANG_INGESTED", entry.get("ingested")),
    ]
    return lines


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("--registry", default=str(REGISTRY))
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--default", action="store_true")
    ap.add_argument("--show")
    ap.add_argument("--field", nargs=2, metavar=("ID", "KEY"))
    ap.add_argument("--env")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--check-baseline", action="store_true")
    ap.add_argument("--collisions", action="store_true")
    args = ap.parse_args(argv)
    path = Path(args.registry)

    try:
        if args.list:
            for pid in list_projects(path):
                print(pid)
            return 0
        if args.default:
            print(default_project(path))
            return 0
        if args.show:
            entry = get(args.show, path=path)
            print(json.dumps({k: _as_text(v) for k, v in entry.items()}, indent=2, sort_keys=True))
            return 0
        if args.field:
            pid, key = args.field
            print(_as_text(field(pid, key, path=path)))
            return 0
        if args.env:
            for line in _env_lines(args.env, path=path):
                print(line)
            return 0
        if args.check:
            problems = check(path)
            for p in problems:
                print(f"projects: {p}", file=sys.stderr)
            if problems:
                return 1
            _default, projects = load(path)
            print(f"projects: {len(projects)} project(s), registry valid")
            return 0
        if args.collisions:
            collisions, per_project = cross_project_id_collisions(path)
            for pid, sets in sorted(per_project.items()):
                print(
                    f"{pid}: {len(sets['blocks'])} block id(s), "
                    f"{len(sets['evidence'])} evidence id(s), "
                    f"{len(sets['journal'])} journal id(s)"
                )
            for kind, shared, a, b in collisions:
                print(f"projects: {kind} id {shared} collides between {a} and {b}", file=sys.stderr)
            return 1 if collisions else 0
        if args.check_baseline:
            problems, extra = check_baseline(path=path)
            for p in problems:
                print(f"projects: baseline {p}", file=sys.stderr)
            if problems:
                return 1
            print(
                f"projects: golden baseline for {extra['project']} current "
                f"({len(extra['computed'])} artifact(s))"
            )
            return 0
    except (RegistryError, KeyError) as exc:
        print(f"projects: {exc}", file=sys.stderr)
        return 1
    ap.print_help()
    return 2


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
