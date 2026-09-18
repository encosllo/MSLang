#!/usr/bin/env python3
"""Mechanical Lean gate (Architecture.md Section 15.6, Revision 3).

Computes, from the pinned project, the three facts the verification layer
depends on - that it builds, that it builds cleanly, and that every mapped
declaration's axioms lie inside the permitted set - plus a project-wide
`sorry`-freeness check. It records them deterministically in
``blocks/lean_audit.json`` so that a `build_ok` verification record can cite a
measured fact rather than a remembered console tail.

Checks:

    lake build          full diagnostic stream captured (not a tail);
                        an unallowlisted warning or any error fails.
    #print axioms       every declaration named in ``lean/declarations.json``
                        (one Lean process); an axiom outside the permitted set
                        fails.
    sorry scan          the ``sorry`` token in the Lean sources fails.

Usage:
    python3 scripts/lean_audit.py
    python3 scripts/lean_audit.py --check
    python3 scripts/lean_audit.py --skip-build     # reuse current oleans

The build runs with ``ELAN_HOME`` removed from the environment so that it uses
the machine toolchain (the project-local ``.elan`` is empty; see the
safe-restart checklist).
"""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import lean_facets  # noqa: E402

ROOT = HERE.parent
LEAN = ROOT / "lean"
OUT = ROOT / "blocks" / "lean_audit.json"
ALLOWLIST = LEAN / "lean_audit_allowlist.json"

PERMITTED_AXIOMS = ["propext", "Classical.choice", "Quot.sound"]

DIAG_RE = re.compile(r"^(warning|error):\s*(.*)$")
# `#print axioms` wraps the axiom list across lines for long declaration names,
# so the head is matched separately and the body accumulated until `]`.
AXIOM_HEAD_RE = re.compile(
    r"^'([^']+)' (does not depend on any axioms|depends on axioms: \[)(.*)$"
)
SORRY_RE = re.compile(r"(?<![A-Za-z0-9_'])sorry(?![A-Za-z0-9_'])")


def toolchain_versions():
    lean = os.environ.get("LEAN_VERSION", "leanprover/lean4:v4.33.1")
    mathlib = os.environ.get(
        "MATHLIB_REV", "0df444a360eaa60ab8c11dca51a86af692955474"
    )
    return lean, mathlib


def load_declarations():
    data = json.loads((LEAN / "declarations.json").read_text(encoding="utf-8"))
    names = []
    for spec in data.get("blocks", {}).values():
        if "decls" in spec:
            names.extend(spec["decls"])
        elif "decl" in spec:
            names.append(spec["decl"])
    # stable and de-duplicated, preserving first-seen order
    seen, out = set(), []
    for n in names:
        if n not in seen:
            seen.add(n)
            out.append(n)
    return out


def subprocess_env():
    env = os.environ.copy()
    env.pop("ELAN_HOME", None)
    return env


def parse_diagnostics(text):
    """First-line warnings and errors from a full Lean/Lake diagnostic stream."""
    warnings, errors = [], []
    for raw in text.splitlines():
        m = DIAG_RE.match(raw.strip())
        if not m:
            continue
        (errors if m.group(1) == "error" else warnings).append(m.group(2).strip())
    return warnings, errors


def parse_axioms(text):
    """{declaration: sorted axiom list} from `#print axioms` output.

    The axiom list may be wrapped across several lines (Lean wraps long names),
    so a head match is followed by continuation lines up to the closing ``]``.
    """
    axioms = {}
    lines = text.splitlines()
    i = 0
    while i < len(lines):
        m = AXIOM_HEAD_RE.match(lines[i].strip())
        if not m:
            i += 1
            continue
        name = m.group(1)
        head, body = m.group(2), m.group(3)
        if head.startswith("does not depend"):
            axioms[name] = []
            i += 1
            continue
        while "]" not in body and i + 1 < len(lines):
            i += 1
            body += " " + lines[i].strip()
        body = body.split("]", 1)[0]
        axioms[name] = sorted(a.strip() for a in body.split(",") if a.strip())
        i += 1
    return axioms


def sorry_hits():
    hits = []
    for path in sorted((LEAN / "Mslang").glob("*.lean")) + [LEAN / "Mslang.lean"]:
        if not path.exists():
            continue
        stripped = lean_facets.strip_lean_comments(path.read_text(encoding="utf-8"))
        for i, line in enumerate(stripped.splitlines(), 1):
            if SORRY_RE.search(line):
                hits.append(f"{path.relative_to(ROOT)}:{i}")
    return hits


