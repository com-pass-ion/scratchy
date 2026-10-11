#!/bin/bash
# local-ci.sh — single entry point for process validation.
# This script is the server-side fallback and orchestrates all governance checks.
#
# Exits with 0 if all checks pass, non-zero otherwise.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo "=== Local CI: Process Validation ==="

# 1. Schema Validation of .cycle_state.json
if [ -f "$PROJECT_DIR/.cycle_state.json" ]; then
    echo "Checking cycle state schema..."
    python3 -c "import json; json.load(open('$PROJECT_DIR/.cycle_state.json'))" >/dev/null || {
        echo "ERROR: .cycle_state.json is not valid JSON" >&2
        exit 1
    }
    # Simple schema check using python
    python3 -c "
import json
try:
    with open('$PROJECT_DIR/.cycle_state.json') as f:
        d = json.load(f)
    required = ['cycle_id', 'state', 'goal', 'started']
    if not all(k in d for k in required):
        raise ValueError(f'Missing required fields: {set(required) - set(d.keys())}')
    if d['state'] not in ['PLANNING', 'ACTIVE', 'CLOSING', 'ARCHIVED']:
        raise ValueError(f'Invalid state: {d[\"state\"]}')
except Exception as e:
    print(f'ERROR: schema validation failed: {e}')
    exit(1)
" || exit 1
else
    echo "ERROR: .cycle_state.json not found" >&2
    exit 1
fi

# 2. Governance Checksums
echo "Checking governance checksums..."
bash "$SCRIPT_DIR/governance-checksum.sh" --check

# 3. State Machine/Recovery check (if in a commit context)
# Note: validate-commit.sh handles its own logic; we use it here to check the current state.
# Since we aren't in a commit-msg hook, we simulate a valid commit message to check the state.
echo "Checking current cycle state gate..."
TMP_MSG=$(mktemp)
printf 'chore(ci): check state [C2]\n' > "$TMP_MSG"
bash "$SCRIPT_DIR/validate-commit.sh" "$TMP_MSG" || {
    echo "ERROR: cycle state gate is CLOSED (not ACTIVE). Recovery is required for commits." >&2
    rm -f "$TMP_MSG"
    exit 1
}
rm -f "$TMP_MSG"

echo "=== Local CI: All checks PASSED ==="
exit 0
