# Emacs From Scratch — Technical Specification

## 1. Overview

- **Project**: Emacs From Scratch — minimal, modern IDE config
- **Author**: njh
- **Emacs Version**: 30.1
- **Platform**: Linux (RaspiOS / Ubuntu)
- **Purpose**: built-in LSP via eglot, clean single-file config
- **Supported Languages**: Python, C/C++, Java, Bash, Elisp

---

## 2. Design Philosophy

- **Built-in first**: Use Emacs built-ins where possible (eglot, project.el, tempo, flymake, which-key)
- **Minimal packages**: Only add packages that provide clear, measurable value
- **Single-file config**: Everything in `init.el`, no modular splitting
- **Testable**: Every feature has an automated test (106 tests, TAP format)
- **Documented**: Keybinding reference in WORKFLOWS.md, technical spec in SPEC.md
- **Session-tracked**: Scrum-style changelog in SESSION.md

---

## 3. Development Workflow

- **Commit after every step**: After completing each task or feature, commit the changes immediately with a descriptive message
- **Test before commit**: Run `./run_tests.sh` to verify all tests pass before committing
- **Update SESSION.md**: Log completed work in the scrum-style changelog before committing

---

## 4. File Structure

```
emacs_from_scratch/
├── init.el                              # Main config (633 lines, 22 KB)
├── test_init.el                         # Test suite (491 lines, 17 KB, 106 tests)
├── run_tests.sh                         # Test runner (22 lines, 486 B)
├── install_emacs_config_dependencies.sh # System deps installer (34 lines, 658 B)
├── WORKFLOWS.md                         # User-facing keybinding cheat sheet (268 lines)
├── SPEC.md                              # This file — technical specification
├── SESSION.md                           # Scrum-style session changelog (70 lines)
├── .gitignore                           # Git ignore rules
└── .git/                                # Git repository
```

---

## 5. Architecture

14 numbered sections in `init.el`:

| # | Section | Packages | Key Features |
|---|---------|----------|--------------|
| 1 | Bootstrap | use-package | GC threshold, package archives, use-package init |
| 2 | Frame & UI | — | Font (Noto Sans Mono), transparency (90%), no chrome |
| 3 | Comfort | vundo, ace-window | which-key, save-place, savehist, recentf, which-function, whitespace-cleanup, narrowing |
| 4 | Theme & Visual | — | Tokyo Night (modus-vivendi), line numbers, hl-line, show-paren, electric-pair |
| 5 | Completion | vertico, orderless, marginalia, corfu, cape | Full completion stack (minibuffer + in-buffer) |
| 6 | Search | consult | Line, buffer, bookmark, ripgrep, yank-pop, history |
| 7 | Help | helpful | Enhanced describe-function/variable/key/symbol |
| 8 | Git | magit, diff-hl | Magit status, git gutter in fringe |
| 9 | LSP | eglot | pyright, clangd, jdtls, bash-ls, flymake navigation |
| 10 | Snippets | — (tempo built-in) | C, Python, Bash, Elisp templates, C-TAB expand |
| 11 | Terminal | eat | Shell in Emacs |
| 12 | Project | — (project.el built-in) | Scaffolding (C++/Python), .projectile, git init |
| 13 | Build & Run | — | CMake build, mode-specific run, compile mode |
| 14 | Org-Mode | — | Babel shell integration |

---

## 6. Usability & Workflow

### 5.1 Complete Keybinding Reference

#### Search & Navigation
| Key | Command | Description |
|-----|---------|-------------|
| `C-s` | `consult-line` | Fuzzy search in current buffer |
| `C-x b` | `consult-buffer` | Switch buffer (with preview) |
| `C-x r b` | `consult-bookmark` | Jump to bookmark |
| `M-s r` | `consult-ripgrep` | Search entire project |
| `M-y` | `consult-yank-pop` | Paste history (kill ring) |

#### Completion
| Key | Command | Description |
|-----|---------|-------------|
| `TAB` | `corfu-complete` | Accept current completion |
| `M-TAB` | `corfu-next` | Next completion option |
| `C-g` | `corfu-quit` | Cancel completion |

