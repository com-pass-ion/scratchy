# Scrum Workflow

## Rules

See [RULES.md](RULES.md) for the complete ruleset.

## Commit Convention

```
<type>(<scope>): <description> [S<N>] [Xsp] [#item]
```

- `[S<N>]` — Sprint number (required)
- `[Xsp]` — Story point estimate (optional)
- `[#item]` — Backlog item reference (optional)

## Workflow

1. Pick items from `scrum/BACKLOG.org`
2. Estimate with Planning Poker (agent suggests SP, user confirms)
3. Work in atomic commits with sprint markers
4. After sprint: discuss findings, add action items to `scrum/BACKLOG.org`

## Story Points

| SP    | Effort    | Description                           |
|-------|-----------|---------------------------------------|
| 1     | < 30 min  | Trivial, quick fix                    |
| 2     | < 1 h     | Small task                            |
| 3     | 1-2 h     | Medium task                           |
| 5     | 2-4 h     | Large task                            |
| 8     | > 4 h     | Epic — break down into sub-tasks      |

## File Structure

- `scrum/BACKLOG.org` - Product backlog with all planned items
- `scrum/SPRINT.org` - Velocity tracking
- `doc/SCRUM.org` - Technical specification
