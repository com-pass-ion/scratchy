# Generic Scrum Workflow

This document contains the generic Scrum process used in this project.

## Rules

- **English Only**: All documentation must be written in English for consistency
- **No Features Without Approval**: Only implement features when explicitly approved
- **No New Features Without Approval**: Only add new items to backlog with confirmation
- **Planning Poker**: Estimation before sprint planning for new items
- **Definition of Done**: All code must pass tests, be documented, and follow style guide
- **Sprint Goal**: Each sprint must have a clear, measurable goal
- **Phase Tracking**: Update `current_state.org` on every phase change
- **Sprint Updates**: Update `log/SPRINT.org` during sprint (velocity, kanban, retrospective)
- **Sprint Completion**: When sprint is done, update velocity table and add retrospective before starting next sprint
- **Follow-up Questions**: After every sprint retrospective, answer 8 questions in `log/SPRINT.org`
- **Session Logging**: Update `log/SESSION.org` with a summary of completed work before starting each new session or sprint
- **Test Strategy**: Tests must verify functionality, not just code presence
- **Commit After Every Step**: Commit after completing each task with descriptive message
- **Atomic Commits**: Each commit must be self-contained and reversible. One logical change per commit. Never mix unrelated changes in a single commit.
- **Test Before Commit**: Run `./test/run_tests.sh` before committing
- **Dependencies Required**: When adding packages with system dependencies, always update `install_emacs_config_dependencies.sh`
- **Capacity**: 2-4 hours per session

## Process Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        PRODUCT BACKLOG                              │
│  All items with :Effort: + :Category:                               │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     PLANNING POKER                                  │
│  Estimate new items: each shows SP                                 │
│  Consensus → update :Effort: in backlog                            │
│  No consensus → discuss until consensus reached                    │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     SPRINT PLANNING                                 │
│  Move items from backlog → sprint board                            │
│  Capacity: 2-4 hours per session                                   │
│  Only approved items!                                              │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       SPRINT (1 Session)                            │
│                                                                     │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐          │
│  │   TO DO      │───▶│ IN PROGRESS  │───▶│     DONE     │          │
│  │  ○ item 1    │    │  ◉ item 2    │    │  ✓ item 3    │          │
│  │  ○ item 4    │    │              │    │  ✓ item 5    │          │
│  └──────────────┘    └──────────────┘    └──────────────┘          │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ DAILY (per session):                                        │   │
│  │  1. What did I do? ( Yesterday → Done )                    │   │
│  │  2. What will I do? ( Today → In Progress )                │   │
│  │  3. Any blockers? ( → Blocked )                            │   │
│  └─────────────────────────────────────────────────────────────┘   │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       SPRINT REVIEW                                 │
│  Log completed work in session log                                 │
│  Update velocity table in sprint log                               │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       RETROSPECTIVE                                 │
│  Log in sprint log                                                 │
│  What went well? What didn't? Action items?                        │
└───────────────────────────────┴─────────────────────────────────────┘
```

## Planning Poker

### Process
1. Select item from backlog
2. Each person shows SP simultaneously (● to ●●●●●)
3. Discuss if difference > 2 SP
4. Consensus → update :Effort: in backlog
5. No consensus → split or break down item

### Example
| Item                     | Estimate 1 | Estimate 2 | Consensus | Final |
|--------------------------|------------|------------|-----------|-------|
| Example Feature          | ●●●        | ●●         | ●●●       | 3     |
| Quick Fix                | ●●         | ●●         | ●●        | 2     |
| Complex Integration      | ●●●        | ●●●●       | ●●●       | 3     |

## Story Points

| SP    | Effort    | Description                           |
|-------|-----------|---------------------------------------|
| ●     | < 30 min  | Trivial, quick fix                    |
| ●●    | < 1 h     | Small task                            |
| ●●●   | 1-2 h     | Medium task                           |
| ●●●●  | 2-4 h     | Large task                            |
| ●●●●● | > 4 h     | Epic — break down into sub-tasks      |

## File Structure

- `current_state.org` - Current Scrum phase status (update on every phase change)
- `log/BACKLOG.org` - Product backlog with all planned items
- `log/SPRINT.org` - Current sprint, velocity, and retrospective
- `log/SESSION.org` - Session-by-session changelog

## Phase Changes

Update `current_state.org` when transitioning between phases:

| Event                  | Phase                | Action                                          |
|------------------------|----------------------|------------------------------------------------|
| Adding new items       | `backlog`            | Update `:Phase:` and `:Updated:`                |
| Estimating items       | `planning-poker`     | Update `:Phase:` and `:Updated:`                |
| Starting sprint planning | `sprint-planning`  | Update `:Phase:`, `:Sprint:`, and `:Updated:`  |
| Active development     | `in-progress`        | Update `:Phase:` and `:Updated:`                |
| Sprint review          | `review`             | Update `:Phase:` and `:Updated:`                |
| Retrospective          | `retrospective`      | Update `:Phase:` and `:Updated:`                |
