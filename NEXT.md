# NEXT: The Leap to Emacs 32

This document outlines the transition to Emacs 32 as the baseline, shifting from installation simulation to a compilation-driven verification pipeline.

## 🎯 Goals
- **Target Emacs 32**: Purge all legacy version guards and 31.1-specific logic.
- **Compilation as Truth**: Make successful byte-compilation of the config the primary validation gate.
- **Tiered Toolchain Validation**: Integrate the Emacs source build into the test suite with impact-based triggering.

---

## 🛠️ Implementation Plan

### 1. Codebase Simplification (The Purge)
- **`src/init.el`**:
    - Remove all `(if (>= emacs-version ...))` version guards.
    - Remove comments referencing Emacs 31.1 requirements.
    - Unconditionally enable `tempel-collection`.
- **`scrum/RULES.md`**:
    - Update the "Definition of Done" to require passing the Absolute-Pass (Source Build + Compile).

### 2. Redesigning the Verification Pipeline
Refactor `test/run_tests.sh` and `test/git-pre-commit` into an impact-driven pipeline:

#### Tier A: The Fast-Pass (Every Commit)
- **Triggers**: Any change.
- **Pipeline**: `validate_process_files.sh` $\to$ `Security Scan` $\to$ `Strict Byte-Compile` (against current binary).
- **Goal**: Syntactic and process correctness.

#### Tier B: The Functional-Pass (Code/Test Changes)
- **Triggers**: Changes to `src/**/*.el`, `test/**/*.sh`, or `dotfiles/**/*`.
- **Pipeline**: Fast-Pass $\to$ `Isolated Functional Tests` (integration/module tests).
- **Goal**: Behavioral correctness and regression prevention.

#### Tier C: The Absolute-Pass (Toolchain/Master Changes)
- **Triggers**: Changes to `build_emacs_source.sh`, `install_emacs_config_dependencies.sh`, or Merge to `master`.
- **Pipeline**: `build_emacs_source.sh` $\to$ Fast-Pass $\to$ Functional-Pass.
- **Goal**: Guarantee compatibility with the exact Emacs 32 source build.

### 3. Backlog Reconciliation
- Mark `#492 Re-enable tempel-collection` as `DONE`.

---

## 🧪 Verification Matrix
| Change | Pipeline | Expected Result |
| :--- | :--- | :--- |
| Edit `RULES.md` | Fast-Pass | Blocked by Safety Guard |
| Edit `init.el` | Functional-Pass | Pass $\to$ `init.elc` produced |
| Merge to `master`| Absolute-Pass | Emacs built from source $\to$ Tests Pass |
