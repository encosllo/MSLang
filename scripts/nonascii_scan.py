#!/usr/bin/env python3
"""Non-ASCII scanner for legacy-encoded (latin1) TeX sources.

Architecture.md Sections 10.6 item 5 and 13.3 item 3.

The manuscript declares ``\\usepackage[latin1]{inputenc}``. Under that
declaration a genuine latin1 accent (a single byte > 0x7F, e.g. 0xF3 for
o-acute) is expected and fine. The dangerous case is a character the editor
inserted as *UTF-8*: a smart quote, an em-dash, a non-breaking space. Those
arrive as a valid multi-byte UTF-8 sequence, which latin1 inputenc then
renders as two or three garbage characters while the compiler may still exit
with no ``!``-prefixed error.

So this scanner flags bytes that form a *valid UTF-8 multi-byte sequence*
and treats lone high bytes as expected latin1. Exit code is non-zero when
suspicious sequences are found, so it can gate a build or a pre-commit hook.

Usage:
    python3 scripts/nonascii_scan.py FILE [FILE ...]
    python3 scripts/nonascii_scan.py --all FILE   # also list latin1 bytes
         python3 scripts/nonascii_scan.py --json FILE
"""
from __future__ import annotations

import json
import sys


def scan(data: bytes):
    """Return (suspicious, latin1) lists of (offset, byte, length|None)."""
    suspicious = []
    latin1 = []
    i = 0
    n = len(data)
    while i < n:
        b = data[i]
        if b < 0x80:
            i += 1
            continue
        # Try to decode a valid UTF-8 multi-byte sequence here.
        length = None
        if 0xC2 <= b <= 0xDF:
            length = 2
        elif 0xE0 <= b <= 0xEF:
            length = 3
        elif 0xF0 <= b <= 0xF4:
            length = 4
        if length and i + length <= n:
            chunk = data[i : i + length]
            try:
                chunk.decode("utf-8")
            except UnicodeDecodeError:
                pass  # not a valid sequence; fall through to latin1
            else:
                suspicious.append((i, chunk))
                i += length
                continue
        latin1.append((i, b))
        i += 1
    return suspicious, latin1


def line_col(data: bytes, offset: int) -> tuple[int, int]:
    line = data.count(b"\n", 0, offset) + 1
    last = data.rfind(b"\n", 0, offset)
    col = offset - last
    return line, col


def main(argv: list[str]) -> int:
    show_all = "--all" in argv
    as_json = "--json" in argv
    files = [a for a in argv if not a.startswith("--")]
    if not files:
        print(__doc__.strip(), file=sys.stderr)
        return 2

    total_suspicious = 0
    report = []
    for path in files:
        with open(path, "rb") as fh:
            data = fh.read()
        suspicious, latin1 = scan(data)
        total_suspicious += len(suspicious)
        entries = []
        for off, chunk in suspicious:
            line, col = line_col(data, off)
            entries.append(
                {
                    "kind": "utf8",
                    "line": line,
                    "col": col,
                    "bytes": chunk.hex(" "),
                    "decoded": chunk.decode("utf-8", "replace"),
                }
            )
        if show_all:
            for off, b in latin1:
                line, col = line_col(data, off)
                entries.append(
                    {"kind": "latin1", "line": line, "col": col, "byte": hex(b)}
                )
        report.append({"file": path, "findings": entries})

    if as_json:
        print(json.dumps(report, indent=2))
    else:
        for item in report:
            for e in item["findings"]:
                if e["kind"] == "utf8":
                    print(
                        f"{item['file']}:{e['line']}:{e['col']}: "
                        f"UTF-8 character {e['decoded']!r} "
                        f"(bytes {e['bytes']}) -- will mojibake under latin1",
                        file=sys.stderr,
                    )
                else:
                    print(
                        f"{item['file']}:{e['line']}:{e['col']}: latin1 byte {e['byte']}",
                        file=sys.stderr,
                    )

    if total_suspicious:
        print(
            f"nonascii_scan: {total_suspicious} suspicious UTF-8 occurrence(s) found",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