#### LSP & Errors
| Key | Command | Description |
|-----|---------|-------------|
| `M-.` | `xref-find-definitions` | Go to definition |
| `M-,` | `xref-pop-marker-location` | Go back from definition |
| `M-?` | `xref-find-references` | Find all references |
| `M-n` | `flymake-goto-next-error` | Jump to next error |
| `M-p` | `flymake-goto-prev-error` | Jump to previous error |
| `C-c C-c` | `python-shell-send-buffer` | Send buffer to Python REPL (Python only) |

#### Build & Run
| Key | Command | Description |
|-----|---------|-------------|
| `C-c l r` | `my/run` | Run file (mode-specific: C++, Python, Bash, Elisp) |
| `C-c l b` | `my/cpp-build` | Build C++ project with CMake |

#### Git
| Key | Command | Description |
|-----|---------|-------------|
| `C-x v =` | `diff-hl-diff-goto-hunk` | View diff for current hunk |
| `C-x v n` | `diff-hl-next-hunk` | Jump to next changed hunk |
| `C-x v p` | `diff-hl-previous-hunk` | Jump to previous changed hunk |
| `M-x magit-status` | `magit-status` | Open magit status buffer |

#### Window & Buffer
| Key | Command | Description |
|-----|---------|-------------|
| `M-o` | `ace-window` | Jump to window by number |
| `C-x C-r` | `recentf-open-files` | Open recent file |
| `C-x 2` | `split-window-below` | Split horizontally |
| `C-x 3` | `split-window-right` | Split vertically |
| `C-x 1` | `delete-other-windows` | Close all other windows |
| `C-x 0` | `delete-window` | Close current window |

#### Undo
| Key | Command | Description |
|-----|---------|-------------|
| `C-/` | `undo` | Undo (standard) |
| `C-?` | `undo-redo` | Redo (standard) |
| `C-c u` | `vundo` | Visual undo tree |

#### Terminal
| Key | Command | Description |
|-----|---------|-------------|
| `C-c t n` | `eat` | Open terminal in side window |

#### Snippets
| Key | Command | Description |
|-----|---------|-------------|
| `C-<TAB>` | `tempo-complete-tag` | Expand snippet at point |

#### Help
| Key | Command | Description |
|-----|---------|-------------|
| `C-h f` | `helpful-callable` | Describe function (enhanced) |
| `C-h v` | `helpful-variable` | Describe variable (enhanced) |
| `C-h k` | `helpful-key` | Describe key (enhanced) |
| `C-h o` | `helpful-symbol` | Describe symbol (enhanced) |

#### Minibuffer
| Key | Command | Description |
|-----|---------|-------------|
| `M-A` | `marginalia-cycle` | Toggle annotations |
| `C-n` | `vertico-next` | Next candidate |
| `C-p` | `vertico-previous` | Previous candidate |
| `C-j` | `vertico-exit` | Confirm selection |
| `C-r` | `consult-history` | Search command history |

### 5.2 Workflow Patterns

**Quick Edit:**
1. `C-x C-r` — open recent file
2. Edit with electric-pair + corfu auto-completion
3. `C-c l r` — run (mode-specific)
4. `M-n`/`M-p` — navigate errors

**Git Workflow:**
1. Edit code — diff-hl shows changes in fringe (green/red/blue marks)
2. `M-x magit-status` — stage, commit, push
3. `C-x v =` — review diff inline

**Multi-Window:**
1. `C-x 2` — split horizontal
2. `C-c t n` — open terminal in bottom
3. `M-o` — jump between windows by number (a/s/d/f/g/h/j/k/l)

**New Project:**
1. `M-x my/project-new` — scaffold C++ or Python project
2. Auto: git init, .gitignore, boilerplate, venv (Python)

### 5.3 Language-Specific Workflows

**Python:**
- LSP: pyright (auto-starts, basic type checking)
- Run REPL: `C-c C-c` (send buffer)
- Run script: `C-c l r` (compile)
- Snippet: `python-main` + `C-<TAB>`

**C/C++:**
- LSP: clangd (C++17 / C11 flags)
- Build: `C-c l b` (CMake)
- Run: `C-c l r` (build + execute)
- Snippet: `c-main` + `C-<TAB>`

**Bash:**
- LSP: bash-language-server (auto-starts)
- Run: `C-c l r`
- Snippet: `bash-header` + `C-<TAB>`

**Java:**
- LSP: jdtls (auto-detected)
- Run: via eglot

