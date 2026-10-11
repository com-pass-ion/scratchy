# NEXT: C2 — The Enforcer

Status: PLANNED. Do tasks in order. One commit per task.
STOP and report on the first failing command. Do not improvise around failures.

## Goal

Turn the Cycle process from documentation into machine-enforced governance:
a state file, a commit validator, governance checksums, and one CI entry point
that also serves as the server-side fallback.

Source of truth for scope: `doc/CYCLE-ROADMAP.md` (C2). This file is the
actionable plan; that file is the design reference.

## Facts (verify, do not assume)

- `git log` latest marker is `[C1]`; no `[C2]` commit exists yet.
- No `.cycle_state.json`, no `cycle/bin/`, no `cycle/*schema*` on disk.
- Installed `.git/hooks/pre-commit` is a symlink to `test/git-pre-commit`.
- `test/git-pre-commit` selects a test tier and calls `test/run_tests.sh`.
- `test/run_tests.sh` fast tier already runs `test/validate_process_files.sh`.
- Immutable governance today: `AGENTS.md`, `cycle/RULES.md`, `cycle/PROMPT.md`.

## Decisions locked in this cycle (resolve roadmap open questions)

- **Server-side fallback**: the client git hook is advisory. `cycle/bin/local-ci.sh`
  is the single process-validation owner and the entry point a CI job must call.
  A bypassed hook (`--no-verify`) is caught by CI running the same script.
- **One owner per behavior**: process checks (regex + state + checksums + schema)
  live only in `cycle/bin/local-ci.sh` and the scripts it calls. `test/git-pre-commit`
  keeps its existing job (test-tier selection) and additionally calls `local-ci.sh`;
  it must not re-implement process checks. `test/validate_process_files.sh` stays the
  pre-commit governance guard and is invoked by `local-ci.sh`.
- **`NEXT.md` is mutable**: it is the working plan, edited every cycle. It is NOT
  added to the governance checksum set. Governance remains `AGENTS.md`,
  `cycle/RULES.md`, `cycle/PROMPT.md`.
- **Commit validation is a `commit-msg` hook**, not `pre-commit`, because only
  `commit-msg` can read the message. `scripts/setup-hooks.sh` installs both hooks.

## Definition of Done

- [ ] T1  `.cycle_state.json` exists, is valid JSON, and conforms to
      `cycle/cycle-state.schema.json`; state is `ACTIVE` for `C2`.
- [ ] T2  `cycle/governance.sha256` pins the three immutable files; `--check` fails
      on tamper and passes on clean tree.
- [ ] T3  `cycle/bin/validate-commit.sh` accepts conforming messages and rejects
      malformed ones, `[S<N>]`, and mismatched cycle IDs — with no `eval`.
- [ ] T4  Commits are blocked when no cycle is `ACTIVE`; `--recovery` and
      `git config cycle.bypass true` both unblock.
- [ ] T5  `cycle/bin/local-ci.sh` runs regex + state + checksums + schema in one
      pass; `commit-msg` and `pre-commit` hooks are installed and wired to it.
- [ ] T6  `./test/run_tests.sh functional` passes with new guard tests included.

## T1 — Cycle state file + schema (1sp)

Create `.cycle_state.json`:

```json
{
  "cycle_id": "C2",
  "state": "ACTIVE",
  "goal": "The Enforcer: machine-enforced cycle governance",
  "started": "2026-10-11"
}
```

Create `cycle/cycle-state.schema.json` (JSON Schema draft-07, `additionalProperties: false`):

- required: `cycle_id`, `state`, `goal`, `started`
- `cycle_id`: pattern `^C[0-9]+$`
- `state`: enum `["PLANNING", "ACTIVE", "CLOSING", "ARCHIVED"]`
- `started`: format `date`

Check (both must succeed):

```
python3 -c "import json;json.load(open('.cycle_state.json'))"
python3 -c "import json;json.load(open('cycle/cycle-state.schema.json'))"
```

Commit: `feat(cycle): add cycle state file and json schema [C2] [1sp]`

## T2 — Governance checksums (1sp)

Add `cycle/bin/governance-checksum.sh`:

- default: write `cycle/governance.sha256` for `AGENTS.md`, `cycle/RULES.md`,
  `cycle/PROMPT.md` (paths relative to repo root, `sha256sum` output format).
- `--check`: verify with `sha256sum -c`, exit non-zero on mismatch/missing.
- Resolve repo root from script location; no hardcoded absolute paths.

Check:

```
bash cycle/bin/governance-checksum.sh
bash cycle/bin/governance-checksum.sh --check     # passes
printf '\n' >> cycle/PROMPT.md
bash cycle/bin/governance-checksum.sh --check     # must FAIL
git restore cycle/PROMPT.md
```

Commit: `feat(cycle): pin governance files with sha256 checksums [C2] [1sp]`

