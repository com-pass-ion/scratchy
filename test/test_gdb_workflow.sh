#!/bin/bash
# test_gdb_workflow.sh — automated basic functionality test for the C++ GDB workflow.
#
# Demo project: ~/debug_cpp (in-place rebuild, per user approval).
# Override with: GDB_DEMO_DIR=/path/to/demo ./test/run_tests.sh
#
# Semantics:
#   ok      — hard PASS
#   not ok  — hard FAIL (script exits 1)
#   SKIP    — arch-limited feature (gdb `record`, `rr` on aarch64).
#             Never fails the suite.
#
# Run with:
#   bash test/test_gdb_workflow.sh
#
# Exit code: 0 = no hard failures, 1 = hard failure.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DEMO_DIR="${GDB_DEMO_DIR:-$HOME/debug_cpp}"
BINARY="$DEMO_DIR/build/debug_demo"

PASS=0
FAIL=0
SKIP=0

ok()   { PASS=$((PASS + 1)); echo "ok - $1"; }
fail() { FAIL=$((FAIL + 1)); echo "not ok - $1"; [ -n "${2:-}" ] && echo "  $2"; }
skip() { SKIP=$((SKIP + 1)); echo "SKIP - $1"; [ -n "${2:-}" ] && echo "  $2"; }

have() { command -v "$1" &>/dev/null; }
run_to() { # run_to <timeout_secs> <outfile> <cmd...>
  local t="$1"; shift
  local out="$1"; shift
  if have timeout; then
    timeout "$t" "$@" >"$out" 2>&1
  else
    "$@" >"$out" 2>&1
  fi
}

echo "--- GDB Workflow Tests (demo: $DEMO_DIR) ---"

# --- A. Dependencies (gdb hard, rr informational) ---
if have gdb; then
  ok "A.1 gdb available ($(gdb --version | head -1))"
else
  fail "A.1 gdb available" "Install with: sudo apt install -y gdb"
fi

if have rr; then
  ok "A.2 rr available ($(rr --version 2>&1 | head -1))"
else
  skip "A.2 rr available" "Not installed; sudo apt install -y rr (x86_64 only for replay)"
fi

if have cmake; then
  ok "A.3 cmake available ($(cmake --version | head -1))"
else
  fail "A.3 cmake available" "Install with: sudo apt install -y cmake"
fi

if [ -d "$DEMO_DIR" ]; then
  ok "A.4 demo directory exists ($DEMO_DIR)"
else
  fail "A.4 demo directory exists" "Set GDB_DEMO_DIR or clone the demo project"
fi

# --- B. In-place rebuild with debug symbols ---
if [ -d "$DEMO_DIR" ]; then
  if run_to 600 /tmp/gdb-build.log cmake -S "$DEMO_DIR" -B "$DEMO_DIR/build" -DCMAKE_BUILD_TYPE=Debug \
    && run_to 600 /tmp/gdb-build2.log cmake --build "$DEMO_DIR/build"; then
    ok "B.1 cmake Debug build succeeded"
  else
    fail "B.1 cmake Debug build succeeded" "See /tmp/gdb-build.log and /tmp/gdb-build2.log"
  fi

  if [ -f "$BINARY" ]; then
    ok "B.2 binary exists ($BINARY)"
  else
    fail "B.2 binary exists" "Build did not produce $BINARY"
  fi

  if [ -f "$BINARY" ] && file "$BINARY" | grep -qiE 'with debug_info|not stripped'; then
    ok "B.3 binary has debug symbols"
  elif [ -f "$BINARY" ] && readelf -S "$BINARY" 2>/dev/null | grep -q '\.debug_info'; then
    ok "B.3 binary has debug symbols"
  else
    fail "B.3 binary has debug symbols" "Rebuild with -DCMAKE_BUILD_TYPE=Debug; rm -rf build on Release cache"
  fi
fi

