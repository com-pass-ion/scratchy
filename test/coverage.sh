#!/bin/bash
# Test coverage report for Scratchy
# Shows which sections have tests and counts

echo "========================================"
echo " Test Coverage Report"
echo "========================================"
echo ""

EMACS_CONFIG="src/init.el"
TEST_FILE="test/test_init.el"
INTEGRATION_FILE="test/test_integration.el"

# Count sections in init.el
echo "=== Sections in init.el ==="
grep -n "^;;; [0-9]" "$EMACS_CONFIG" | head -25
echo ""

# Count tests per section (module tests)
echo "=== Module Tests per Section ==="
grep -o "[0-9]*\.[0-9]*" "$TEST_FILE" | sort -t. -k1,1n -k2,2n | uniq -c | awk '{printf "Section %s: %s tests\n", $2, $1}'
echo ""

# Total module tests
TOTAL_TESTS=$(grep -c "test--assert" "$TEST_FILE")
echo "=== Total Module Tests: $TOTAL_TESTS ==="
echo ""

# Total integration tests
INT_TESTS=$(grep -c "inttest--assert" "$INTEGRATION_FILE")
echo "=== Total Integration Tests: $INT_TESTS ==="
echo ""

# Sections with/without tests
echo "=== Module Section Coverage ==="
for i in $(seq 1 21); do
    COUNT=$(grep -o "${i}\.[0-9]*" "$TEST_FILE" | wc -l)
    if [ "$COUNT" -gt 0 ]; then
        echo "  Section $i: $COUNT tests"
    else
        echo "  Section $i: No tests"
    fi
done
echo ""

echo "=== Integration Test Workflow Coverage ==="
for workflow in "LSP + COMPLETION" "GIT + DIFF" "PROJECT + BUILD" "SNIPPETS + COMPLETION" "SEARCH + NAVIGATION" "COMFORT + UX" "THEME + VISUAL" "TERMINAL" "HELP" "DOCKER" "TREE-SITTER" "SESSION"; do
    COUNT=$(grep -c "$workflow" "$INTEGRATION_FILE" 2>/dev/null || true)
    if [ "$COUNT" -gt 0 ] 2>/dev/null; then
        echo "  $workflow: $COUNT tests"
    fi
done
echo ""

echo "========================================"
echo " Report generated: $(date)"
echo "========================================"
