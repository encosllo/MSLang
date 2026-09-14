# scripts/env.sh -- project environment for MSLang.
#
# Source at the start of every session:   . scripts/env.sh
# See Architecture.md Sections 10.6 (bootstrap items 2-3) and 15.3.
#
# The Lean toolchain and Mathlib cache for this project live under
# "$ELAN_HOME" inside the repository and are NEVER shared with another
# project. Sharing a mutable cache has destroyed shared state in practice
# (Architecture.md Section 15.3), so do not point ELAN_HOME anywhere else.

MSLANG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
export MSLANG_ROOT

# --- Pinned versions (bootstrap item 3) -------------------------------------
# Native arm64 toolchain; see STATE.md for the clean-build baseline.
export LEAN_VERSION="leanprover/lean4:v4.33.1"
# Fixed when lean/ is bootstrapped (bootstrap item 4); record it here and in
# STATE.md, then update the Lake manifest to match.
export MATHLIB_REV="TBD"

# --- Isolated toolchain home (bootstrap items 1-2) --------------------------
export ELAN_HOME="$MSLANG_ROOT/.elan"
if [ -x "$ELAN_HOME/bin/elan" ]; then
  case ":$PATH:" in
    *":$ELAN_HOME/bin:"*) ;;
    *) export PATH="$ELAN_HOME/bin:$PATH" ;;
  esac
else
  echo "[env.sh] project-local toolchain not installed at $ELAN_HOME" >&2
  echo "[env.sh] bootstrap item 4 pending; using fallback elan on PATH" >&2
fi

# --- Manuscript toolchain ---------------------------------------------------
export TEXINPUTS="$MSLANG_ROOT/manuscript:${TEXINPUTS:-}"
export BIBINPUTS="$MSLANG_ROOT/manuscript:${BIBINPUTS:-}"

# Convenient entry points.
export MSLANG_MANUSCRIPT="$MSLANG_ROOT/manuscript/MSEilenberg.tex"
