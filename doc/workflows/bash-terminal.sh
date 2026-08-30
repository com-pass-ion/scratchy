#!/usr/bin/env bash
# =============================================================================
# Workflow Test: Terminal + Execution (Bash)
#
# INSTRUCTIONS:
# 1. Open this file in Emacs
# 2. Test terminal:
#    - C-c t n to open eat terminal (side window)
#    - Run commands in terminal
#    - Terminal persists while you edit
# 3. Test execution:
#    - C-c l r to run this script
#    - Output appears in *compilation* buffer
# 4. Test snippets:
#    - Type "if" then M-+ to expand
#    - Type "for" then M-+ to expand
#    - Type "fun" then M-+ to expand
# 5. Test LSP (bash-language-server):
#    - Wait for [eglot] in mode line
#    - M-. on function to jump to definition
#    - M-? to find references
# =============================================================================

set -euo pipefail

# Test 1: Basic script (verify execution works)
echo "=== Bash Workflow Test ==="
echo "Script running from: $0"
echo "Current directory: $(pwd)"
echo "Date: $(date)"

# Test 2: Variables (verify completion)
NAME="Scratchy"
VERSION="1.0"
echo "Testing: $NAME v$VERSION"

# Test 3: Functions (verify snippets)
greet() {
    local name="$1"
    echo "Hello, $name!"
}

# Type "fun" then M-+ to expand
# fun

# Test 4: Arrays (verify LSP)
FRUITS=("apple" "banana" "cherry")
echo "Fruits: ${FRUITS[*]}"

# Test 5: Loops (verify snippets)
# Type "for" then M-+ to expand
# for

echo "Loop test:"
for fruit in "${FRUITS[@]}"; do
    echo "  - $fruit"
done

# Test 6: Conditionals (verify snippets)
# Type "if" then M-+ to expand
# if

if [[ -f "/etc/os-release" ]]; then
    echo "OS detected: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2)"
else
    echo "OS detection not available"
fi

# Test 7: Case statement
case "${1:-help}" in
    "hello")
        echo "Hello from bash!"
        ;;
    "test")
        echo "Running tests..."
        ;;
    "help"|*)
        echo "Usage: $0 [hello|test]"
        ;;
esac

# Test 8: Terminal test commands
echo ""
echo "=== Terminal Test Commands ==="
echo "Try these in the eat terminal (C-c t n):"
echo "  ls -la"
echo "  pwd"
echo "  echo 'Hello from terminal'"
echo "  htop  # if installed"
echo ""

# Test 9: Exit codes
exit 0

# VERIFICATION:
# - [ ] Terminal opens (C-c t n)
# - [ ] Script runs (C-c l r)
# - [ ] Output appears in compilation buffer
# - [ ] Snippets expand (M-+)
# - [ ] LSP starts (check mode line)
# - [ ] Jump to definition works (M-.)
