#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo " Emacs Config Test Suite (Fresh Install)"
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

# Function to run emacs in a totally isolated environment to verify fresh install
run_isolated_emacs() {
    local tmp_dir=$(mktemp -d)
    # We set USER_EMACS_DIRECTORY for the config and package-user-dir for the installed packages.
    # This ensures no leakage from ~/.emacs.d.
    USER_EMACS_DIRECTORY="$tmp_dir" \
    emacs --batch \
          --eval "(setq package-user-dir \"$tmp_dir/elpa\")" \
          "$@"
    rm -rf "$tmp_dir"
}

echo "--- Environment Sync ---"
# Verify that init.el can bootstrap itself from scratch
run_isolated_emacs -l "$SCRIPT_DIR/../src/init.el" --eval "(package-initialize)"

echo ""
# Run module tests
echo "--- Module Tests ---"
run_isolated_emacs -l "$SCRIPT_DIR/test_init.el"

echo ""
# Run integration tests
echo "--- Integration Tests ---"
run_isolated_emacs -l "$SCRIPT_DIR/test_integration.el"

echo ""
# Run GDB workflow tests
echo "--- GDB Workflow Tests ---"
# Note: test_gdb_workflow.sh might need internal modifications to be isolated.
# For now we run it; if it uses emacs, it should ideally use the same isolation.
bash "$SCRIPT_DIR/test_gdb_workflow.sh"

echo ""
# Byte-compile check (STRICT MODE)
echo "--- Byte-Compile Check ---"
run_isolated_emacs \
    --eval "(package-initialize)" \
    --eval "(require 'use-package)" \
    --eval "(setq byte-compile-error-on-warn t)" \
    -f batch-byte-compile "$SCRIPT_DIR/../src/init.el"
rm -f "$SCRIPT_DIR/../src/init.elc"

echo ""
# Security scan
echo "--- Security Scan ---"
if grep -rni "password\|secret\|api.key" "$SCRIPT_DIR/../src" "$SCRIPT_DIR" | grep -vE "grep -rni|ERROR: Secrets found|No secrets found" ; then
    echo "ERROR: Secrets found in codebase!"
    exit 1
else
    echo "No secrets found."
fi


