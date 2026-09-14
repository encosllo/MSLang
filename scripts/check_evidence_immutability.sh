#!/usr/bin/env bash
# Evidence immutability check (Architecture.md Section 10.5).
#
# An evidence record must never be edited after creation, only superseded by a
# new record with a new ID. With real git history that rule is enforceable:
# any staged change that modifies, deletes, renames, or copies over an
# existing file under evidence/ is a policy violation. Pure additions are
# allowed.
#
# Usable standalone (checks the index) or as the pre-commit hook.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

violations="$(git -C "$ROOT" diff --cached --name-status --diff-filter=MDRC -- evidence/ 2>/dev/null || true)"

if [ -n "$violations" ]; then
  echo "evidence-immutability: commit rejected." >&2
  echo "Existing evidence records must never be edited; supersede with a new record." >&2
  echo "Offending paths (status  path):" >&2
  echo "$violations" >&2
  exit 1
fi

exit 0
