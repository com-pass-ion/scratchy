# Scrum Rules for Agents

Quick reference of all rules to follow when working on this project.

## Language

- **English Only**: All documentation must be written in English

## Features

- **No Features Without Approval**: Only implement features when explicitly approved
- **No New Features Without Approval**: Only add new items to backlog with confirmation
- **Planning Poker**: Estimation before sprint planning for new items
- **Backlog Tasks: DONE not Deleted**: Tasks removed from backlog must be marked as DONE, not deleted

## Quality

- **Definition of Done**: All code must pass tests, be documented, and follow style guide
- **Test Before Commit**: Run `./test/run_tests.sh` before committing
- **Commit After Every Step**: Commit after completing each task with descriptive message
- **Dependencies Required**: When adding packages with system dependencies, always update `install_emacs_config_dependencies.sh`
- **Test Strategy**: Tests must verify functionality, not just code presence. Use feature tests (fboundp), state tests (bound-and-true-p), and integration tests (file open). Source code tests only for critical configs (font, keybindings).

## Sprint

- **Sprint Goal**: Each sprint must have a clear, measurable goal
- **Capacity**: 2-4 hours per session
- **Phase Tracking**: Update `current_state.org` on every phase change

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
