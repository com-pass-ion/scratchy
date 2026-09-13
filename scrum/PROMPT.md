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
6. After sprint, discuss findings with user and add action items to `scrum/BACKLOG.org`
7. Test strategy: verify functionality, not just code presence
8. When adding packages with system deps, update `install_emacs_config_dependencies.sh`
9. On token/context limits: STOP, commit, log state, start fresh
10. Keep prompts simple for 32B models — break work into atomic units
11. Never modify RULES.md, SCRUM-WORKFLOW.md, or PROMPT.md without explicit approval
12. User selects sprint items — agent suggests, user approves
13. Planning Poker: Agent suggests SP estimates, user confirms or suggests own estimates
14. Use commit convention: `<type>(<scope>): <desc> [S<N>] [Xsp] [#item]`

## Key Commands

- Run tests: `./test/run_tests.sh`
- Open config: `src/init.el`