## T3 — Commit message validator (2sp)

Add `cycle/bin/validate-commit.sh`:

- Input: path to a commit-message file (`$1`), as git passes to `commit-msg`.
- Convention regex: `^<type>(<scope>): <description> [C<N>] [Xsp] [#item]`
  where `[C<N>]` required, `[Xsp]`/`[#item]` optional, `<type>` from a fixed set
  (`feat|fix|docs|test|chore|refactor|style|perf|build|ci`).
- Reject `[S<N>]` explicitly with a distinct error.
- Validate `[C<N>]` against `.cycle_state.json` `cycle_id`; if absent, fall back to
  latest `[C<N>]` in `git log`.
- Ignore merge commits (`^Merge `) and comment lines (`^#`).
- **No `eval`.** Quote every expansion; treat the message strictly as data.
- `--recovery` / `git config cycle.bypass true` skip the state gate only, never the
  format check.

Check (fail cases must exit non-zero, pass cases zero):

```
bash cycle/bin/validate-commit.sh <(printf 'feat(lsp): add eglot [C2] [3sp] [#nix]\n')
bash cycle/bin/validate-commit.sh <(printf 'feat(lsp): add eglot [S2]\n')      # FAIL
bash cycle/bin/validate-commit.sh <(printf 'add eglot [C2]\n')                 # FAIL
bash cycle/bin/validate-commit.sh <(printf 'feat(lsp): add eglot [C1]\n')      # FAIL (id)
```

Commit: `feat(cycle): enforce commit convention without eval [C2] [2sp]`

## T4 — State gate + recovery (1sp)

Extend `validate-commit.sh` (or a `cycle/bin/require-active-cycle.sh` it calls):

- If `.cycle_state.json` `state` is not `ACTIVE`, fail with a clear message and the
  recovery instructions.
- `--recovery` flag and `git config cycle.bypass true` both bypass the gate.
- Bypass is logged to stderr with the cycle id and reason.

Check:

```
python3 - <<'PY'
import json,subprocess
p='.cycle_state.json'; d=json.load(open(p)); d['state']='CLOSING'; json.dump(d,open(p,'w'))
PY
bash cycle/bin/validate-commit.sh <(printf 'feat(x): y [C2]\n')                 # FAIL
bash cycle/bin/validate-commit.sh --recovery <(printf 'feat(x): y [C2]\n')      # pass
git restore --staged --worktree .cycle_state.json 2>/dev/null || true
```

Restore `state` to `ACTIVE` before continuing.

Commit: `feat(cycle): gate commits on active cycle with recovery [C2] [1sp]`

## T5 — Single CI owner + hooks (1sp)

Add `cycle/bin/local-ci.sh`: one pass over regex + state + checksums + schema.
It calls the scripts from T2–T4 and `python3` for schema validation; it exits on
first failure with a single summary. This is the server-side entry point.

Wire hooks:

- `test/git-pre-commit`: keep tier detection and `run_tests.sh`, prepend a call to
  `cycle/bin/local-ci.sh`. Do not duplicate its checks.
- Add `test/git-commit-msg` that calls `cycle/bin/validate-commit.sh "$1"`.
- `scripts/setup-hooks.sh`: install both `pre-commit` and `commit-msg` symlinks;
  resolve to absolute paths (same approach as the existing hook fix).

Check:

```
bash cycle/bin/local-ci.sh                    # passes
bash scripts/setup-hooks.sh
ls -l .git/hooks/pre-commit .git/hooks/commit-msg
bash test/git-commit-msg <(printf 'bad message\n')   # FAIL
```

Commit: `feat(cycle): add local ci entrypoint and commit-msg hook [C2] [1sp]`

## T6 — Tests + docs (1sp)

- Add `test/test_cycle_guards.sh`: table-driven pass/fail cases for
  `validate-commit.sh`, checksum `--check`, and state gating. Assert exit codes,
  not output text.
- Register it in `test/run_tests.sh` under the functional tier (Tier B).
- Update `cycle/DEVELOPMENT-CYCLE.md` with the state machine
  `PLANNING → ACTIVE → CLOSING → ARCHIVED`, the `local-ci.sh` owner note, and the
  two recovery paths. **Governance-adjacent: propose the diff and get user approval
  before editing** (`cycle/RULES.md` > Cycle Document Safety).

Check:

```
./test/run_tests.sh functional
```

Do not run the `absolute` tier: it shells out to `sudo apt-get` and builds Emacs
from source. C2 touches no toolchain files.

Commit: `test(cycle): cover commit and state guards [C2] [1sp]`

## Out of scope (later cycles)

C3 Lifecycle (`cycle-start`/`cycle-close`/`cycle-reset`), C4 Orchestrator (MCP
server). See `doc/CYCLE-ROADMAP.md`.
