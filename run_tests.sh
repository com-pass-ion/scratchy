#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo " Emacs Config Test Suite"
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

# Run tests
emacs --batch -l "$SCRIPT_DIR/test_init.el"
