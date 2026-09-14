#!/usr/bin/env python3
"""Seeded hygiene tests (Architecture.md Sections 13.3, 21 Phase 1 exit criteria).

Checks that the anchor-based hasher and the importer are stable under the exact
edits that silently break range-based bookkeeping:

* **line shift**  -- inserting text/comments elsewhere must not change any
  block hash (anchors are block IDs, not line ranges);
* **locality**    -- editing one block's body changes that block's hash and no
  other;
* **re-ingestion identity** -- block IDs, order, and labels survive re-runs on
  an edited source, and only the edited block's facet hash changes;
* **proof/statement separation** -- editing a proof does not change the
  statement hash.

Runs entirely on in-memory copies of the manuscript; nothing on disk is
modified. Exit non-zero on failure.

Usage:
    python3 scripts/hygiene_test.py [manuscript/MSEilenberg.tex]
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import hash_blocks as hb  # noqa: E402
import ingest  # noqa: E402

FAILURES = []


def check(name, condition, detail=""):
    status = "PASS" if condition else "FAIL"
    print(f"[{status}] {name}" + (f" -- {detail}" if detail and not condition else ""))
    if not condition:
        FAILURES.append(name)


def runs(text):
    """(hash_blocks anchors, ingest registry) for a source string."""
    clean = hb.strip_comments(text)
    sections = [(m.start(), m.group(1).strip()) for m in ingest.SECTION_RE.finditer(clean)]
    return hb.hash_map(text), ingest.collect_blocks(clean, sections)


def main(argv):
    path = Path(argv[0]) if argv else Path("manuscript/MSEilenberg.tex")
    text = path.read_text(encoding="latin1")

    base_hashes, base_reg = runs(text)
    check("baseline has anchors", len(base_hashes) > 0, str(len(base_hashes)))

    # --- Test 1: inserted comment / shifted lines change nothing. ---
    shifted = "% seeded shift line 1\n" + text
    shifted = shifted.replace(
        "\\section{Preliminaries.}",
        "\\section{Preliminaries.}\n\nInserted expository sentence between blocks.",
        1,
    )
    sh_hashes, sh_reg = runs(shifted)
    check("line shift: no hash changes", sh_hashes == base_hashes)
    check("line shift: no added/removed anchors", set(sh_hashes) == set(base_hashes))
    check(
        "line shift: registry IDs stable and ordered",
        [b["id"] for b in sh_reg] == [b["id"] for b in base_reg],
    )

    # --- Test 2: editing one definition body changes only that block. ---
    m = re.search(r"\\begin\{definition\}", text)
    insert_at = text.index("\\end{definition}", m.start())
    edited = text[:insert_at] + " SEEDEDEDIT." + text[insert_at:]
    ed_hashes, ed_reg = runs(edited)
    changed = {k for k in base_hashes if base_hashes[k] != ed_hashes.get(k)}
    check(
        "locality: exactly one anchor changes",
        len(changed) == 1,
        f"changed={sorted(changed)}",
    )
    first_def_id = next(
        b["id"] for b in base_reg if b.get("kind") == "definition"
    )
    check(
        "locality: the edited block is the first definition",
        changed == {first_def_id},
        f"changed={sorted(changed)} expected={first_def_id}",
    )
    check(
        "locality: registry IDs stable",
        [b["id"] for b in ed_reg] == [b["id"] for b in base_reg],
    )
    check(
        "locality: labels stable",
        [b["label"] for b in ed_reg] == [b["label"] for b in base_reg],
    )

    # --- Test 3: re-ingestion identity after an edit. ---
    base_ids = [b["id"] for b in base_reg]
    ed_ids = [b["id"] for b in ed_reg]
    check("re-ingestion: same IDs, same order", base_ids == ed_ids)
    base_conf = sum(1 for b in base_reg if b["status"] == "confirmed")
    ed_conf = sum(1 for b in ed_reg if b["status"] == "confirmed")
    check("re-ingestion: confirmed count stable", base_conf == ed_conf)

    # --- Test 4: editing a proof leaves the statement hash alone. ---
    clean = hb.strip_comments(text)
    pm = re.search(r"\\begin\{proof\}", clean)
    if pm:
        pend = clean.index("\\end{proof}", pm.start())
        pedited = clean[:pend] + " SEEDEDPROOFEDIT." + clean[pend:]
        _pe_hashes, pe_reg = runs(pedited)
        proof_line = clean.count("\n", 0, pm.start()) + 1
        owner = next((b for b in base_reg if b.get("proof_line") == proof_line), None)
        if owner:
            stmt_before = next(b["body_hash"] for b in base_reg if b["id"] == owner["id"])
            stmt_after = next(b["body_hash"] for b in pe_reg if b["id"] == owner["id"])
            check(
                "proof edit: statement hash unchanged",
                stmt_before == stmt_after,
                owner["id"],
            )
        else:
            check("proof edit: owner block located", False, f"line {proof_line}")
    else:
        check("proof edit: a proof exists to edit", False)

    print()
    if FAILURES:
        print(f"hygiene_test: {len(FAILURES)} FAILED: {', '.join(FAILURES)}")
        return 1
    print("hygiene_test: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
