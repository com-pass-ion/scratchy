#!/bin/bash
# test_cycle_guards.sh — test suite for cycle process guards.
# This is a table-driven test of the validator, checksums, and state gate.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."
VALIDATOR="$PROJECT_DIR/cycle/bin/validate-commit.sh"
CHECKSUM_TOOL="$PROJECT_DIR/cycle/bin/governance-checksum.sh"
STATE_FILE="$PROJECT_DIR/.cycle_state.json"

echo "=== Testing Cycle Guards ==="

# Setup: ensure ACTIVE state
python3 -c "import json; d=json.load(open('$STATE_FILE')); d['state']='ACTIVE'; json.dump(d, open('$STATE_FILE','w'))"

# Derive the expected cycle id from the state file (never hardcode it).
CYCLE="$(python3 -c 'import json; print(json.load(open("'"$STATE_FILE"'"))["cycle_id"])')"
WRONG_CYCLE="C99"

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
assert_commit_exit "valid full" "feat(lsp): add eglot [$CYCLE] [3sp] [#nix]" 0
assert_commit_exit "valid min" "fix(cycle): empty [$CYCLE]" 0
assert_commit_exit "legacy S" "feat(lsp): add eglot [S2]" 1
assert_commit_exit "no type" "add eglot [$CYCLE]" 1
assert_commit_exit "no scope" "feat: add eglot [$CYCLE]" 1
assert_commit_exit "no cycle" "feat(lsp): add eglot" 1
assert_commit_exit "wrong id" "feat(lsp): add eglot [$WRONG_CYCLE]" 1
assert_commit_exit "merge" "Merge branch x" 0

# 2. Test Governance Checksums
# Back up working-tree state so the test never discards uncommitted edits
# (do NOT use `git restore`: it reverts to the index and destroys local work).
echo "Testing checksums..."
CHECKSUM_BAK=$(mktemp)
PROMPT_BAK=$(mktemp)
trap 'cp "$CHECKSUM_BAK" "$PROJECT_DIR/cycle/governance.sha256"; cp "$PROMPT_BAK" "$PROJECT_DIR/cycle/PROMPT.org"; rm -f "$CHECKSUM_BAK" "$PROMPT_BAK"' EXIT
cp "$PROJECT_DIR/cycle/governance.sha256" "$CHECKSUM_BAK"
cp "$PROJECT_DIR/cycle/PROMPT.org" "$PROMPT_BAK"
# Initial generation
bash "$CHECKSUM_TOOL" >/dev/null
bash "$CHECKSUM_TOOL" --check >/dev/null || { echo "FAIL: clean tree should pass"; exit 1; }
# Tamper
printf '\n' >> "$PROJECT_DIR/cycle/PROMPT.org"
bash "$CHECKSUM_TOOL" --check >/dev/null && { echo "FAIL: tamper should fail"; exit 1; }
cp "$PROMPT_BAK" "$PROJECT_DIR/cycle/PROMPT.org"

# 3. Test State Gate
echo "Testing state gate..."
# Setup: ensure ACTIVE
python3 -c "import json; d=json.load(open('$STATE_FILE')); d['state']='ACTIVE'; json.dump(d, open('$STATE_FILE','w'))"
assert_commit_exit "active gate" "chore(ci): check [$CYCLE]" 0

# Setup: CLOSING
python3 -c "import json; d=json.load(open('$STATE_FILE')); d['state']='CLOSING'; json.dump(d, open('$STATE_FILE','w'))"
assert_commit_exit "closing gate fail" "chore(ci): check [$CYCLE]" 1
# Recovery test (manual call to pass flag)
f_rec=$(mktemp)
printf "chore(ci): recovery [$CYCLE]\n" > "$f_rec"
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