# --- C. CLI gdb batch (fixed-doc recipes, -nx isolates demo .gdbinit drift) ---
if [ -f "$BINARY" ] && have gdb; then
  if run_to 120 /tmp/gdb-c1.log gdb -nx -batch \
    -ex 'set pagination off' -ex 'set confirm off' -ex 'set breakpoint pending on' \
    -ex 'set print pretty on' -ex 'set print object on' \
    "$BINARY" \
    -ex 'break src/main.cpp:100' -ex run -ex 'next' \
    -ex 'print *res' -ex 'continue' -ex quit; then
    if grep -q 'id_ = 42' /tmp/gdb-c1.log; then
      ok "C.1 deref unique_ptr (*res shows id_ = 42)"
    else
      fail "C.1 deref unique_ptr (*res shows id_ = 42)" "See /tmp/gdb-c1.log"
    fi
  else
    fail "C.1 deref unique_ptr" "gdb batch failed; see /tmp/gdb-c1.log"
  fi

  if run_to 120 /tmp/gdb-c2.log gdb -nx -batch \
    -ex 'set pagination off' -ex 'set confirm off' -ex 'set breakpoint pending on' \
    "$BINARY" \
    -ex 'break main' -ex run \
    -ex 'print std::get<0>(v)' -ex 'continue' -ex quit; then
    if grep -q 'variant demo' /tmp/gdb-c2.log; then
      ok "C.2 variant inspect (std::get<0>(v) shows variant demo)"
    else
      fail "C.2 variant inspect" "See /tmp/gdb-c2.log"
    fi
  else
    fail "C.2 variant inspect" "gdb batch failed; see /tmp/gdb-c2.log"
  fi

  if run_to 120 /tmp/gdb-c3.log gdb -nx -batch \
    -ex 'set pagination off' -ex 'set confirm off' -ex 'set breakpoint pending on' \
    "$BINARY" \
    -ex 'break src/main.cpp:139' -ex run -ex 'next' \
    -ex 'print safe_null' -ex 'continue' -ex quit; then
    ok "C.3 optional inspect (safe_null printable without crash)"
  else
    fail "C.3 optional inspect" "gdb batch failed; see /tmp/gdb-c3.log"
  fi
fi

# --- D. gdb record smoke (best-effort; arch failures are SKIP) ---
if [ -f "$BINARY" ] && have gdb; then
  if run_to 60 /tmp/gdb-record.log gdb -nx -batch \
    -ex 'set pagination off' -ex 'set confirm off' \
    "$BINARY" \
    -ex 'break main' -ex run -ex record -ex 'next' \
    -ex reverse-next -ex 'record stop' -ex continue -ex quit; then
    ok "D.1 gdb record reverse-step works"
  else
    skip "D.1 gdb record reverse-step" "Best-effort only; fails on some syscalls/AVX/aarch64. See /tmp/gdb-record.log"
  fi
fi

# --- E. rr smoke (failures are SKIP; aarch64 is suspect #1, not the config) ---
if [ -f "$BINARY" ] && have rr; then
  if run_to 120 /tmp/gdb-rr.log bash -c "cd '$DEMO_DIR' && rr record ./build/debug_demo"; then
    ok "E.1 rr record works"
  else
    skip "E.1 rr record" "rr is x86_64-focused; failure on aarch64 is architecture, not config. See /tmp/gdb-rr.log"
  fi
else
  skip "E.1 rr record" "rr or binary missing"
fi

# --- F. init.el Sec.21 expectations (hard failures) ---
INIT_EL="$PROJECT_DIR/src/init.el"
if [ -f "$INIT_EL" ]; then
  if grep -q "(defun my/cpp-debug " "$INIT_EL" && grep -q 'my/gdb-init-args' "$INIT_EL"; then
    ok "F.1 init.el defines my/cpp-debug with integrated gdb flags"
  else
    fail "F.1 init.el defines my/cpp-debug with integrated gdb flags" "Sec.21 must define my/cpp-debug + my/gdb-init-args"
  fi
  if grep -q "(defun my/gdb-no-completions " "$INIT_EL"; then
    ok "F.2 init.el disables completions in GDB buffers"
  else
    fail "F.2 init.el disables completions in GDB buffers" "Sec.21 must define my/gdb-no-completions"
  fi
  if ! grep -q 'gud-mode-map (kbd' "$INIT_EL" && ! grep -q 'gud-minor-mode-map (kbd' "$INIT_EL"; then
    ok "F.3 init.el has no custom GDB keybindings (built-in aliases only)"
  else
    fail "F.3 init.el has no custom GDB keybindings" "Sec.21 must not bind gud-mode-map/gud-minor-mode-map"
  fi
  if grep -q 'gdb-many-windows' "$INIT_EL" && grep -q 'gud-tooltip-mode' "$INIT_EL"; then
    ok "F.4 init.el sets gdb-many-windows layout + tooltips"
  else
    fail "F.4 init.el sets gdb-many-windows layout + tooltips" "Sec.21 must set gdb-many-windows/gdb-show-main and gud-tooltip-mode"
  fi
  if grep -q 'setq compile-command "cmake -B build' "$INIT_EL"; then
    fail "F.5 init.el avoids global compile-command clobber" "Build command lives in my/cpp-debug, not global"
  else
    ok "F.5 init.el avoids global compile-command clobber"
  fi
else
  skip "F. init.el checks" "src/init.el not found"
fi

echo ""
echo "# GDB workflow: $PASS passed, $FAIL failed, $SKIP skipped"
if [ "$FAIL" -gt 0 ]; then
  echo "# RESULT: FAILED"
  exit 1
fi
echo "# RESULT: PASSED"
exit 0
