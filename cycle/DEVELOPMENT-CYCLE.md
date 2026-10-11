# Development Cycle

## Rules

See [RULES.md](RULES.md) for the complete ruleset.

## Commit Convention

```
<type>(<scope>): <description> [C<N>] [Xsp] [#item]
```

- `[C<N>]` — Cycle number (required)
- `[Xsp]` — Story point estimate (optional)
- `[#item]` — Backlog item reference (optional)

The legacy `[S<N>]` marker is forbidden.

## Workflow

1. Pick items from `cycle/BACKLOG.org`
2. Work in atomic commits with cycle markers
3. After a cycle: discuss findings, add action items to `cycle/BACKLOG.org`
4. Record delivered story points in `cycle/CYCLE-HISTORY.org`
