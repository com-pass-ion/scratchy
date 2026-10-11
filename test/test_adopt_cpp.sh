#!/bin/bash
# test_adopt_cpp.sh — TAP tests for scaffold/adopt-cpp-project.sh
# Run via ./test/run_tests.sh (wired in) or directly.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
ADOPT="$REPO_ROOT/scaffold/adopt-cpp-project.sh"

PASS=0
FAIL=0
SKIP=0

ok()   { PASS=$((PASS + 1)); echo "ok - $1"; }
fail() { FAIL=$((FAIL + 1)); echo "not ok - $1"; [ -n "${2:-}" ] && echo "  $2"; }
skip() { SKIP=$((SKIP + 1)); echo "SKIP - $1"; [ -n "${2:-}" ] && echo "  $2"; }

have() { command -v "$1" &>/dev/null; }

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

echo "1..8"

# 1. creates Makefile + .clangd + .gitignore + .clang-format when none exist
d1="$tmpdir/proj1"
mkdir -p "$d1/src"
printf '#include <iostream>\nint main(){std::cout<<"hi\\n";return 0;}\n' > "$d1/src/main.cpp"
if "$ADOPT" "$d1" >/dev/null 2>&1; then
  ok "1 adopt runs"
  [ -f "$d1/Makefile" ] && [ -f "$d1/.clangd" ] && [ -f "$d1/.gitignore" ] && [ -f "$d1/.clang-format" ] && ok "2 creates expected files" || fail "2 creates expected files"
else
  fail "1 adopt runs"
  fail "2 creates expected files"
fi

# 3. does not overwrite existing files; second run adds nothing
d2="$tmpdir/proj2"
mkdir -p "$d2/src"
printf 'old' > "$d2/.clangd"
printf '#include <iostream>\nint main(){return 0;}\n' > "$d2/src/main.cpp"
"$ADOPT" "$d2" >/dev/null 2>&1
if [ "$(cat "$d2/.clangd")" = "old" ]; then
  ok "3 does not overwrite pre-existing files"
else
  fail "3 does not overwrite pre-existing files"
fi

# 4. no build system created when CMakeLists.txt exists
d3="$tmpdir/proj3"
mkdir -p "$d3/src"
cat > "$d3/CMakeLists.txt" << 'EOF'
cmake_minimum_required(VERSION 3.10)
project(proj3)
set(CMAKE_CXX_STANDARD 17)
add_executable(${PROJECT_NAME} src/main.cpp)
EOF
printf '#include <iostream>\nint main(){return 0;}\n' > "$d3/src/main.cpp"
"$ADOPT" "$d3" >/dev/null 2>&1
if [ ! -f "$d3/Makefile" ] && [ -f "$d3/.clangd" ]; then
  ok "4 does not create Makefile when CMakeLists exists"
else
  fail "4 does not create Makefile when CMakeLists exists"
fi

# 5. no sources -> no Makefile provided
d4="$tmpdir/proj4"
mkdir -p "$d4"
"$ADOPT" "$d4" >/dev/null 2>&1
if [ ! -f "$d4/Makefile" ]; then
  ok "5 no Makefile when no sources"
else
  fail "5 no Makefile when no sources"
fi

# 6. --no-format skips .clang-format
d5="$tmpdir/proj5"
mkdir -p "$d5/src"
printf '#include <iostream>\nint main(){return 0;}\n' > "$d5/src/main.cpp"
"$ADOPT" "$d5" --no-format >/dev/null 2>&1
if [ ! -f "$d5/.clang-format" ]; then
  ok "6 --no-format skips .clang-format"
else
  fail "6 --no-format skips .clang-format"
fi

# 7. --dry-run writes nothing
d6="$tmpdir/proj6"
mkdir -p "$d6/src"
printf '#include <iostream>\nint main(){return 0;}\n' > "$d6/src/main.cpp"
"$ADOPT" "$d6" --dry-run >/dev/null 2>&1
if [ ! -f "$d6/Makefile" ] && [ ! -f "$d6/.clangd" ] && [ ! -f "$d6/.gitignore" ]; then
  ok "7 --dry-run writes nothing"
else
  fail "7 --dry-run writes nothing"
fi

# 8. --build produces compile_commands.json and binary
d7="$tmpdir/proj7"
mkdir -p "$d7/src"
cat > "$d7/src/main.cpp" << 'EOF'
#include <iostream>
int main() {
  std::cout << "ok\n";
  return 0;
}
EOF
"$ADOPT" "$d7" >/dev/null 2>&1
if [ -f "$d7/Makefile" ]; then
  if make -C "$d7" >/dev/null 2>&1 && [ -f "$d7/build/compile_commands.json" ] && [ -x "$d7/build/proj7" ]; then
    ok "8 build seeds compile_commands.json and binary"
  else
    fail "8 build seeds compile_commands.json and binary"
  fi
else
  fail "8 build seeds compile_commands.json and binary"
fi

echo ""
echo "# adopt-cpp tests: $PASS passed, $FAIL failed, $SKIP skipped"
if [ "$FAIL" -gt 0 ]; then
  echo "# RESULT: FAILED"
  exit 1
fi
echo "# RESULT: PASSED"
exit 0
