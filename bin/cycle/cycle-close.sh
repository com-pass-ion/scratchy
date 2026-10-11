#!/bin/bash
# cycle-close.sh — archive and remove NEXT.md upon cycle completion.
#
# This script handles the transition from ACTIVE to ARCHIVED.
# It appends the plan to CYCLE-HISTORY.org and removes the root NEXT.md.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$PROJECT_DIR")"
NEXT_FILE="$PROJECT_ROOT/NEXT.md"
HISTORY_FILE="$PROJECT_DIR/CYCLE-HISTORY.org"
STATE_FILE="$PROJECT_ROOT/.cycle_state.json"

if [ ! -f "$NEXT_FILE" ]; then
    echo "ERROR: NEXT.md not found. No active plan to close." >&2
    exit 1
fi

# 1. Verify completion
# Check if any pending tasks remain in NEXT.md (look for [ ] )
if grep -q "\[ \]" "$NEXT_FILE"; then
    echo "ERROR: NEXT.md still contains pending tasks. Cannot close cycle." >&2
    exit 1
fi

# 2. Extract Cycle ID
CYCLE_ID=$(python3 -c "import json; print(json.load(open('$STATE_FILE'))['cycle_id'])" 2>/dev/null || echo "Unknown")
DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "Closing Cycle $CYCLE_ID..."

# 3. Archive to CYCLE-HISTORY.org
{
    echo ""
    echo "* Cycle $CYCLE_ID - Closed on $DATE"
    echo "------------------------------------------------------------------"
    cat "$NEXT_FILE"
    echo ""
    echo "------------------------------------------------------------------"
    echo ""
} >> "$HISTORY_FILE"

# 4. Update state to ARCHIVED
python3 -c "
import json
with open('$STATE_FILE', 'r+') as f:
    d = json.load(f)
    d['state'] = 'ARCHIVED'
    f.seek(0)
    json.dump(d, f, indent=2)
    f.truncate()
"

# 5. Remove NEXT.md
rm "$NEXT_FILE"

echo "Cycle $CYCLE_ID archived and NEXT.md removed."
