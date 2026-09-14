#!/usr/bin/env python3
"""Cross-reference blast-radius checker.

Architecture.md Sections 12.1 and 13.3 item 2: before treating an edit as
local to one block, check whether any other block cites the edited block, by
``\\ref``/``\\cref`` *or by name in prose*. Missing such a citation silently
changes another block's hash.

Modes:
    python3 scripts/check_crossrefs.py --audit FILE
        Report undefined references, unused labels, and cross-section
        references (a label defined in one section, cited in another).

    python3 scripts/check_crossrefs.py --who "NAME" FILE ...
        List every occurrence of NAME (a label, a macro, or a prose term)
        with its surrounding section, for use before an edit.

Prose-name detection is deliberately over-inclusive (Section 12.1): a hit is
a candidate edge for author confirmation, not a confirmed dependency.
"""
from __future__ import annotations

import re
import sys

SECTION_RE = re.compile(r"\\section\{((?:[^{}]|\{[^{}]*\})*)\}")
LABEL_RE = re.compile(r"\\label\{([^}]*)\}")
REF_RE = re.compile(r"\\(?:c?ref|eqref|autoref|nameref)\{([^}]*)\}")


def section_at(sections, offset):
    name = "<preamble>"
    for start, title in sections:
        if start <= offset:
            name = title
        else:
            break
    return name


def line_of(text, offset):
    return text.count("\n", 0, offset) + 1


def audit(path):
    with open(path, "r", encoding="latin1") as fh:
        text = fh.read()
    sections = [(m.start(), m.group(1).strip()) for m in SECTION_RE.finditer(text)]

    labels = {}
    for m in LABEL_RE.finditer(text):
        labels.setdefault(m.group(1), (line_of(text, m.start()), section_at(sections, m.start())))

    refs = []
    for m in REF_RE.finditer(text):
        refs.append(
            (
                m.group(1),
                line_of(text, m.start()),
                section_at(sections, m.start()),
            )
        )

    problems = 0
    used_labels = set()
    for target, line, sec in refs:
        if target not in labels:
            print(f"UNDEFINED ref {{{target}}} at line {line} (section: {sec})")
            problems += 1
            continue
        used_labels.add(target)
        def_line, def_sec = labels[target]
        if def_sec != sec:
            print(
                f"CROSS-SECTION ref {{{target}}} used at line {line} "
                f"(section: {sec}); defined at line {def_line} (section: {def_sec})"
            )

    for label, (line, sec) in labels.items():
        if label not in used_labels:
            print(f"UNUSED label {{{label}}} at line {line} (section: {sec})")

    print(
        f"\ncheck_crossrefs: {len(labels)} labels, {len(refs)} refs, "
        f"{problems} undefined",
        file=sys.stderr,
    )
    return 1 if problems else 0


def who(term, paths):
    pattern = re.compile(re.escape(term))
    for path in paths:
        with open(path, "r", encoding="latin1") as fh:
            text = fh.read()
        sections = [
            (m.start(), m.group(1).strip()) for m in SECTION_RE.finditer(text)
        ]
        for m in pattern.finditer(text):
            print(
                f"{path}:{line_of(text, m.start())}: "
                f"[{section_at(sections, m.start())}] "
                + text[m.start() : m.start() + 60].splitlines()[0]
            )
    return 0


def main(argv):
    if not argv:
        print(__doc__.strip(), file=sys.stderr)
        return 2
    if argv[0] == "--audit":
        return audit(argv[1]) if len(argv) > 1 else 2
    if argv[0] == "--who":
        if len(argv) < 2:
            return 2
        return who(argv[1], argv[2:])
    print(__doc__.strip(), file=sys.stderr)
    return 2


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
