# Project Status Resume: C++ Workflow & Adoption

## 1. Current State of C/C++ Workflow
The C++ development pipeline has been modernized (S14/S15) to move away from custom Elisp wrappers and toward tool-native configurations.

- **Build System**: Uses a `Makefile` wrapping `cmake`. `C-c l b` invokes `project-compile` (default `make`).
- **Indexing**: clangd uses `build/compile_commands.json`.
- **Formatting**: `clang-format` on save via `c-mode-common-hook`, gated by the presence of a `.clang-format` file.
- **Debugging**: Standard `M-x gdb` with `gdb-many-windows` layout and `gud-tooltip-mode`. Pretty-printing is handled by a versioned default `.gdbinit` symlinked by the installer.

## 2. Adoption Workflow (implemented in S15)
A new shell-based adoption system replaces the old Elisp scaffolding.

- **Tool**: `scaffold/adopt-cpp-project.sh`
- **Purpose**: Adapts an existing make-based C/C++ project to the Scratchy workflow.
- **Actions**:
    - Adds `.clangd` (points to `build/compile_commands.json`).
    - Adds `.gitignore` (ignores `build/` and `compile_commands.json`).
    - Adds `.clang-format` (conservative SOTA) if requested via `--with-format` and absent.
    - Initializes `git` if no repository is found.
    - Optionally runs `make` (`--build`) to seed the compile database.
- **Emacs Entry**: `M-x adopt-cpp-project` confirms and executes the script in the current directory.

## 3. Implementation Layer Decisions
Following the "one owner per behavior" rule:
- **Elisp**: Only handles entry points (`adopt-cpp-project`) and Emacs state (layout).
- **Shell**: Owns file scaffolding and external tool invocation.
- **Tool Config**: `.clangd`, `.clang-format`, and `.gdbinit` own the tool settings.

## 4. Completed (S16)
- **`#cpp-run`**: `C-c l r` now executes `make run`.
- **`#cpp-format-hint`**: Added warning on mode entry when `clang-format` is missing.
- **`#cpp-build-flag`**: Confirmed `C-c l b` uses plain `make`.
- **CMake Backbone**: Adoption script now supports native CMake builds via `--build` to generate compile commands.
