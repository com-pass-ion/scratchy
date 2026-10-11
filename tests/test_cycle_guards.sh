#!/bin/bash
# test_cycle_guards.sh — test suite for cycle process guards.
# This is a table-driven test of the validator, checksums, and state gate.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."
VALIDATOR="$PROJECT_DIR/bin/cycle/validate-commit.sh"
CHECKSUM_TOOL="$PROJECT_DIR/bin/cycle/governance-checksum.sh"
STATE_FILE="$PROJECT_DIR/.cycle_state.json"

echo "=== Testing Cycle Guards ==="

# Setup: ensure ACTIVE state
python3 -c "import json; d=json.load(open('$STATE_FILE')); d['state']='ACTIVE'; json.dump(d, open('$STATE_FILE','w'))"

# Helper to test validate-commit exit codes
# Usage: assert_commit_exit "description" "message" expected_exit
assert_commit_exit() {
    local desc="$1"
    local msg="$2"
    local exp="$3"
    local f=$(mktemp)
    printf "%s\n" "$msg" > "$f"
    echo "Running: $desc"
    if bash "$VALIDATOR" "$f" >/dev/null 2>&1; then
        local got=0
    else
        local got=1
    fi
    rm -f "$f"
    if [ "$got" -eq "$exp" ]; then
        echo "PASS: $desc"
    else
        echo "FAIL: $desc (exp $exp, got $got)"
        exit 1
    fi
}

# 1. Test Format and Legacy tags
assert_commit_exit "valid full" "feat(lsp): add eglot [C2] [3sp] [#nix]" 0
assert_commit_exit "valid min" "fix(cycle): empty [C2]" 0
assert_commit_exit "legacy S" "feat(lsp): add eglot [S2]" 1
assert_commit_exit "no type" "add eglot [C2]" 1
assert_commit_exit "no scope" "feat: add eglot [C2]" 1
assert_commit_exit "no cycle" "feat(lsp): add eglot" 1
assert_commit_exit "wrong id" "feat(lsp): add eglot [C1]" 1
assert_commit_exit "merge" "Merge branch x" 0

# 2. Test Governance Checksums
echo "Testing checksums..."
# Initial generation
bash "$CHECKSUM_TOOL" >/dev/null
bash "$CHECKSUM_TOOL" --check >/dev/null || { echo "FAIL: clean tree should pass"; exit 1; }
# Tamper
printf '\n' >> "$PROJECT_DIR/docs/cycle/PROMPT.md"
if bash "$CHECKSUM_TOOL" --check >/dev/null 2>&1; then
    echo "FAIL: tamper should fail"
    git restore "$PROJECT_DIR/docs/cycle/PROMPT.md"
    exit 1
fi
git restore "$PROJECT_DIR/docs/cycle/PROMPT.md"

# 3. Test State Gate
echo "Testing state gate..."
# Setup: ensure ACTIVE
python3 -c "import json; d=json.load(open('$STATE_FILE')); d['state']='ACTIVE'; json.dump(d, open('$STATE_FILE','w'))"
assert_commit_exit "active gate" "chore(ci): check [C2]" 0

# Setup: CLOSING
python3 -c "import json; d=json.load(open('$STATE_FILE')); d['state']='CLOSING'; json.dump(d, open('$STATE_FILE','w'))"
assert_commit_exit "closing gate fail" "chore(ci): check [C2]" 1
# Recovery test (manual call to pass flag)
f_rec=$(mktemp)
printf "chore(ci): recovery [C2]\n" > "$f_rec"
if bash "$VALIDATOR" --recovery "$f_rec" >/dev/null 2>&1; then
    echo "PASS: closing gate recovery"
else
    echo "FAIL: closing gate recovery"
    rm -f "$f_rec"
    exit 1
fi
rm -f "$f_rec"

# Restore state
python3 -c "import json; d=json.load(open('$STATE_FILE')); d['state']='ACTIVE'; json.dump(d, open('$STATE_FILE','w'))"

echo "All guards passed!"
