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

### Build + Run
- `cpp-build.cpp` — C++ build system, compile, run

### Terminal
- `bash-terminal.sh` — Terminal emulator, shell commands

### Eval + Debug
- `elisp-test.el` — Emacs Lisp evaluation, testing

### Git + Diff
- `git-test.py` — Version control, diff visualization

### Snippets
- `snippet-test.py` — Template expansion, IDE snippets

## Verification Checklist

- [ ] LSP starts automatically
- [ ] Completion appears after typing
- [ ] Build commands work
- [ ] Terminal opens correctly
- [ ] Git diff shows in fringe
- [ ] Snippets expand with M-+
- [ ] Keybindings work as documented
