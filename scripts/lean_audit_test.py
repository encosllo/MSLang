#!/usr/bin/env python3
"""Tests for the mechanical Lean gate's pure parsing (Architecture.md 15.6).

Seeded checks over sample Lean/Lake streams: diagnostics are split into
warnings and errors, `#print axioms` output is parsed in both forms with
axioms sorted, and the `sorry` token is matched as a whole identifier (so
`sorryAx` and `no_sorry` are not hits).

Run:
    python3 scripts/lean_audit_test.py
"""
from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import lean_audit as la  # noqa: E402

FAILURES = []

BUILD = """\
info: Mslang.lean:14:0: building
warning: Mslang/Pilot.lean:764:4: Variable name `s` is not explicitly referenced.
warning: Mslang/Pilot.lean:800:2: unused variable
error: Mslang/Pilot.lean:900:1: unknown identifier
Build completed successfully (8709 jobs).
"""

AXIOMS = """\
'Mslang.foo' depends on axioms: [Quot.sound, propext]
'Mslang.bar' does not depend on any axioms
'Mslang.baz' depends on axioms: [Classical.choice]
"""

# Lean wraps the axiom list across lines for long declaration names.
AXIOMS_WRAPPED = """\
'Mslang.a_very_long_declaration_name_that_forces_wrapping' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'Mslang.short' does not depend on any axioms
"""


def check(name, condition, detail=""):
    print(f"[{'PASS' if condition else 'FAIL'}] {name}"
          + (f" -- {detail}" if detail and not condition else ""))
    if not condition:
        FAILURES.append(name)


def main():
    warnings, errors = la.parse_diagnostics(BUILD)
    check("two warnings parsed", len(warnings) == 2, str(warnings))
    check("one error parsed", errors == ["Mslang/Pilot.lean:900:1: unknown identifier"], str(errors))
    check("info line ignored",
          not any("building" in w for w in warnings), str(warnings))

    ax = la.parse_axioms(AXIOMS)
    check("axioms parsed for depending declarations",
          ax.get("Mslang.foo") == ["Quot.sound", "propext"], str(ax))
    check("no-axiom declaration is empty", ax.get("Mslang.bar") == [], str(ax))
    check("axioms are sorted",
          ax.get("Mslang.foo") == sorted(ax.get("Mslang.foo", [])), str(ax))

    axw = la.parse_axioms(AXIOMS_WRAPPED)
    check("wrapped axiom list parsed",
          axw.get("Mslang.a_very_long_declaration_name_that_forces_wrapping")
          == ["Classical.choice", "Quot.sound", "propext"], str(axw))
    check("wrapped output does not swallow the next declaration",
          axw.get("Mslang.short") == [], str(axw))

    check("sorry token matched as a whole identifier",
          bool(la.SORRY_RE.search(":= by sorry")) and
          bool(la.SORRY_RE.search("(sorry)")))
    check("sorry inside a longer identifier is not a hit",
          not la.SORRY_RE.search("sorryAx") and
          not la.SORRY_RE.search("no_sorry") and
          not la.SORRY_RE.search("sorryish"))

    print()
    if FAILURES:
        print(f"lean_audit_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("lean_audit_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
