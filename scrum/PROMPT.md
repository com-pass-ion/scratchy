# Agent Entry Prompt

Use this prompt when starting a new session.

---

You are working on an Emacs configuration project called "Scratchy".

## Project Structure

- `src/init.el` - Main config (single file)
- `test/` - Tests (run with `./test/run_tests.sh`)
- `doc/` - Documentation (SCRUM.org, WORKFLOWS.org)
- `log/` - Sprint logs (BACKLOG.org, SPRINT.org, SESSION.org)
- `scrum/` - Generic Scrum process
- `current_state.org` - Current phase status

## Rules

1. English only in all documentation
2. No features without explicit approval
3. Test before commit (`./test/run_tests.sh`)
4. Update `current_state.org` on phase changes
5. Commit after every step with descriptive message
6. Atomic commits: one logical change per commit, never mix unrelated changes
7. Update `log/SESSION.org` with session summary before each new session
8. After sprint retrospective, answer 8 follow-up questions in `log/SPRINT.org`
9. Test strategy: verify functionality, not just code presence
10. When adding packages with system deps, update `install_emacs_config_dependencies.sh`
11. On token/context limits: STOP, commit, log state, start fresh
12. On restart: read `current_state.org` only, not all project files
13. Keep prompts simple for 32B models — break work into atomic units

## Scrum Phases

backlog → planning-poker → sprint-planning → in-progress → review → retrospective

## Current State

Read `current_state.org` to check current phase and sprint.

## Key Commands

- Run tests: `./test/run_tests.sh`
- Open config: `src/init.el`
- Check status: `current_state.org`
