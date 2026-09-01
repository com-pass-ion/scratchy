#!/bin/bash
# Test: Agent Research Documentation
# Verifies that the agentic SOA research document exists and contains key sections

set -e

TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$TEST_DIR")"
RESEARCH_DOC="$PROJECT_DIR/doc/agent-research/AGENTIC-SOA-RESEARCH.org"

echo "=== Testing Agent Research Documentation ==="

# Test 1: Research document exists
echo -n "Test 1: Research document exists... "
if [[ -f "$RESEARCH_DOC" ]]; then
    echo "PASS"
else
    echo "FAIL - Document not found"
    exit 1
fi

# Test 2: Document has required sections
echo -n "Test 2: Document has required sections... "
REQUIRED_SECTIONS=(
    "Executive Summary"
    "Core Concepts"
    "Communication Protocols"
    "Agent Lifecycle Management"
    "Orchestration Patterns"
    "Choreography vs Orchestration"
    "State Management"
    "Security Patterns"
    "Monitoring and Observability"
    "Recommendations"
)

MISSING=0
for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! grep -q "$section" "$RESEARCH_DOC"; then
        echo "FAIL - Missing section: $section"
        MISSING=1
    fi
done

if [[ $MISSING -eq 0 ]]; then
    echo "PASS"
else
    exit 1
fi

# Test 3: Document has SOA agent patterns
echo -n "Test 3: Document has SOA agent patterns... "
if grep -q "SOA Agent" "$RESEARCH_DOC" && grep -q "Harness-ability" "$RESEARCH_DOC"; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Test 4: Document has lifecycle management
echo -n "Test 4: Document has lifecycle management... "
if grep -q "spawn" "$RESEARCH_DOC" && grep -q "suspend" "$RESEARCH_DOC" && grep -q "resume" "$RESEARCH_DOC"; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Test 5: Document has orchestration patterns
echo -n "Test 5: Document has orchestration patterns... "
if grep -q "Sequential" "$RESEARCH_DOC" && grep -q "Concurrent" "$RESEARCH_DOC" && grep -q "Magentic" "$RESEARCH_DOC"; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Test 6: Document has recommendations
echo -n "Test 6: Document has recommendations... "
if grep -q "Recommendations for Emacs Implementation" "$RESEARCH_DOC"; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

echo ""
echo "=== All Agent Research Tests Passed ==="
