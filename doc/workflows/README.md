# Workflow Tests

Sample files to test and verify Scratchy's workflow configurations.

## How to Use

1. Open each file in Emacs
2. Follow the instructions in comments
3. Test the keybindings and features
4. Verify everything works as expected

## Files

| File | Workflow | Tests |
|------|----------|-------|
| `python-lsp.py` | LSP + Completion | Eglot, Corfu, Consult |
| `cpp-build.cpp` | Build + Run | CMake, Compile |
| `bash-terminal.sh` | Terminal + Execution | Eat, Shell |
| `elisp-test.el` | Eval + Debug | Emacs Lisp, ERT |
| `git-test.py` | Git + Diff | Magit, diff-hl |
| `snippet-test.py` | Snippets | Tempel, Templates |

## Workflow Categories

### LSP + Completion
- `python-lsp.py` — Python language server, autocompletion, diagnostics

**Usability Checklist:**
- [ ] Open `python-lsp.py` — Eglot starts automatically
- [ ] Type `def ` — Corfu completion popup appears
- [ ] Press `M-.` — Jump to definition works
- [ ] Press `M-?` — Find references works
- [ ] Press `M-n`/`M-p` — Navigate errors

### Build + Run
- `cpp-build.cpp` — C++ build system, compile, run

**Usability Checklist:**
- [ ] Open `cpp-build.cpp` — Eglot starts (clangd)
- [ ] Press `C-c l b` — Build with CMake
- [ ] Press `C-c l r` — Build and run
- [ ] Press `C-c l n`/`C-c l p` — Navigate errors

### Terminal
- `bash-terminal.sh` — Terminal emulator, shell commands

**Usability Checklist:**
- [ ] Press `C-c t n` — Eat terminal opens
- [ ] Run shell commands — Output appears
- [ ] Press `C-c C-c` — Send buffer to shell (bash-mode)

### Eval + Debug
- `elisp-test.el` — Emacs Lisp evaluation, testing

**Usability Checklist:**
- [ ] Press `C-c l r` — Evaluate buffer
- [ ] Press `C-x C-e` — Evaluate last S-expression
- [ ] Press `M-:` — Evaluate expression in minibuffer

### Git + Diff
- `git-test.py` — Version control, diff visualization

**Usability Checklist:**
- [ ] Edit file — diff-hl shows changes in fringe
- [ ] Press `C-x v =` — View diff for current hunk
- [ ] Press `C-x v n`/`C-x v p` — Jump between changes
- [ ] Press `M-x magit-status` — Open magit buffer

### Snippets
- `snippet-test.py` — Template expansion, IDE snippets

**Usability Checklist:**
- [ ] Type `def` — Snippet name appears
- [ ] Press `M-+` — Snippet expands via completion
- [ ] Press `M-*` — Insert snippet by name
- [ ] Type `for` — For loop snippet works

## Verification Summary

| Workflow | Module Test | Integration Test | Usability Test |
|----------|-------------|------------------|----------------|
| LSP + Completion | Section 9 | Test 1.1-1.5 | python-lsp.py |
| Build + Run | Section 13 | Test 3.1-3.4 | cpp-build.cpp |
| Terminal | Section 11 | Test 8.1-8.2 | bash-terminal.sh |
| Eval + Debug | Section 14 | — | elisp-test.el |
| Git + Diff | Section 8 | Test 2.1-2.3 | git-test.py |
| Snippets | Section 10 | Test 4.1-4.3 | snippet-test.py |
