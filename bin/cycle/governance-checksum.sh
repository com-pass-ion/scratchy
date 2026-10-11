#!/bin/bash
# governance-checksum.sh — pin and verify the immutable governance files.
#
#   (no args)  regenerate cycle/governance.sha256
#   --check    verify the tree against cycle/governance.sha256
#
# Immutable governance: AGENTS.md, docs/cycle/RULES.md, docs/cycle/PROMPT.md.
# NEXT.md is intentionally excluded; it is the mutable working plan.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
CHECKSUM_FILE="cycle/governance.sha256"
GOVERNANCE_FILES=(
    "AGENTS.md"
    "docs/cycle/RULES.md"
    "docs/cycle/PROMPT.md"
)

usage() {
    echo "usage: $(basename "$0") [--check]" >&2
    exit 2
}

case "${1:-}" in
    "")
        ( cd "$PROJECT_DIR" && sha256sum "${GOVERNANCE_FILES[@]}" > "$CHECKSUM_FILE" )
        echo "Wrote $CHECKSUM_FILE"
        ;;
    --check)
        if [ ! -f "$PROJECT_DIR/$CHECKSUM_FILE" ]; then
            echo "ERROR: $CHECKSUM_FILE not found; run without --check to generate." >&2
            exit 1
        fi
        ( cd "$PROJECT_DIR" && sha256sum --check --status "$CHECKSUM_FILE" ) || {
            echo "GOVERNANCE_VIOLATION: One or more immutable governance files have been modified." >&2
            echo "The following files are protected: ${GOVERNANCE_FILES[*]}" >&2
            echo "To authorize these changes, regenerate the checksum: bash bin/cycle/governance-checksum.sh" >&2
            exit 1
        }
        echo "Governance checksums OK."
        ;;
    *)
        usage
        ;;
esac
