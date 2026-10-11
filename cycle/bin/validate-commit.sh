#!/bin/bash
# validate-commit.sh — enforce the cycle commit convention.
#
# Usage: validate-commit.sh [--recovery] <commit-msg-file>
#
# Intended as a git `commit-msg` hook (git passes the message file as $1).
# The message is treated strictly as data: no `eval`, every expansion quoted.
#
# Convention:
#   <type>(<scope>): <description> [C<N>] [Xsp] [#item]
# where <type> is one of feat|fix|docs|test|chore|refactor|style|perf|build|ci,
# [C<N>] is required, and [Xsp]/[#item] are optional. Legacy [S<N>] is rejected.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
STATE_FILE="$PROJECT_DIR/.cycle_state.json"

RECOVERY=0
MSG_FILE=""
for arg in "$@"; do
    case "$arg" in
        --recovery) RECOVERY=1 ;;
        -*) echo "ERROR: unknown option: $arg" >&2; exit 2 ;;
        *) MSG_FILE="$arg" ;;
    esac
done

if [ -z "$MSG_FILE" ] || [ ! -f "$MSG_FILE" ]; then
    echo "usage: $(basename "$0") [--recovery] <commit-msg-file>" >&2
    exit 2
fi

# --- First meaningful line: skip blanks and git comment lines. ---
subject=""
while IFS= read -r line; do
    case "$line" in
        ''|'#'*) continue ;;
        *) subject="$line"; break ;;
    esac
done < "$MSG_FILE"

if [ -z "$subject" ]; then
    echo "ERROR: empty commit message." >&2
    exit 1
fi

# Merge commits are not subject to the convention.
case "$subject" in
    Merge*) exit 0 ;;
esac

# --- Legacy marker check (distinct, explicit message). ---
if [[ "$subject" =~ \[S[0-9]+\] ]]; then
    echo "ERROR: legacy [S<N>] marker is forbidden; use [C<N>]." >&2
    exit 1
fi

# --- Format check. ---
PATTERN='^(feat|fix|docs|test|chore|refactor|style|perf|build|ci)\([^)]+\): .+ \[C[0-9]+(-CLOSE)?\]( \[[0-9]+sp\])?( \[#[A-Za-z0-9._-]+\])?$'
if [[ ! "$subject" =~ $PATTERN ]]; then
    echo "ERROR: commit subject does not match the convention." >&2
    echo "       <type>(<scope>): <description> [C<N>] [Xsp] [#item]" >&2
    echo "       got: $subject" >&2
    exit 1
fi

# --- Cycle id check against state, falling back to git log. ---
if [[ "$subject" =~ \[C([0-9]+)(-CLOSE)?\] ]]; then
    commit_cycle="C${BASH_REMATCH[1]}"
else
    echo "ERROR: could not extract [C<N>] from subject." >&2
    exit 1
fi

expected_cycle=""
if [ -f "$STATE_FILE" ] && command -v python3 >/dev/null 2>&1; then
    expected_cycle="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["cycle_id"])' "$STATE_FILE" 2>/dev/null || true)"
fi
if [ -z "$expected_cycle" ]; then
    expected_cycle="$(git -C "$PROJECT_DIR" log --format='%s' -n 200 2>/dev/null \
        | grep -oE '\[C[0-9]+\]' | head -1 | tr -d '[]' || true)"
fi

if [ -n "$expected_cycle" ] && [ "$commit_cycle" != "$expected_cycle" ]; then
    echo "ERROR: commit cycle $commit_cycle does not match expected $expected_cycle." >&2
    exit 1
fi

# --- Active-cycle gate. Bypassable via --recovery or cycle.bypass; the format
#     and cycle-id checks above are never bypassable. ---
if [ -f "$STATE_FILE" ] && command -v python3 >/dev/null 2>&1; then
    state="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["state"])' "$STATE_FILE" 2>/dev/null || true)"
    bypass_cfg="$(git -C "$PROJECT_DIR" config --bool cycle.bypass 2>/dev/null || true)"
    if [ -n "$state" ] && [ "$state" != "ACTIVE" ]; then
        if [ "$RECOVERY" -eq 1 ] || [ "$bypass_cfg" = "true" ]; then
            echo "WARNING: cycle $commit_cycle state=$state; closing gate bypassed (recovery)." >&2
        else
            echo "ERROR: no ACTIVE cycle (state=$state)." >&2
            echo "       Recover with: --recovery, or 'git config cycle.bypass true'." >&2
            exit 1
        fi
    fi
fi

echo "Commit message OK ($commit_cycle)."
