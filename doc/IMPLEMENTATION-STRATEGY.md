# Implementation Strategy: Elisp vs Shell vs Config

Where each capability lives: Emacs Lisp in `src/init.el`, an external shell
script, or a tool-native config file. The guiding principle is **one owner
per behavior** — a capability is implemented in exactly one layer and the
other layers only call into it.

## Decision Table

| Capability kind | Home | Why | Test layer |
|-----------------|------|-----|------------|
| Emacs state, interaction, entry points (commands, hooks, keybindings, dispatch) | Elisp (`src/init.el`) | Needs live editor state and user interaction | `test/test_init.el`, `test/test_integration.el` |
| Data tables / constants (flags, mappings) | Elisp (`defconst`/`defvar`) | Single source of truth, testable as values | `test/test_init.el` |
| Subprocesses, pipelines, builds outside Emacs | Shell script (`test/`, `scripts/`, project `Makefile`) | Runs standalone, reusable at the terminal and in CI | TAP shell scripts |
| Tool-native settings (language server, formatter, build tool) | Tool config file (`.clangd`, `.clang-format`, `CMakeLists.txt`) | Works with other editors/CI, no Emacs dependency | fixture existence/content checks |

## Criteria (rules of thumb)

1. **Emacs state/interaction/entry points → Elisp.** If it reads editor
   state, prompts the user, or defines a command/hook, it belongs in Elisp.
2. **Subprocess/pipeline/outside-Emacs → shell script.** If it makes sense
   to run it without Emacs (build, index, batch test), put it in a script.
3. **Tool-native settings → config file.** If the tool already defines a
   config format (clangd, clang-format), prefer it over Emacs-side options:
   it works with other clients and is easier to debug.
4. **Data belongs to Elisp, execution to the shell.** Emacs owns the
   *what* (ordered flags, dispatch); the shell/tool owns the *how*.
5. **One owner per behavior.** Never implement the same behavior in two
   layers; the other layer should only invoke the owner.

## Lessons from the GDB workflow (Sprint 12 → 14)

**Positive (keep):** GDB pretty-printing settings were held as an Elisp data
list (`my/gdb-init-args`) and passed through a single entry point. This kept
the *data* in one place and testable as a value.

**Negative (avoid):** Passing those settings as `-ex` flags meant the Emacs
side duplicated what gdb/`.gdbinit` already own, and a project `.gdbinit`
narrowing `auto-load safe-path` fought the flags. The fix is to let gdb own
its own settings again.

**Negative (avoid):** Writing Emacs-specific marker files (e.g. `.projectile`)
that the chosen tool ignores. Use the tool's native mechanism (project.el
uses `.git`; CMake uses `CMakeLists.txt`). Positive example: `src/templates`
is read natively by Tempel with no adapter code.

**Sprint 14 decision:** Standardize on stock `M-x gdb` with no custom
launcher. Emacs owns only layout and tooltips; gdb owns pretty-printing and
safe-path (via `~/.gdbinit`, below).

## User `~/.gdbinit` recipe

The GDB settings formerly passed as `-ex` flags now live in the user's
`~/.gdbinit` (outside this repo, so it is not versioned and applies to all
projects):

```gdb
set auto-load safe-path /
set print pretty on
set print array on
set print array-indexes on
set print elements 0
set print object on
set print address off
set pagination off
set breakpoint pending on
set confirm off
```

## C/C++ pipeline decisions (Sprint 14)

- **Build:** the project `Makefile` wraps a CMake backbone
  (`cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build`).
  `make` is the single entry point; Emacs calls it via `project-compile`
  (`C-c l b`). No custom `my/cpp-build`/`my/cpp-run` wrappers.
- **Indexing:** clangd reads `build/compile_commands.json` (pointed at by the
  project `.clangd` file); hardcoded `-std=` fallback flags were removed.
- **Legacy projects:** `bear` generates a compile database where CMake is
  unavailable.
- **Formatting:** clang-format runs on save using `-style=file`, so the
  nearest project `.clang-format` governs the style (legacy-aware).
- **Debugging:** stock `M-x gdb`; pretty-printing via `~/.gdbinit` (above).

## Test layers per implementation

| Layer | Verified by | Example |
|-------|-------------|---------|
| Elisp behavior | `test/test_init.el`, `test/test_integration.el` | commands defined, keybindings, pure helpers |
| Shell behavior | TAP shell scripts | `test/test_gdb_workflow.sh`, `test/validate_process_files.sh` |
| Config files | existence/content checks | fixture `Makefile` exports `CMAKE_EXPORT_COMPILE_COMMANDS`, `.clangd`, `.clang-format` |

## References

- `scrum/RULES.md` — project rules (see Coding Style)
- `doc/SCRUM.org` — architecture and test coverage
- `doc/agent-research/WORLD-MODEL-STRUCTURE.org` — tools/skills roadmap
