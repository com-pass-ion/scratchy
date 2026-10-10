#!/bin/bash
# adopt-cpp-project.sh — adopt an existing C/C++ project into the Scratchy workflow.
#
# Adds only what a project is missing:
#   - a basic make build system (only when no build system is present)
#   - .clangd, .gitignore
#   - .clang-format (unless --no-format, and only if none exists up the tree)
# Initializes git when the directory is not a repository. Never overwrites files.
# Does not create source directories or demo code.
#
# Usage: adopt-cpp-project.sh [DIR] [--no-format] [--no-git] [--build] [--dry-run]
#        adopt-cpp-project.sh -h

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/cpp"

DIR="."
WITH_FORMAT=1
DO_GIT=1
DO_BUILD=0
DRY_RUN=0

usage() {
  sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# // '
}

for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    --no-format) WITH_FORMAT=0 ;;
    --no-git)    DO_GIT=0 ;;
    --build)     DO_BUILD=1 ;;
    --dry-run)   DRY_RUN=1 ;;
    -*) echo "adopt-cpp-project: unknown option: $arg" >&2; usage >&2; exit 2 ;;
    *)  DIR="$arg" ;;
  esac
done

if [ ! -d "$DIR" ]; then
  echo "adopt-cpp-project: not a directory: $DIR" >&2
  exit 1
fi
DIR="$(cd "$DIR" && pwd)"
cd "$DIR"
PROJECT_NAME="$(basename "$DIR")"

ADDED=()
SKIPPED=()

note_added()   { ADDED+=("$1"); }
note_skipped() { SKIPPED+=("$1"); }

have_rg=0
command -v rg >/dev/null 2>&1 && have_rg=1

find_cc_sources() {
  if [ "$have_rg" = 1 ]; then
    rg --files -g '*.c' -g '*.cc' -g '*.cpp' -g '*.cxx' -g '*.h' -g '*.hpp' \
       --glob '!build/**' 2>/dev/null || true
  else
    find . -type f \( -name '*.c' -o -name '*.cc' -o -name '*.cpp' \
      -o -name '*.cxx' -o -name '*.h' -o -name '*.hpp' \) \
      -not -path './build/*' 2>/dev/null || true
  fi
}

clang_format_up_tree() {
  local d="$DIR"
  while [ -n "$d" ]; do
    [ -e "$d/.clang-format" ] && return 0
    local parent; parent="$(dirname "$d")"
    [ "$parent" = "$d" ] && break
    d="$parent"
  done
  return 1
}

copy_if_missing() { # <src> <dest> <label>
  local src="$1" dest="$2" label="$3"
  if [ -e "$dest" ]; then
    note_skipped "$label (exists)"
  elif [ "$DRY_RUN" = 1 ]; then
    note_added "$label (would add)"
  else
    cp "$src" "$dest"
    note_added "$label"
  fi
}

# --- detection ---------------------------------------------------------------

build_markers=(CMakeLists.txt Makefile makefile GNUmakefile meson.build \
  build.ninja BUILD BUILD.bazel WORKSPACE xmake.lua SConstruct SConscript \
  configure configure.ac Makefile.am premake5.lua)
build_marker=""
for m in "${build_markers[@]}"; do
  if [ -e "$m" ]; then build_marker="$m"; break; fi
done

sources="$(find_cc_sources)"
has_sources=0; [ -n "$sources" ] && has_sources=1

# --- provide missing pieces ---------------------------------------------------

if [ -n "$build_marker" ]; then
  note_skipped "build system ($build_marker)"
elif [ "$has_sources" = 1 ]; then
  copy_if_missing "$TEMPLATE_DIR/Makefile" "Makefile" "Makefile (basic build system)"
else
  echo "adopt-cpp-project: warning: no C/C++ sources found; not providing a build system" >&2S
fi

copy_if_missing "$TEMPLATE_DIR/.clangd" ".clangd" ".clangd"
copy_if_missing "$TEMPLATE_DIR/.gitignore" ".gitignore" ".gitignore"

if [ "$WITH_FORMAT" = 1 ]; then
  if clang_format_up_tree; then
    note_skipped ".clang-format (found up tree)"
  else
    copy_if_missing "$TEMPLATE_DIR/.clang-format" ".clang-format" ".clang-format"
  fi
else
  note_skipped ".clang-format (--no-format)"
fi

# --- git ------------------------------------------------------------------

if [ "$DO_GIT" = 1 ]; then
  if [ -d .git ]; then
    note_skipped "git (repository exists)"
  elif [ "$DRY_RUN" = 1 ]; then
    note_added "git init (would run)"
  else
    git init -q
    note_added "git init"
  fi
else
  note_skipped "git (--no-git)"
fi

# --- optional build (seeds build/compile_commands.json) -------------------
 
if [ "$DO_BUILD" = 1 ]; then
  if [ -e CMakeLists.txt ]; then
    if [ "$DRY_RUN" = 1 ]; then
      note_added "cmake (would run)"
    elif cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON >/dev/null 2>&1 && cmake --build build >/dev/null 2>&1; then
      note_added "cmake (binary + compile_commands.json)"
    else
      echo "adopt-cpp-project: warning: cmake failed; build/compile_commands.json not generated" >&2
    fi
  elif [ -e Makefile ]; then
    if [ "$DRY_RUN" = 1 ]; then
      note_added "make (would run)"
    elif make >/dev/null 2>&1; then
      note_added "make (binary + compile_commands.json)"
    else
      echo "adopt-cpp-project: warning: make failed; build/compile_commands.json not generated" >&2
    fi
  fi
fi

# --- summary --------------------------------------------------------------

echo ""
echo "adopt-cpp-project: $PROJECT_NAME"
echo "  directory: $DIR"
for a in "${ADDED[@]}"; do echo "  added:   $a"; done
for s in "${SKIPPED[@]}"; do echo "  skipped: $s"; done
[ "$DRY_RUN" = 1 ] && echo "  (dry run: no changes written)"
echo ""
echo "Build with: make        (C-c l b in Emacs)"
echo "Run with:   make run"
echo ""
exit 0
