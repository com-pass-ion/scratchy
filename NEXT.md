# NEXT: C1 — Scrum → Cycle Migration

Status: READY · Est: 6sp · Do tasks in order. One commit per task.
STOP and report on the first failing command. Do not improvise around failures.

## Facts (verify, do not assume)

- `git status` shows `scrum/*` deleted and `cycle/` untracked.
- `cycle/` files are byte-identical to committed `scrum/` files (safe to `git mv`).
- No `.cycle_state.json`, no `cycle/bin/`, no installed hooks (only `*.sample`).
- C2–C4 design lives in `doc/CYCLE-ROADMAP.md` — do NOT implement it here.

## Definition of Done

- [ ] T1  Renames recorded with `git mv` (history preserved).
- [ ] T2  `cycle/` governance docs use Cycle terminology; `[C<N>]` required, `[S<N>]` banned.
- [ ] T3  No `scrum/` references remain (see check in T3).
- [ ] T4  Guard targets `AGENTS.md cycle/RULES.md cycle/PROMPT.md`; hook installed and blocks a staged governance edit.
- [ ] T5  `./test/run_tests.sh functional` passes.

## T1 — Record renames (2sp)

```
rm -rf cycle
git restore scrum
git mv scrum cycle
git mv cycle/SCRUM-WORKFLOW.md cycle/DEVELOPMENT-CYCLE.md
git mv cycle/SPRINT.org cycle/CYCLE-HISTORY.org
```

Check: `git status --short` shows `R ` (rename) entries for the five files.
Commit: `docs(cycle): rename scrum directory to cycle preserving history [C1] [2sp]`

## T2 — Cycle terminology (1sp)

Edit these files:

- `cycle/RULES.md` — title → "Cycle Rules for Agents"; `scrum/` → `cycle/`;
  `SCRUM-WORKFLOW.md` → `DEVELOPMENT-CYCLE.md`; `## Sprint` → `## Cycle`;
  commit examples `[S13]` → `[C13]`; add line: legacy `[S<N>]` is forbidden.
- `cycle/PROMPT.md` — `scrum/` → `cycle/`; convention `[C<N>]`; rule 10 file
  list → `RULES.md, DEVELOPMENT-CYCLE.md, PROMPT.md`; "sprint" → "cycle".
- `cycle/DEVELOPMENT-CYCLE.md` — rewrite fully in Cycle terms (was Scrum Workflow).
- `cycle/CYCLE-HISTORY.org` — title → "Cycle Velocity"; header `Sprint` → `Cycle`.
- `AGENTS.md` — protect cycle artifacts `RULES.md, PROMPT.md, DEVELOPMENT-CYCLE.md`.

Check: `grep -rniE 'scrum-|\[S<N>\]|\[S[0-9]+\]' cycle/ AGENTS.md` → empty.
Commit: `docs(cycle): rewrite process docs in cycle terminology [C1] [1sp]`

## T3 — Sweep references (1sp)

Replace `scrum/` → `cycle/` and `SCRUM-WORKFLOW.md` → `DEVELOPMENT-CYCLE.md` in:

- `test/test_init.el` (assertions 31.3/31.4/31.5 and section heading)
- `test/run_tests.sh` (comment "Scrum Document Safety Guard")
- `test/validate_process_files.sh` (paths handled in T4; comment here)
- `doc/agent-prompts.org`, `doc/IMPLEMENTATION-STRATEGY.md`, `doc/SCRUM.org`,
  `doc/scratchy_testing_strategy.org`
- `cycle/BACKLOG.org`

Check (must print nothing):
```
grep -rn "scrum/" --exclude-dir=.git . | grep -v -e NEXT.md -e CYCLE-ROADMAP.md
```
Commit: `docs(cycle): sweep scrum references to cycle paths [C1] [1sp]`

## T4 — Retarget guard + install hook (1sp)

1. `test/validate_process_files.sh`:
   `PROCESS_FILES=( "AGENTS.md" "cycle/RULES.md" "cycle/PROMPT.md" )`
   and update the header comment + error message to "Cycle Document Safety".
2. Add files: `git add AGENTS.md scripts/setup-hooks.sh test/validate_process_files.sh`
3. Commit: `chore(cycle): retarget safety guard and install pre-commit hook [C1] [1sp]`
4. Install: `bash scripts/setup-hooks.sh`
5. Prove it blocks (must fail, then clean up):
```
printf '\n# test\n' >> cycle/RULES.md
git add cycle/RULES.md
git commit -m "test [C1]"      # EXPECT: blocked by validate_process_files.sh
git restore --staged --worktree cycle/RULES.md
```

## T5 — Tests (1sp)

```
./test/run_tests.sh functional
```

Do not run the `absolute` tier: it shells out to `sudo apt-get` and builds Emacs
from source. This migration touches no toolchain files.

Fix fallout, then commit: `test(cycle): fix path assertions after rename [C1] [1sp]`

## Out of scope (later cycles)

C2 Enforcer, C3 Lifecycle, C4 Orchestrator. See `doc/CYCLE-ROADMAP.md`.
