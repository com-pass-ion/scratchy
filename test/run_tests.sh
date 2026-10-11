#!/bin/bash
set -euo pipefail

# Pipeline Tiers: fast, functional, absolute
TIER=${1:-"absolute"}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo " Emacs Config Test Suite"
echo " TIER: $TIER"
echo "========================================"
echo ""

# Check if emacs is available
if ! command -v emacs &> /dev/null; then
    echo "ERROR: emacs not found in PATH"
    exit 1
fi

echo "Emacs: $(emacs --version | head -1)"
echo "Date:  $(date)"
echo ""

# Function to run emacs in a totally isolated environment
run_isolated_emacs() {
    local tmp_dir=$(mktemp -d)
    USER_EMACS_DIRECTORY="$tmp_dir" \
    emacs --batch \
          --eval "(setq package-user-dir \"$tmp_dir/elpa\")" \
          "$@"
    rm -rf "$tmp_dir"
}

# --- TIER A: FAST-PASS (Every Commit) ---
echo "--- Tier A: Fast-Pass ---"
# 1. Security Scan
if grep -rni "password\|secret\|api.key" "$SCRIPT_DIR/../src" "$SCRIPT_DIR" | grep -vE "grep -rni|ERROR: Secrets found|No secrets found" ; then
    echo "ERROR: Secrets found in codebase!"
    exit 1
else
    echo "Security scan: No secrets found."
fi

# 2. Strict Byte-Compile (against current binary)
echo "--- Strict Byte-Compile ---"
run_isolated_emacs \
    -l "$SCRIPT_DIR/../src/init.el" \
    --eval "(package-initialize)" \
    --eval "(require 'use-package)" \
    --eval "(setq byte-compile-error-on-warn t)" \
    -f batch-byte-compile "$SCRIPT_DIR/../src/init.el"
rm -f "$SCRIPT_DIR/../src/init.elc"

if [[ "$TIER" == "fast" ]]; then
    echo "Fast-Pass completed successfully."
    exit 0
fi

# --- TIER B: FUNCTIONAL-PASS (Code/Test Changes) ---
echo ""
echo "--- Tier B: Functional-Pass ---"
# Process Governance Guards
bash "$SCRIPT_DIR/test_cycle_guards.sh"
# Environment Sync
run_isolated_emacs -l "$SCRIPT_DIR/../src/init.el" --eval "(package-initialize)"

# Module Tests
run_isolated_emacs -l "$SCRIPT_DIR/test_init.el"

# Integration Tests
run_isolated_emacs -l "$SCRIPT_DIR/test_integration.el"

# GDB Workflow Tests
bash "$SCRIPT_DIR/test_gdb_workflow.sh"

# Adopt Script Tests
bash "$SCRIPT_DIR/test_adopt_cpp.sh"

if [[ "$TIER" == "functional" ]]; then
    echo "Functional-Pass completed successfully."
    exit 0
fi

# --- TIER C: ABSOLUTE-PASS (Toolchain/Master Changes) ---
echo ""
echo "--- Tier C: Absolute-Pass ---"
# Verify Emacs source build
if [ -f "$SCRIPT_DIR/../build_emacs_source.sh" ]; then
    echo "Triggering Emacs source build verification..."
    bash "$SCRIPT_DIR/../build_emacs_source.sh"
else
    echo "WARNING: build_emacs_source.sh not found, skipping source build."
fi

echo "Absolute-Pass completed successfully."
