# Implementation Strategy: Elisp vs Shell vs Config

Where each capability lives: Emacs Lisp in `src/init.el`, an external shell
script, or a tool-native config file. The guiding principle is **one owner
per behavior** — a capability is implemented in exactly one layer and the
other layers only call into it.

## Decision Table

| Capability kind | Home | Why | Test layer |
|-----------------|------|-----|------------|
| Emacs state, interaction, entry points (commands, hooks, keybindings, dispatch) | Elisp (`src/init.el`) | Needs live editor state and user interaction | `tests/test_init.el`, `tests/test_integration.el` |
| Data tables / constants (flags, mappings) | Elisp (`defconst`/`defvar`) | Single source of truth, testable as values | `tests/test_init.el` |
| Subprocesses, pipelines, builds outside Emacs | Shell script (`tests/`, `scripts/`, project `Makefile`) | Runs standalone, reusable at the terminal and in CI | TAP shell scripts |
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
6. **Never wrap a decoupled design in Elisp.** If a tool already owns a config
   format, ship the tool's native config file (see `src/dotfiles/`) instead of
   adding Elisp functions or data that duplicate it. A default native init
   file coexists with the user's; it must not overwrite their defaults.

## Lessons from the GDB workflow (Sprint 12 → 14)

**Negative (avoid):** GDB pretty-printing settings were once held as an Elisp
data list (`my/gdb-init-args`) and passed as command-line flags. This wrapped a
design gdb already owns: the Emacs side duplicated `.gdbinit`, and a project
`.gdbinit` narrowing `auto-load safe-path` fought the flags. Elisp must not
wrap decoupled designs (see `docs/cycle/RULES.md`).

**Fix (owner):** gdb owns its own settings through a default `.gdbinit` init
file shipped in this repo (`src/dotfiles/.gdbinit`). The installer symlinks it to
`~/.gdbinit` only when the user has none, so the user's own init is never
overwritten. No Elisp function wraps it.

**Negative (avoid):** Writing Emacs-specific marker files (e.g. `.projectile`)
that the chosen tool ignores. Use the tool's native mechanism (project.el
uses `.git`; CMake uses `CMakeLists.txt`). Positive example: `src/templates`
is read natively by Tempel with no adapter code.

**Sprint 14 decision:** Standardize on stock `M-x gdb` with no custom
launcher. Emacs owns only layout and tooltips; gdb owns pretty-printing and
safe-path (via the default `.gdbinit`, below).

## Default GDB init file

`src/dotfiles/.gdbinit` is the versioned default. The dependency installer
symlinks it to `~/.gdbinit` only when that path does not already exist, so a
user's own init file is never overwritten:

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

gdb owns these settings; Emacs passes no command-line GDB flags.

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
- **Debugging:** stock `M-x gdb`; pretty-printing via the default `.gdbinit`
  (`src/dotfiles/.gdbinit`, symlinked to `~/.gdbinit` by the installer).

## Test layers per implementation

| Layer | Verified by | Example |
|-------|-------------|---------|
| Elisp behavior | `tests/test_init.el`, `tests/test_integration.el` | commands defined, keybindings, pure helpers |
| Shell behavior | TAP shell scripts | `tests/test_gdb_workflow.sh`, `tests/validate_process_files.sh` |
| Config files | existence/content checks | fixture `Makefile` exports `CMAKE_EXPORT_COMPILE_COMMANDS`, `.clangd`, `.clang-format` |

## References

- `docs/cycle/RULES.md` — project rules (see Coding Style)
- `docs/SCRUM.org` — architecture and test coverage
- `docs/agent-research/WORLD-MODEL-STRUCTURE.org` — tools/skills roadmap
