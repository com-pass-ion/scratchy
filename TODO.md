# TODO: Commit-Driven Sprint Tracking

Replace manual sprint tracking with a commit-driven system. Commit messages are the single source of truth.

## Commit Convention

Extend conventional commits with sprint metadata:
```
<type>(<scope>): <description> [S<N>] [Xsp] [#item]
```

Examples:
```
feat(lsp): add eglot for nix-mode [S13] [3sp] [#nix-lsp]
fix(debug): correct gdb binary path [S13] [1sp]
chore(deps): add ripgrep to installer [S13] [1sp]
docs(scrum): remove kanban process [S13] [1sp]
```

- `[S<N>]` — Sprint number (required for sprint tracking)
- `[Xsp]` — Story point estimate (optional)
- `[#item]` — Backlog item reference (optional)

## Before Deleting: Extract History

| File | What to Extract | Destination |
|------|----------------|-------------|
| `scrum/SPRINT.org` | Velocity table | `scrum/velocity.csv` |
| `scrum/SPRINT.org` | Action items (lines 25-48) | `scrum/BACKLOG.org` |

## Execution Order

### Step 1: Extract history
- [x] Save velocity table to `scrum/SPRINT.org` (velocity-only format)
- [x] Merge SPRINT.org action items into `scrum/BACKLOG.org`

### Step 2: Edit scrum/RULES.md
Remove:
- Kanban reference
- Retro rules and 8 follow-up questions
- Phase tracking rule
- Phases section
- File Locations table: remove old entries

Add:
- Commit convention section (format, required fields)
- Review findings → BACKLOG.org rule

### Step 3: Edit scrum/SCRUM-WORKFLOW.md
Remove:
- Process flow diagram with kanban
- Planning Poker section
- Story Points table
- File Structure section
- Phase Changes table

Replace with:
- Commit convention reference
- Simplified workflow description

### Step 4: Edit scrum/PROMPT.md
Remove:
- Sprint phases section
- `.scrum` file references
- Retro rule

Add:
- Commit convention rule
- Current sprint derived from latest `[S<N>]` commit

### Step 5: Edit doc/SCRUM.org
Update:
- File structure tree: remove deleted files
- Remove stale references
- Keep Review Log as historical audit trail

### Step 6: Edit log/BACKLOG.org
- Add action items from SPRINT.org evaluation with proper properties
- Update stale phase-specific items

### Step 7: Delete files
- [x] `log/SPRINT.org`
- [x] `log/SESSION.org`
- [x] `sprint_13_backlog_06_09_2026.scrum`
- [x] `testBeforeIntegration/`
- [x] `opencode.json`
- [x] `learning_cmake.org`

### Step 8: Fix broken references
- [x] `doc/scratchy_testing_strategy.org` — stale ref to `doc/WORKFLOWS.org`
- [x] `doc/SCRUM.org` — stale WORKFLOWS.org, opencode.json refs
- [x] `scrum/BACKLOG.org` — stale testBeforeIntegration ref

### Step 9: Verify
- [ ] Run `./test/run_tests.sh`
- [ ] Check for any remaining references to deleted files

### Step 10: Commit
Atomic commits per step, conventional format:
```
chore(scrum): extract velocity history to SPRINT.org [S13] [1sp]
refactor(rules): remove kanban/retro, add commit convention [S13] [1sp]
refactor(workflow): simplify to commit-driven process [S13] [1sp]
refactor(prompt): update agent instructions [S13] [1sp]
refactor(docs): update SCRUM.org file structure [S13] [1sp]
chore(log): merge action items into BACKLOG.org [S13] [1sp]
chore: delete SPRINT.org, SESSION.org, .scrum, testBeforeIntegration [S13] [1sp]
fix: remove stale WORKFLOWS.org, opencode.json references [S13] [1sp]
```
