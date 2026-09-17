# Tasks

## 1. Goal set store

- [x] 1.1 Relax `validate` in `scripts/ranking.py` to accept one or more goals
  (remove the at-most-one error); verify `ranking.py --check` still passes on the
  current one-entry-example-free store and a multi-goal fixture validates.
- [x] 1.2 Extend the CLI with `--set-goal` add/update and `--remove-goal
  --block ...`, author-reserved; verify `ranking_test.py` covers adding two
  goals, removing one, and an agent refusal.

## 2. Forward rank over the goal set

- [x] 2.1 Compute restart mass over the designated goal set and rank the union
  of their ancestor sets; verify a fixture with two overlapping goals recommends
  a shared prerequisite and never a terminal goal (a goal that is a prerequisite
  of another may be recommended).
- [x] 2.2 Verify a block outside the union is not ranked.

## 3. Per-goal breakdown

- [x] 3.1 Report, for each ranked block, the designated goals it contributes to;
  verify a fixture shows a block belonging to both goals.

## 4. Report, drift, and integration

- [x] 4.1 Regenerate `reports/ranking.md` for the goal-set shape; verify it
  shows the goal set, the shared recommendation, and the per-goal column.
- [x] 4.2 Run `scripts/check_all.sh --fast` (ranking report drift check
  included) and verify it passes.
- [x] 4.3 Record the author's goal set (the two Eilenberg theorems) with
  `ranking.py --set-goal` and verify the report names a next step; this is an
  author decision (attributed to `author:<session>`).
