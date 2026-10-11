#!/bin/bash
# setup-hooks.sh — Activate git pre-commit hooks

set -e

HOOK_SOURCE="tests/git-pre-commit"
HOOK_DEST=".git/hooks/pre-commit"

if [ ! -f "$HOOK_SOURCE" ]; then
    echo "ERROR: Source hook $HOOK_SOURCE not found!"
    exit 1
fi

echo "Installing pre-commit hook..."
ln -sf "$(pwd)/$HOOK_SOURCE" "$HOOK_DEST"
chmod +x "$HOOK_DEST"

echo "Installing commit-msg hook..."
ln -sf "$(pwd)/tests/git-commit-msg" ".git/hooks/commit-msg"
chmod +x ".git/hooks/commit-msg"

echo "Installing post-commit hook..."
ln -sf "$(pwd)/tests/git-post-commit" ".git/hooks/post-commit"
chmod +x ".git/hooks/post-commit"

echo "Hooks activated successfully."
