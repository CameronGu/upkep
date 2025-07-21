#!/bin/bash
# test_runner.sh - Main test runner for Auto-Maintainer

BASE_DIR="$(dirname "$0")/.."
MODULES_DIR="$BASE_DIR/scripts/modules"
TEST_DIR="$(dirname "$0")/test_cases"

echo "==== Auto-Maintainer Test Runner ===="
echo "Running all test cases in $TEST_DIR"
echo

for test_case in "$TEST_DIR"/*.sh; do
    echo "→ Running $(basename "$test_case")"
    if [[ ! -f "$test_case" ]]; then
        echo "   ✖ Test file not found: $test_case"
        continue
    fi
    bash "$test_case"
    if [[ $? -eq 0 ]]; then
        echo "   ✔ Passed"
    else
        echo "   ✖ Failed"
    fi
    echo
done

echo "All tests completed."