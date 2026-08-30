# Testing Strategy for Scratchy

Three-tier testing approach: **Module**, **Integration**, and **Usability**.

## Overview

```
┌─────────────────────────────────────────────────────────┐
│                    USABILITY TESTS                       │
│         Human-in-the-loop, manual verification          │
│         "Does it work as expected in real use?"         │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│                   INTEGRATION TESTS                      │
│         Workflow testing, package interactions           │
│         "Do packages work together correctly?"           │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│                     MODULE TESTS                         │
│         Unit tests, feature detection, state checks      │
│         "Is each package configured correctly?"          │
└─────────────────────────────────────────────────────────┘
```

## 1. Module Tests (Unit)

**Purpose**: Verify each package is installed, configured, and functional.

**Approach**:
- Use `fboundp` to verify commands are defined
- Use `package-installed-p` to verify packages are installed
- Use `bound-and-true-p` to verify modes are enabled
- Use `string-match-p` on source for critical configs (font, keybindings)

**Current Coverage**: 142 tests across 20 sections

**Example Tests**:
```elisp
;; Feature test (preferred)
(test--assert "vertico-mode is enabled"
  (cl-assert (bound-and-true-p vertico-mode)))

;; State test
(test--assert "corfu-auto is t"
  (cl-assert (eq corfu-auto t)))

;; Source test (only for critical configs)
(test--assert "font is Noto Sans Mono"
  (cl-assert (string-match-p "Noto Sans Mono" (test--get-init-el))))
```

## 2. Integration Tests

**Purpose**: Verify packages work together correctly in workflows.

**Approach**:
- Test workflow chains (e.g., LSP + completion + snippets)
- Test keybinding interactions
- Test mode hook chains
- Test package loading order

**Planned Tests**:

| Workflow | Test | Validates |
|----------|------|-----------|
| LSP + Completion | Eglot + Corfu + Cape | Code intelligence stack |
| Git + Diff | Magit + diff-hl | Version control integration |
| Project + Build | Project.el + compile | Build system workflow |
| Snippets + Completion | Tempel + Corfu | Snippet expansion |
| Search + Navigation | Consult + Vertico | Search workflow |

**Example Integration Test**:
```elisp
(test--assert "LSP + completion stack works"
  (cl-assert (and (fboundp 'eglot-ensure)
                  (bound-and-true-p global-corfu-mode)
                  (member 'cape-dabbrev completion-at-point-functions))))
```

## 3. Usability Tests

**Purpose**: Verify features work as expected in real usage scenarios.

**Approach**:
- Human-in-the-loop verification
- Workflow scenario testing
- Performance checks
- Edge case testing

**Test Scenarios**:

| Scenario | Steps | Expected Result |
|----------|-------|-----------------|
| Open Python file | `find-file` → `.py` | Eglot starts, Corfu enabled |
| Run Python | `C-c l r` | Buffer shows output |
| Git commit | `M-x magit-status` | Magit buffer opens |
| Search project | `M-s r` | Ripgrep results appear |
| Expand snippet | Type `def` → `M-+` | Snippet expands |
| Switch buffer | `C-x b` | Vertico buffer list |

**Usability Checklist**:
- [ ] Feature enables without errors
- [ ] Keybindings work as documented
- [ ] Completion appears when expected
- [ ] No performance degradation
- [ ] Works across all supported languages

## Running Tests

```bash
# Module tests (current)
./test/run_tests.sh

# Coverage report
./test/coverage.sh

# Integration tests (future)
./test/integration_tests.sh

# Usability tests (manual)
# Follow doc/WORKFLOWS.org scenarios
```

## Test Strategy Rules

1. **Test before commit**: Always run `./test/run_tests.sh`
2. **Feature tests preferred**: Use `fboundp`, `bound-and-true-p` over source tests
3. **Source tests only for critical configs**: Font, keybindings, theme
4. **Integration tests for workflows**: Test package interactions
5. **Usability tests for new features**: Human verification before release

## Coverage Goals

| Tier | Current | Target | Status |
|------|---------|--------|--------|
| Module | 142 tests | 150+ | ✅ On track |
| Integration | 0 tests | 10+ | 🔄 Planned |
| Usability | Manual | Checklist | 🔄 Planned |

## Future Enhancements

1. **Automated integration tests**: Script workflow scenarios
2. **Performance benchmarks**: Track startup time, memory usage
3. **Regression tests**: Verify fixes don't break existing features
4. **CI/CD integration**: Run tests on commit (git hook already exists)
