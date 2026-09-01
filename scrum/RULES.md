# Scrum Rules for Agents

Quick reference of all rules to follow when working on this project.

## Language

- **English Only**: All documentation must be written in English

## Features

- **No Features Without Approval**: Only implement features when explicitly approved
- **No New Features Without Approval**: Only add new items to backlog with confirmation
- **Planning Poker**: Estimation before sprint planning for new items. Agent suggests SP estimates for each item, user confirms or suggests own estimates. Final estimation requires consensus.
- **Backlog Tasks: DONE not Deleted**: Tasks removed from backlog must be marked as DONE, not deleted

## Quality

- **Definition of Done**: All code must pass tests, be documented, and follow style guide
- **Test Before Commit**: Run `./test/run_tests.sh` before committing
- **Commit After Every Step**: Commit after completing each task with descriptive message
- **Atomic Commits**: Each commit must be self-contained and reversible. One logical change per commit. Never mix unrelated changes (e.g., code fix + docs update) in a single commit.
- **Dependencies Required**: When adding packages with system dependencies, always update `install_emacs_config_dependencies.sh`
- **Test Strategy**: Tests must verify functionality, not just code presence. Use feature tests (fboundp), state tests (bound-and-true-p), and integration tests (file open). Source code tests only for critical configs (font, keybindings).
- **Research Documents Exempt from Tests**: Documentation-only files in `doc/agent-research/` and similar research directories do not require test coverage. Research is documentation, not code.

## Agent Safety

- **Context Limits**: If session runs out of tokens or context becomes too large, STOP. Do not continue with partial work. Commit what exists, log state in SESSION.org, and start fresh in a new session.
- **Session Restart Protocol**: On session restart, read `current_state.org` first. Do not re-read all project files. Only read files needed for the current task.
- **Minimal Reads**: When resuming work, read only: `current_state.org`, relevant task file, and max 2-3 supporting files. Do not batch-read the entire project.
- **Prompt Complexity**: Keep prompts simple and direct. Complex multi-step prompts fail on smaller models (32B). Break work into atomic units with clear stop conditions.
- **Fail-Safe Commits**: If any operation fails (edit, test, commit), stop immediately. Do not attempt workarounds that bypass the fail-safe. Commit partial progress and report.
- **Scrum Document Safety**: Never modify `scrum/RULES.md`, `scrum/SCRUM-WORKFLOW.md`, or `scrum/PROMPT.md` without explicit user approval. These are process-defining files that affect all future sessions. Propose changes first, wait for confirmation.

## Coding Style

- **Pure Functional Style**: Prefer pure functions with no side effects. Use `let` for local bindings, avoid `setq` for global state. Functions should return values, not modify globals. Use `defconst` for constants, `defvar` for mutable state only when necessary.

## Sprint

- **Sprint Goal**: Each sprint must have a clear, measurable goal
- **User Selects Items**: The user must explicitly select which backlog items to include in each sprint. The agent may suggest items, but must wait for user approval before finalizing sprint planning.
- **Capacity**: 2-4 hours per session
- **Phase Tracking**: Update `current_state.org` on every phase change
- **Sprint Updates**: Update `log/SPRINT.org` during sprint (velocity, kanban, retrospective)
- **Sprint Completion**: When sprint is done, update velocity table and add retrospective before starting next sprint
- **Follow-up Questions**: After every sprint retrospective, answer these questions in `log/SPRINT.org`:
  1. Did we meet the sprint goal?
  2. What was the biggest blocker?
  3. What should we start doing?
  4. What should we stop doing?
  5. What should we continue doing?
  6. Any technical debt to address?
  7. Any process improvements?
  8. Should we adjust velocity?
- **Session Logging**: Update `log/SESSION.org` with a summary of completed work before starting each new session or sprint

## File Locations

| File | Purpose |
|------|---------|
| `current_state.org` | Current Scrum phase (update on phase change) |
| `log/BACKLOG.org` | Product backlog with all planned items |
| `log/SPRINT.org` | Current sprint, velocity, retrospective |
| `log/SESSION.org` | Session-by-session changelog |
| `doc/SCRUM.org` | Technical specification and workflow |
| `scrum/SCRUM-WORKFLOW.md` | Generic Scrum process documentation |

## Phases

```
backlog → planning-poker → sprint-planning → in-progress → review → retrospective
```
