# Session Log

Scrum-style changelog. Each session gets a dated entry. Newest on top.

---

## [2026-08-30] Session 2 — Phase 2 Quick Wins

### Done
- Added delete-selection-mode (typing replaces selected region)
- Added frame-title-format (shows buffer name/path in title bar)
- Added compilation keybindings: C-c l c (compile), C-c l k (kill), C-c l n/p (navigate errors)
- Added flymake error faces (red for errors, yellow for warnings with wave underline)
- Created .gitignore (Emacs artifacts, build artifacts, OS files)
- Cleaned up stale Emacs artifacts (#init.el#, init.el~, SPEC.md~)
- Fixed SPEC.md (stale file counts, removed fixed known issues, removed completed planned items)

### Changed
- Test count: 99 → 106 (7 new tests for Phase 2 features)
- init.el: 609 → 633 lines

### Blocked
- (none)

### Next
- Phase 3: Enhance project scaffolding (add more templates)
- Phase 4: Consider additional LSP features
- Commit current state to git

---

## [2026-08-30] Session 1 — Setup, Refactor & Comfort

### Done
- Refactored init.el into 14 semantically ordered sections with detailed comments
- Changed font from Hack to Noto Sans Mono (height 145)
- Added comfort features (built-in): which-key, save-place, savehist, recentf, which-function, whitespace-cleanup
- Added flymake navigation keybindings (M-n / M-p)
- Created automated test suite (99 tests, TAP format)
- Created run_tests.sh pipeline script
- Added packages: diff-hl (git gutter), vundo (visual undo), ace-window (window switching)
- Created SPEC.md (technical specification)
- Created SESSION.md (this file)
- Updated install_emacs_config_dependencies.sh (Noto Sans Mono font)
- Updated WORKFLOWS.md (fix errors, add missing features)

### Changed
- Font: Hack → Noto Sans Mono
- Font height: 130 → 145
- init.el: 377 lines → 609 lines (comments + refactoring)
- Test count: 0 → 99

### Blocked
- (none)

### Next
- Phase 2 Quick Wins: delete-selection-mode, frame title, compile keys, flymake faces
- Commit current state to git

---

## [2026-04-28] Session 0 — Initial Setup

### Done
- Initial init.el creation
- First commit to git

### Changed
- (none)

### Blocked
- (none)

### Next
- Refactor and expand config
