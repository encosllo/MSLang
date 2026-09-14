#!/usr/bin/env python3
"""Schema validation for evidence records and the journal (Architecture.md
Sections 7.2, 10.4; roadmap Phase 2).

Implemented without third-party dependencies (the environment has neither
``jsonschema`` nor ``PyYAML`` installed) so the check always runs locally. It
supports the JSON-Schema subset used by ``schemas/*.json``:

    type, required, properties, additionalProperties (bool), enum, pattern,
    minItems, items, format (date-time)

An unknown key or missing required field is a hard error, never silently
ignored (Section 7.2: "evidence whose metadata the tooling does not parse is
not evidence").

*.json* evidence records are validated directly. YAML records are validated
only if a YAML parser is importable; otherwise they are reported as unvalidated,
not as passing.

Usage:
    python3 scripts/validate_records.py
    python3 scripts/validate_records.py --journal journal/events.jsonl \
        --evidence-dir evidence --schemas schemas
    python3 scripts/validate_records.py --self-test
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

DATE_TIME_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})$")

TYPE_CHECKS = {
    "object": lambda v: isinstance(v, dict),
    "array": lambda v: isinstance(v, list),
    "string": lambda v: isinstance(v, str),
    "integer": lambda v: isinstance(v, int) and not isinstance(v, bool),
    "number": lambda v: isinstance(v, (int, float)) and not isinstance(v, bool),
    "boolean": lambda v: isinstance(v, bool),
    "null": lambda v: v is None,
}


def validate(instance, schema, path="$"):
    """Return a list of human-readable validation errors."""
    errors = []
    if not isinstance(schema, dict):
        return errors

    stype = schema.get("type")
    if stype:
        types = stype if isinstance(stype, list) else [stype]
        if not any(TYPE_CHECKS.get(t, lambda _v: True)(instance) for t in types):
            errors.append(f"{path}: expected {stype}, got {type(instance).__name__}")
            return errors

    if "enum" in schema and instance not in schema["enum"]:
        errors.append(f"{path}: {instance!r} not in enum {schema['enum']}")

    if isinstance(instance, str):
        if "pattern" in schema and not re.search(schema["pattern"], instance):
            errors.append(f"{path}: {instance!r} does not match {schema['pattern']!r}")
        if schema.get("format") == "date-time" and not DATE_TIME_RE.match(instance):
            errors.append(f"{path}: {instance!r} is not an RFC3339 date-time")

    if isinstance(instance, list):
        if "minItems" in schema and len(instance) < schema["minItems"]:
            errors.append(f"{path}: requires at least {schema['minItems']} item(s)")
        item_schema = schema.get("items")
        if item_schema:
            for i, item in enumerate(instance):
                errors += validate(item, item_schema, f"{path}[{i}]")

    if isinstance(instance, dict):
        for key in schema.get("required", []):
            if key not in instance:
                errors.append(f"{path}: missing required key {key!r}")
        props = schema.get("properties", {})
        for key, value in instance.items():
            if key in props:
                errors += validate(value, props[key], f"{path}.{key}")
            elif schema.get("additionalProperties") is False:
                errors.append(f"{path}: unknown key {key!r}")
    return errors


def load_json(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def load_yaml(path):
    try:
        import yaml  # type: ignore
    except Exception:
        return None
    with open(path, "r", encoding="utf-8") as fh:
        return yaml.safe_load(fh)


def check_journal(path, schema):
    errors = []
    n = 0
    for i, line in enumerate(Path(path).read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip():
            continue
        n += 1
        try:
            event = json.loads(line)
        except json.JSONDecodeError as exc:
            errors.append(f"{path}:{i}: invalid JSON ({exc})")
            continue
        errors += [f"{path}:{i}: {e}" for e in validate(event, schema)]
    return n, errors


def check_evidence_dir(directory, schema):
    errors = []
    validated = 0
    skipped = []
    directory = Path(directory)
    if not directory.is_dir():
        return validated, skipped, errors
    for path in sorted(directory.glob("*")):
        if path.suffix == ".json":
            try:
                record = load_json(path)
            except Exception as exc:
                errors.append(f"{path}: cannot parse ({exc})")
                continue
        elif path.suffix in (".yaml", ".yml"):
            record = load_yaml(path)
            if record is None:
                skipped.append(str(path))
                continue
        else:
            continue
        validated += 1
        errors += [f"{path}: {e}" for e in validate(record, schema)]
    return validated, skipped, errors


def self_test(schema):
    """Ensure the validator actually rejects malformed records."""
    problems = []
    good = {
        "evidence_id": "E-000001",
        "layer": "review",
        "block": "B-D001",
        "inputs": [{"artifact": "B-D001/informal_statement", "hash": "a" * 64}],
        "environment": {"lean": "v4.33.1", "mathlib": "0df444a"},
        "producer": {"kind": "agent", "role": "reviewer"},
        "outcome": "pass",
        "timestamp": "2026-09-14T09:00:00Z",
    }
    if validate(good, schema):
        problems.append(f"valid record rejected: {validate(good, schema)}")
    bad = dict(good)
    bad["block"] = "B-0142"  # old numeric pattern must now be rejected
    if not validate(bad, schema):
        problems.append("old-style numeric block id was not rejected")
    bad2 = dict(good)
    bad2["typo_field"] = 1
    if not validate(bad2, schema):
        problems.append("unknown key was not rejected")
    bad3 = dict(good)
    del bad3["inputs"]
    if not validate(bad3, schema):
        problems.append("missing required key was not rejected")
    return problems


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("--schemas", default="schemas")
    ap.add_argument("--journal", default="journal/events.jsonl")
    ap.add_argument("--evidence-dir", default="evidence")
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args(argv)

    schemas = Path(args.schemas)
    ev_schema = load_json(schemas / "evidence.schema.json")
    jr_schema = load_json(schemas / "journal_event.schema.json")
    errors = []

    if args.self_test:
        problems = self_test(ev_schema)
        if problems:
            for p in problems:
                print(f"FAIL {p}")
            return 1
        print("validate_records: self-test passed (validator rejects bad records)")

    n_events, jerrors = check_journal(args.journal, jr_schema)
    errors += jerrors
    n_ev, skipped, eerrors = check_evidence_dir(args.evidence_dir, ev_schema)
    errors += eerrors

    print(f"validate_records: {n_events} journal events, {n_ev} evidence records")
    if skipped:
        print(
            f"validate_records: {len(skipped)} YAML record(s) skipped (no YAML "
            f"parser): {', '.join(skipped)}"
        )
    for e in errors:
        print(f"ERROR {e}")
    if errors:
        return 1
    print("validate_records: all records valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
