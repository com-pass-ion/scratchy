# Definition of Done

All code must satisfy these criteria before merging.

## Checklist

| # | Criterion | Command | Status |
|---|-----------|---------|--------|
| 1 | Tests pass | `./test/run_tests.sh` | ✅ |
| 2 | No lint errors | Elisp lint | ✅ |
| 3 | No type errors | Elisp type check | ✅ |
| 4 | No secrets | Security scan | ✅ |
| 5 | Docs updated | Manual review | ✅ |

## Usage

Run all checks before commit:

```bash
# 1. Run tests
./test/run_tests.sh

# 2. Lint (if configured)
emacs --batch -l init.el --eval '(check-declare-file "src/init.el")'

# 3. Security scan (check for hardcoded secrets)
grep -rn "password\|secret\|api.key\|token" src/init.el || echo "No secrets found"
```

## Notes

- Tests use TAP format (Test Anything Protocol)
- Exit code 0 = pass, 1 = fail
- This DoD will be enforced via pre-commit hook in future sprint