def load_allowlist():
    if not ALLOWLIST.exists():
        return {"warnings": [], "axioms": []}
    data = json.loads(ALLOWLIST.read_text(encoding="utf-8"))
    return {
        "warnings": list(data.get("warnings", [])),
        "axioms": list(data.get("axioms", [])),
    }


def run_build():
    proc = subprocess.run(
        ["lake", "build"],
        cwd=LEAN,
        env=subprocess_env(),
        capture_output=True,
        text=True,
    )
    return proc.returncode, proc.stdout + proc.stderr


def run_axioms(names):
    with tempfile.TemporaryDirectory() as tmp:
        check = Path(tmp) / "lean_audit_check.lean"
        lines = ["import Mslang"] + [
            f"#print axioms {n}" for n in names
        ]
        check.write_text("\n".join(lines) + "\n", encoding="utf-8")
        proc = subprocess.run(
            ["lake", "env", "lean", str(check)],
            cwd=LEAN,
            env=subprocess_env(),
            capture_output=True,
            text=True,
        )
    return proc.returncode, proc.stdout + proc.stderr


def compute(skip_build=False):
    lean, mathlib = toolchain_versions()
    names = load_declarations()
    allow = load_allowlist()

    build_rc, build_out = (0, "") if skip_build else run_build()
    warnings, errors = parse_diagnostics(build_out)
    allowed = set(allow["warnings"])
    unexpected_warnings = [w for w in warnings if w not in allowed]
    build_ok = build_rc == 0 and not errors and not unexpected_warnings

    ax_rc, ax_out = run_axioms(names)
    axioms = parse_axioms(ax_out)
    missing = [n for n in names if n not in axioms]
    permitted = set(PERMITTED_AXIOMS) | set(allow["axioms"])
    unpermitted = {
        n: axs for n, axs in sorted(axioms.items())
        if any(a not in permitted for a in axs)
    }

    sorry = sorry_hits()

    return {
        "note": "Mechanical Lean gate (Architecture.md Section 15.6). Derived by "
        "scripts/lean_audit.py; do not edit by hand.",
        "declared_permitted_axioms": PERMITTED_AXIOMS,
        "allowlist": allow,
        "environment": {"lean": lean, "mathlib": mathlib},
        "declarations_audited": len(names),
        "axioms": {n: axioms[n] for n in names if n in axioms},
        "build": {
            "ok": build_ok,
            "returncode": build_rc,
            "warnings": warnings,
            "errors": errors,
            "unexpected_warnings": unexpected_warnings,
        },
        "missing_axiom_reports": missing,
        "unpermitted_axioms": unpermitted,
        "sorry": sorry,
        "ok": build_ok and not missing and not unpermitted and not sorry,
    }


def render(audit):
    return json.dumps(audit, indent=2, sort_keys=True) + "\n"


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("--check", action="store_true",
                    help="fail if blocks/lean_audit.json would change")
    ap.add_argument("--skip-build", action="store_true",
                    help="reuse the current oleans instead of running lake build")
    ap.add_argument("--out", default=str(OUT))
    args = ap.parse_args(argv)

    audit = compute(skip_build=args.skip_build)
    payload = render(audit)
    out = Path(args.out)

    if args.check:
        existing = out.read_text(encoding="utf-8") if out.exists() else None
        if existing != payload:
            print("lean_audit: drift in blocks/lean_audit.json", file=sys.stderr)
            return 1
        print(
            f"lean_audit: {audit['declarations_audited']} declaration(s), "
            f"{len(audit['build']['warnings'])} warning(s), "
            f"{len(audit['unpermitted_axioms'])} unpermitted, "
            f"{len(audit['sorry'])} sorry, ok={audit['ok']}"
        )
        return 0 if audit["ok"] else 1

    out.write_text(payload, encoding="utf-8")
    print(
        f"lean_audit: {audit['declarations_audited']} declaration(s), "
        f"{len(audit['build']['warnings'])} warning(s), "
        f"{len(audit['unpermitted_axioms'])} unpermitted, "
        f"{len(audit['sorry'])} sorry, ok={audit['ok']}"
    )
    print(f"lean_audit: wrote {out.relative_to(ROOT)}")
    return 0 if audit["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
