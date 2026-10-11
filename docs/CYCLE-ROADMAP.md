# Cycle Process Roadmap (C2–C4)

Design reference for cycles after C1. **Do not implement from this file.**
Each cycle gets its own `NEXT.md` with atomic tasks and acceptance criteria.

## Normative terminology

- Cycle (formerly Sprint).
- Cycle ID `C<N>`.
- `NEXT.md` at repo root is the active plan.
- `.cycle_state.json` is the source of truth for cycle state.
- Process files: `cycle/BACKLOG.org`, `cycle/CYCLE-HISTORY.org`,
  `cycle/DEVELOPMENT-CYCLE.md`.
- Immutable governance: `AGENTS.md`, `docs/cycle/RULES.md`, `docs/cycle/PROMPT.md`.

## Commit convention

```
<type>(<scope>): <description> [C<N>] [Xsp] [#item]
```

`[C<N>]` is required. Legacy `[S<N>]` is rejected.

## C2 — The Enforcer

- `.cycle_state.json` plus JSON schema.
- Formal state machine: `PLANNING → ACTIVE → CLOSING → ARCHIVED`.
- `bin/cycle/validate-commit.sh`: regex commit validation; strict quoting with
  **no `eval`** (neutralize injection from commit messages); explicit rejection
  of `[S<N>]`; validate Cycle ID against `.cycle_state.json` or `git log`.
- Cycle-closure logic: fail commits when no cycle is active, but permit recovery
  via `--recovery` or `git config cycle.bypass true`.
- Checksum verification of governance files.
- `bin/cycle/local-ci.sh`: single pass over regex + state + checksums + schema.

## C3 — Lifecycle

- `cycle-start`: fail if `NEXT.md` exists; prompt for cycle type; generate
  `NEXT.md` with `C<N>`; init `CYCLE-HISTORY.org`.
- `cycle-close`: verify completion; archive `NEXT.md`; verify archival; delete
  `NEXT.md`.
- `cycle-reset`: emergency recovery, requires `--force`.
- All lifecycle commands must be idempotent.

## C4 — The Orchestrator

- MCP server. File access restricted to `cycle/` plus root `NEXT.md`,
  `BACKLOG.org`, `.cycle_state.json`.
- State tools: `get_current_context`, `get_cycle_metrics`.
- Mutation tools: `mark_item_complete`, `add_to_next`, `log_cycle_event` — with
  `flock`, sanitization, and state constraints (e.g. no `add_to_next` while
  `CLOSING`).
- Intelligence tool: `analyze_backlog_priority` with blocked-item detection.

## Open questions to resolve before C2

- Enforcement must not rely solely on client-side hooks — decide the
  server-side/CI fallback.
- `local-ci.sh` overlaps `tests/git-pre-commit` and `tests/run_tests.sh`; fold them
  into one owner instead of duplicating (see "one owner per behavior").
- Confirm whether `NEXT.md` is itself immutable, since every cycle edits it.