**Elisp:**
- Run: `C-c l r` (eval-buffer)
- Eval last sexpr: `C-x C-e`
- Snippet: `elisp-func` + `C-<TAB>`

---

## 7. Packages

| Package | Source | Section | Purpose | Load Strategy |
|---------|--------|---------|---------|---------------|
| use-package | ELPA | 1 | Package management | Eager |
| vertico | ELPA | 5 | Minibuffer completion | Eager |
| orderless | ELPA | 5 | Fuzzy matching | Eager |
| marginalia | ELPA | 5 | Minibuffer annotations | Eager |
| corfu | ELPA | 5 | In-buffer completion | Eager |
| cape | ELPA | 5 | Completion backends | Eager |
| consult | ELPA | 6 | Search/navigation | Lazy (bind) |
| helpful | MELPA | 7 | Enhanced help | Eager |
| magit | MELPA | 8 | Git interface | Lazy (command) |
| diff-hl | MELPA | 8 | Git gutter | Eager (hook) |
| vundo | ELPA | 3 | Visual undo | Lazy (command) |
| ace-window | ELPA | 3 | Window switching | Eager (bind) |
| eat | ELPA | 11 | Terminal emulator | Lazy (command) |

---

## 8. Testing

- **Format**: TAP (Test Anything Protocol)
- **Runner**: `./run_tests.sh` or `emacs --batch -l test_init.el`
- **Exit Code**: 0 = pass, 1 = fail
- **Total Tests**: 106

### Coverage by Section

| Section | Tests | What's Tested |
|---------|-------|---------------|
| 1. Bootstrap | 7 | GC, package system, archives, use-package |
| 2. Frame & UI | 14 | Font, transparency, chrome, bell, line-spacing |
| 3. Comfort | 12 | All modes, keybindings, vundo, ace-window |
| 4. Theme & Visual | 16 | Colors, line numbers, hl-line, parens, cursor, scrolling |
| 5. Completion | 11 | All packages, auto-completion, backends |
| 6. Search | 5 | All consult keybindings |
| 7. Help | 4 | All helpful remaps |
| 8. Git | 5 | Magit functions, diff-hl |
| 9. LSP | 6 | Eglot hooks (5 languages), autoshutdown |
| 10. Snippets | 5 | Tempo templates (4 templates) |
| 11. Terminal | 2 | Eat command, keybinding |
| 12. Project | 3 | Project.el config, scaffolding function |
| 13. Build & Run | 8 | All functions, keybindings, compile settings |
| 14. Org-Mode | 1 | Babel shell integration |

---

## 9. Dependencies

### System Packages (apt)

| Package | Purpose |
|---------|---------|
| emacs | Editor (30.1+) |
| git | Version control |
| build-essential | C compiler, make |
| cmake | C++ build system |
| clangd | C/C++ language server |
| jdtls | Java language server |
| python3 | Python runtime |
| python3-pip | Python package manager |
| python3-venv | Python virtual environments |
| npm | Node.js package manager |
| fonts-noto | Noto Sans Mono font |

### npm Packages (global)

| Package | Purpose |
|---------|---------|
| pyright | Python language server |
| bash-language-server | Bash language server |

### Install Command

```bash
./install_emacs_config_dependencies.sh
```

---

## 10. Session Log

See `SESSION.md` for the scrum-style changelog tracking all sessions.

---

## 11. Planned Features

### Phase 2 — Quick Wins ✅
- delete-selection-mode — text replacement behaves like standard IDEs
- Frame title with filename and path — overview with multiple windows
- Compilation keybindings (`C-c l c` compile, `C-c l k` kill, `C-c l n/p` navigate) — build workflow
- Flymake error faces (red underline, yellow warning) — errors visually prominent

### Phase 3 — Komfort
- apheleia — format-on-save for consistent code style
- yasnippet — richer snippets with tabstops
- tab-bar or persp-mode — workspace management for parallel projects

### Phase 4 — Testing & CI
- Git pre-commit hook — run tests before commit
- GitHub Actions — CI pipeline
- Coverage report — track test additions

### Phase 5 — Documentation
- Add CHANGELOG.md — structured change tracking

---

## 12. Known Issues

| Issue | Detail | Fix |
|-------|--------|-----|
| Stale Emacs artifacts | `#init.el#` and `init.el~` in repo | Added to .gitignore, removed |
| Git history minimal | Only 1 commit, many changes since | Commit current state |
