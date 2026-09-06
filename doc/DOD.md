# Definition of Done

All code must satisfy these criteria before merging.

## Checklist

| # | Criterion | Command | Status |
|---|-----------|---------|--------|
| 1 | Tests pass | `./test/run_tests.sh` | ✅ |
| 2 | No byte-compile errors | `emacs --batch --eval '(byte-compile-file "src/init.el")'` (no `Error:` output) | ✅ |
| 3 | No secrets | `grep -rni "password\|secret\|api.key" src/ test/ \|\| echo "No secrets found"` | ✅ |
| 4 | Docs updated | Manual review | ✅ |

## Usage

Run all checks before commit:

```bash
# 1. Run tests
./test/run_tests.sh

# 2. Byte-compile (catches syntax/forward-ref errors; warnings OK, errors fail)
emacs --batch --eval '(setq byte-compile-error-on-warn nil)' -f batch-byte-compile src/init.el
rm -f src/init.elc

# 3. Security scan (check for hardcoded secrets)
grep -rni "password\|secret\|api.key" src/ test/ || echo "No secrets found"
```

## Notes

- Tests use TAP format (Test Anything Protocol)
- Exit code 0 = pass, 1 = fail
- This DoD will be enforced via pre-commit hook in future sprint
