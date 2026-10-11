# Scratchy default GDB init file (versioned at src/dotfiles/.gdbinit).
#
# The dependency installer symlinks this to ~/.gdbinit only when the user
# has none, so it never overwrites a user's own GDB configuration.
#
# gdb owns these settings; Emacs passes no command-line GDB flags.
# See docs/IMPLEMENTATION-STRATEGY.md.

# Allow auto-loading pretty-printers (libstdc++, etc.) from anywhere.
set auto-load safe-path /

# Pretty-printing and stable, non-truncated output for STL containers.
set print pretty on
set print array on
set print array-indexes on
set print elements 0
set print object on
set print address off

# Non-interactive-friendly behavior.
set pagination off
set breakpoint pending on
set confirm off
