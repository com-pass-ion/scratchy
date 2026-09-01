#!/bin/bash
# validate_process_files.sh — Scrum Document Safety Guard
# Validates that RULES.md, SCRUM-WORKFLOW.md, and PROMPT.md
# are not modified without explicit approval.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

PROCESS_FILES=(
    "scrum/RULES.md"
    "scrum/SCRUM-WORKFLOW.md"
    "scrum/PROMPT.md"
)

ERRORS=0

for file in "${PROCESS_FILES[@]}"; do
    filepath="$PROJECT_DIR/$file"
    if [ -f "$filepath" ]; then
        # Check if file is staged for commit
        if git -C "$PROJECT_DIR" diff --cached --name-only | grep -q "$(basename "$file")"; then
            # Check if there are actual changes
            if ! git -C "$PROJECT_DIR" diff --cached --quiet -- "$file" 2>/dev/null; then
                echo "ERROR: Unauthorized change detected in $file"
                echo "       Process files require explicit user approval to modify."
                ERRORS=$((ERRORS + 1))
            fi
        fi
    fi
done

if [ "$ERRORS" -gt 0 ]; then
    echo ""
    echo "Commit blocked: $ERRORS process file(s) modified without approval."
    echo "See scrum/RULES.md > Agent Safety > Scrum Document Safety"
    exit 1
fi

exit 0