# Cycle Rules for Agents

Quick reference of all rules to follow when working on this project.

## Language

- **English Only**: All documentation must be written in English

## Features

- **No Features Without Approval**: Only implement features when explicitly approved. Only add new items to backlog with confirmation.
- **Backlog Tasks: DONE not Deleted**: Tasks removed from backlog must be marked as DONE, not deleted

## Quality

- **Definition of Done**: All code must pass tests, be documented, and follow style guide. For configuration changes, passing the Absolute-Pass (Source Build + Compile) is required.
- **Test Before Commit**: Run `./tests/run_tests.sh` before committing
- **Commit After Every Step**: Commit after completing each task with descriptive message
- **Atomic Commits**: Each commit must be self-contained and reversible. One logical change per commit. Never mix unrelated changes (e.g., code fix + docs update) in a single commit.
- **Dependencies Required**: When adding packages with system dependencies, always update the installation script.
- **Dependency Gate**: Verify package availability and system dependencies during planning poker. Do not commit to a cycle item if its core dependencies are unverified.
- **Test Strategy**: Tests must verify functionality, not just code presence. Use feature tests (fboundp), state tests (bound-and-true-p), and integration tests (file open). Source code tests only for critical configs (font, keybindings).
- **Research Documents Exempt from Tests**: Documentation-only files in `docs/agent-research/` and similar research directories do not require test coverage. Research is documentation, not code.
- **Blueprint Requirement**: Research tasks must conclude with a "Prototype/Implementation Sketch" section. This transforms abstract findings into a concrete blueprint for future implementation.

## Agent Safety

- **Context Limits**: If session runs out of tokens or context becomes too large, STOP. Do not continue with partial work. Commit what exists, log state, and start fresh in a new session.
- **Session Restart Protocol**: On session restart, read `cycle/BACKLOG.org` first. Do not re-read all project files. Only read files needed for the current task.
- **Minimal Reads**: When resuming work, read only: `cycle/BACKLOG.org`, relevant task file, and max 2-3 supporting files. Do not batch-read the entire project.
- **Prompt Complexity**: Keep prompts simple and direct. Complex multi-step prompts fail on smaller models (32B). Break work into atomic units with clear stop conditions.
- **Fail-Safe Commits**: If any operation fails (edit, test, commit), stop immediately. Do not attempt workarounds that bypass the fail-safe. Commit partial progress and report.
- **Cycle Document Safety**: Never modify `docs/cycle/RULES.md` or `docs/cycle/PROMPT.md` without explicit user approval. These are process-defining files that affect all future sessions. Propose changes first, wait for confirmation.

## Coding Style

- **Pure Functional Style**: Prefer pure functions with no side effects. Use `let` for local bindings, avoid `setq` for global state. Functions should return values, not modify globals. Use `defconst` for constants, `defvar` for mutable state only when necessary.
- **No Hardcoded Absolute Paths**: Use relative paths or environment variables. Never hardcode `/home/ncu/...` or similar absolute paths in code, scripts, or configs.
- **Implementation Layer**: Implement each capability in exactly one layer — Elisp, a shell script, or a tool-native config file — following `docs/IMPLEMENTATION-STRATEGY.md` (one owner per behavior). Tool-native settings are never mirrored in Elisp; ship a default native config file (see `src/dotfiles/`) when defaults are needed.
- **No Elisp Wrappers Around Decoupled Designs**: Do not add Elisp functions that encapsulate data or wrap a design a tool already owns (init files, config files, native formats). Configure the tool through its own mechanism. Example: provide a default `.gdbinit` init file for GDB — do not write an Elisp function that overwrites the default.

## Cycle

- **Cycle Goal**: Each cycle must have a clear, measurable goal
- **User Selects Items**: The user must explicitly select which backlog items to include in each cycle. The agent may suggest items, but must wait for user approval before finalizing cycle planning.
- **Capacity**: 2-4 hours per session
- **Review Findings**: After cycle review, discuss findings with user and add action items to `cycle/BACKLOG.org`

### Workflow & Governance

1. **Pick items** from `cycle/BACKLOG.org`
2. **Work in atomic commits** with cycle markers
3. **Post-Cycle**: Discuss findings, add action items to `cycle/BACKLOG.org`
4. **Record** delivered story points in `cycle/CYCLE-HISTORY.org`

The cycle process is machine-enforced via git hooks and `bin/cycle/local-ci.sh`.

**State Machine**:
Cycles follow a formal state transition: `PLANNING` $\rightarrow$ `ACTIVE` $\rightarrow$ `CLOSING` $\rightarrow$ `ARCHIVED`
- **ACTIVE**: Commits are permitted.
- **Other**: Commits are blocked unless a recovery path is used.

**Recovery Paths**:
If a commit is required while the cycle is not `ACTIVE`:
1. **One-time**: Use the `--recovery` flag with the commit validator.
2. **Persistent**: Set `git config cycle.bypass true`.

**Local CI**:
`bin/cycle/local-ci.sh` is the single owner of process validation, orchestrating:
- State file schema validation.
- Governance checksum verification.
- Current cycle state gating.


## Commit Convention

Extend conventional commits with cycle metadata:
```
<type>(<scope>): <description> [C<N>] [Xsp] [#item]
```

- `[C<N>]` — Cycle number (required for cycle tracking)
- `[Xsp]` — Story point estimate (optional)
- `[#item]` — Backlog item reference (optional)

The legacy `[S<N>]` marker is forbidden; use `[C<N>]`.

Examples:
```
feat(lsp): add eglot for nix-mode [C13] [3sp] [#nix-lsp]
fix(debug): correct gdb binary path [C13] [1sp]
chore(deps): add ripgrep to installer [C13] [1sp]
docs(cycle): remove kanban process [C13] [1sp]
```

## File Locations

| File | Purpose |
|------|---------|
| `cycle/BACKLOG.org` | Product backlog with all planned items |
| `docs/SCRUM.org` | Technical specification and workflow |
| `docs/cycle/RULES.md` | This file — all project rules |
| `docs/cycle/PROMPT.md` | Agent entry prompt (auto-loaded) |
