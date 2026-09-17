# Tasks

## 1. Goal store and tooling

- [x] 1.1 Add `blocks/ranking.json` with the documented shape (a `note` plus a
  `goals` map keyed by goal block, each entry carrying `decided_by` and
  `rationale`); verify `python3 scripts/ranking.py --check` passes on the empty
  store.
- [x] 1.2 Implement `scripts/ranking.py` store commands (`--set-goal`,
  `--list`, `--check`), mirroring `scripts/scope.py` and refusing any
  `decided_by` not beginning with `author:`; verify via 1.3.
- [x] 1.3 Add `scripts/ranking_test.py` covering a valid goal, an invalid target,
  and an agent `decided_by` refusal; verify the test file runs green.
- [x] 1.4 Register the store check in `scripts/check_all.sh`; verify
  `scripts/check_all.sh --fast` reports it and passes.

## 2. Weighted graph

- [x] 2.1 Implement edge loading (all confirmed and candidate edges) with a
  source weight (`explicit` above `symbol`) and exclusion of edges disposed
  `type-carrier` or `simplification`; verify a unit test asserts the weight
  ordering and the exclusion.
- [x] 2.2 Verify the ranking is advisory: a test asserts that running it writes
  no closure, layer status, or evidence record.

## 3. Goal proposal (reverse rank)

- [x] 3.1 Implement reverse PageRank on the impact graph with restart mass over
  result-bearing blocks; verify determinism and that the shortlist contains the
  manuscript's headline results.
- [x] 3.2 Report the ranked shortlist and mark the goal undecided when no goal
  is designated; verify the report states it does not adopt the top candidate
  automatically.

## 4. Next step (forward rank)

- [x] 4.1 Implement ancestor restriction and target-conditioned forward
  PageRank with the goal excluded; verify a fixture recommends a prerequisite
  rather than the goal.
- [x] 4.2 Implement `done` and `ready`; verify a block with an undone dependency
  is reported not ready and is not recommended.
- [x] 4.3 Verify a block outside the goal's transitive ancestor set is not
  ranked.

## 5. Report and drift check

- [x] 5.1 Generate `reports/ranking.md` showing the shortlist, the designated
  goal, the ranked ancestors with readiness, the recommended next step, and the
  stated `done`/`ready` predicate and edge weighting; verify the regenerated
  report contains each section.
- [x] 5.2 Add a `--check-report` drift check; verify a manual edit fails the
  check and regeneration makes it pass.

## 6. Determinism, integration, and real run

- [x] 6.1 Verify two runs on unchanged inputs produce an identical ranking and
  recommendation, and that an unresolved edge entering the walk is named rather
  than dropped.
- [x] 6.2 Wire the ranking tests, store check, and report drift check into
  `scripts/check_all.sh`; verify `scripts/check_all.sh --fast` passes.
- [x] 6.3 Run `scripts/ranking.py` on the project with the current graph; verify
  a buildable recommendation is produced and `git status` shows only the
  intended ranking artifacts changed.
