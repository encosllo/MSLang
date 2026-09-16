#!/usr/bin/env python3
"""Tests for Lean formal-facet extraction and hashing (Sections 6, 7.2, 12.3).

Seeded checks: the statement/proof split is correct, comments are stripped, a
proof rewrite leaves the statement hash alone (proof irrelevance), a signature
rewrite changes it, and a missing declaration is flagged rather than silently
dropped.

Run:
    python3 scripts/lean_facets_test.py
"""
from __future__ import annotations

import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import lean_facets as lf  # noqa: E402

FAILURES = []

SRC = """
import Mathlib
namespace Mslang
/-- a doc comment that must not be hashed -/
theorem foo (n : Nat) : n = n := by rfl
lemma bar : True := by trivial
def baz (n : Nat) : Nat := n + 1
abbrev qux := Nat
theorem incomplete : True
@[simp]
theorem attributed : True := by trivial
noncomputable def ncd : Nat := 0
inductive Leaf : Nat → Prop
  | base : Leaf 0
  | step : ∀ n, Leaf n → Leaf (n + 1)
end Mslang
"""


def check(name, condition, detail=""):
    print(f"[{'PASS' if condition else 'FAIL'}] {name}" + (f" -- {detail}" if detail and not condition else ""))
    if not condition:
        FAILURES.append(name)


def write(tmp, name, text):
    p = Path(tmp) / name
    p.write_text(text, encoding="utf-8")
    return p


def main():
    d = lf.extract_declarations(SRC)
    check("all declarations found", set(d) == {"foo", "bar", "baz", "qux", "incomplete", "attributed", "ncd", "Leaf"}, str(set(d)))
    check(
        "inductive constructors are part of its statement, with no proof facet",
        d["Leaf"]["proof"] == ""
        and d["Leaf"]["statement"].startswith("inductive Leaf")
        and "| step" in d["Leaf"]["statement"],
        str(d["Leaf"]),
    )
    check(
        "theorem statement split at :=",
        d["foo"]["statement"] == "theorem foo (n : Nat) : n = n"
        and d["foo"]["proof"] == ":= by rfl",
        str(d["foo"]),
    )
    check("comment not in hashed statement",
        "doc comment" not in d["foo"]["statement"],
        d["foo"]["statement"],
    )
    check(
        "def body is the proof facet",
        d["baz"]["statement"] == "def baz (n : Nat) : Nat"
        and d["baz"]["proof"] == ":= n + 1",
        str(d["baz"]),
    )
    check("abbrev body is the proof facet", d["qux"]["proof"] == ":= Nat", str(d["qux"]))
    check("declaration without := has no proof facet", d["incomplete"]["proof"] == "", str(d["incomplete"]))
    check(
        "an attribute does not leak into the preceding proof",
        "@[" not in d["incomplete"]["proof"]
        and d["attributed"]["proof"] == ":= by trivial",
        repr(d["incomplete"]["proof"]),
    )
    check(
        "a modifier is part of its declaration",
        d["ncd"]["statement"] == "noncomputable def ncd : Nat"
        and d["ncd"]["proof"] == ":= 0",
        str(d["ncd"]),
    )

    with tempfile.TemporaryDirectory() as tmp:
        declmap = {"B-X": {"decl": "Mslang.foo", "file": "a.lean"}}
        write(tmp, "a.lean", SRC)
        base = lf.compute(declmap, root=Path(tmp))[0]["blocks"]["B-X"]

        write(tmp, "a.lean", SRC.replace(":= by rfl", ":= by simp"))
        proof_edit = lf.compute(declmap, root=Path(tmp))[0]["blocks"]["B-X"]
        check(
            "proof rewrite keeps the statement hash",
            proof_edit["formal_statement"]["hash"]
            == base["formal_statement"]["hash"],
        )
        check(
            "proof rewrite changes the proof hash",
            proof_edit["formal_proof"]["hash"] != base["formal_proof"]["hash"],
        )

        write(tmp, "a.lean", SRC.replace("n = n", "n ≤ n"))
        sig_edit = lf.compute(declmap, root=Path(tmp))[0]["blocks"]["B-X"]
        check(
            "signature rewrite changes the statement hash",
            sig_edit["formal_statement"]["hash"]
            != base["formal_statement"]["hash"],
        )

        missing = {"B-Y": {"decl": "Mslang.nope", "file": "a.lean"}}
        out = lf.compute(missing, root=Path(tmp))[0]["blocks"]["B-Y"]
        check("missing declaration flagged", "error" in out, str(out))

    print()
    if FAILURES:
        print(f"lean_facets_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("lean_facets_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
