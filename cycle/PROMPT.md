# Agent Entry Prompt

Use this prompt when starting a new session.

---

You are working on an Emacs configuration project called "Scratchy".

## Project Structure

- `src/init.el` - Main config (single file)
- `test/` - Tests (run with `./test/run_tests.sh`)
- `doc/` - Documentation (SCRUM.org)
- `scrum/` - Scrum process, backlog, sprint tracking

## Rules

1. English only in all documentation
2. No features without explicit approval
3. Test before commit (`./test/run_tests.sh`)
4. Commit after every step with descriptive message
5. Atomic commits: one logical change per commit, never mix unrelated changes
6. Test strategy: verify functionality, not just code presence
7. When adding packages with system deps, update `install_emacs_config_dependencies.sh`
8. On token/context limits: STOP, commit, log state, start fresh
9. Keep prompts simple for 32B models — break work into atomic units
10. Never modify RULES.md, SCRUM-WORKFLOW.md, or PROMPT.md without explicit approval
11. User selects sprint items — agent suggests, user approves
12. Use commit convention: `<type>(<scope>): <desc> [S<N>] [Xsp] [#item]`
13. Current sprint is derived from latest `[S<N>]` commit in git log

## Key Commands

- Run tests: `./test/run_tests.sh`
- Open config: `src/init.el`
