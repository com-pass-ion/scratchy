# Scrum Rules for Agents

Quick reference of all rules to follow when working on this project.

## Language

- **English Only**: All documentation must be written in English

## Features

- **No Features Without Approval**: Only implement features when explicitly approved. Only add new items to backlog with confirmation.
- **Planning Poker**: Estimation before sprint planning for new items. Agent suggests SP estimates for each item, user confirms or suggests own estimates. Final estimation requires consensus.
- **Backlog Tasks: DONE not Deleted**: Tasks removed from backlog must be marked as DONE, not deleted

## Quality

- **Definition of Done**: All code must pass tests, be documented, and follow style guide
- **Test Before Commit**: Run `./test/run_tests.sh` before committing
- **Commit After Every Step**: Commit after completing each task with descriptive message
- **Atomic Commits**: Each commit must be self-contained and reversible. One logical change per commit. Never mix unrelated changes (e.g., code fix + docs update) in a single commit.
- **Dependencies Required**: When adding packages with system dependencies, always update `install_emacs_config_dependencies.sh`
- **Dependency Gate**: Verify package availability and system dependencies during planning poker. Do not commit to a sprint item if its core dependencies are unverified.
- **Test Strategy**: Tests must verify functionality, not just code presence. Use feature tests (fboundp), state tests (bound-and-true-p), and integration tests (file open). Source code tests only for critical configs (font, keybindings).
- **Research Documents Exempt from Tests**: Documentation-only files in `doc/agent-research/` and similar research directories do not require test coverage. Research is documentation, not code.
- **Blueprint Requirement**: Research tasks must conclude with a "Prototype/Implementation Sketch" section. This transforms abstract findings into a concrete blueprint for future implementation.

## Agent Safety

- **Context Limits**: If session runs out of tokens or context becomes too large, STOP. Do not continue with partial work. Commit what exists, log state, and start fresh in a new session.
- **Session Restart Protocol**: On session restart, read `scrum/BACKLOG.org` first. Do not re-read all project files. Only read files needed for the current task.
- **Minimal Reads**: When resuming work, read only: `scrum/BACKLOG.org`, relevant task file, and max 2-3 supporting files. Do not batch-read the entire project.
- **Prompt Complexity**: Keep prompts simple and direct. Complex multi-step prompts fail on smaller models (32B). Break work into atomic units with clear stop conditions.
- **Fail-Safe Commits**: If any operation fails (edit, test, commit), stop immediately. Do not attempt workarounds that bypass the fail-safe. Commit partial progress and report.
- **Scrum Document Safety**: Never modify `scrum/RULES.md`, `scrum/SCRUM-WORKFLOW.md`, or `scrum/PROMPT.md` without explicit user approval. These are process-defining files that affect all future sessions. Propose changes first, wait for confirmation.

## Coding Style

- **Pure Functional Style**: Prefer pure functions with no side effects. Use `let` for local bindings, avoid `setq` for global state. Functions should return values, not modify globals. Use `defconst` for constants, `defvar` for mutable state only when necessary.

## Sprint

- **Sprint Goal**: Each sprint must have a clear, measurable goal
- **User Selects Items**: The user must explicitly select which backlog items to include in each sprint. The agent may suggest items, but must wait for user approval before finalizing sprint planning.
- **Capacity**: 2-4 hours per session
- **Commit Convention**: Use `<type>(<scope>): <desc> [S<N>] [Xsp] [#item]` format
- **Sprint Updates**: Update `scrum/SPRINT.org` during sprint (velocity)
- **Sprint Completion**: When sprint is done, update velocity table and add retrospective before starting next sprint
- **Actionable Retros**: Every point in "What could improve" must be converted into a backlog task or a concrete rule change. No "improvement" remains just a thought.
- **Follow-up Questions**: After every sprint, discuss findings with user and add action items to `scrum/BACKLOG.org`

## File Locations

| File | Purpose |
|------|---------|
| `scrum/BACKLOG.org` | Product backlog with all planned items |
| `scrum/SPRINT.org` | Velocity tracking |
| `doc/SCRUM.org` | Technical specification and workflow |
| `scrum/SCRUM-WORKFLOW.md` | Generic Scrum process documentation |
