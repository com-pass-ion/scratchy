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

## Governance Enforcement

The cycle process is machine-enforced via git hooks and `cycle/bin/local-ci.sh`.

### State Machine
Cycles follow a formal state transition:
`PLANNING` $\rightarrow$ `ACTIVE` $\rightarrow$ `CLOSING` $\rightarrow$ `ARCHIVED`

- **ACTIVE**: Commits are permitted.
- **Other**: Commits are blocked unless a recovery path is used.

### Recovery Paths
If a commit is required while the cycle is not `ACTIVE`:
1. **One-time**: Use the `--recovery` flag with the commit validator.
2. **Persistent**: Set `git config cycle.bypass true`.

### Local CI
`cycle/bin/local-ci.sh` is the single owner of process validation, orchestrating:
- State file schema validation.
- Governance checksum verification.
- Current cycle state gating.
