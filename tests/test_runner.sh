#!/bin/bash
# test_runner.sh - Enhanced test runner for upKep Linux Maintainer

BASE_DIR="$(dirname "$0")/.."
MODULES_DIR="$BASE_DIR/scripts/modules"
TEST_DIR="$(dirname "$0")/test_cases"

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_color() {
    local color="$1"
    local text="$2"
    echo -e "${color}${text}${NC}"
}

echo "==== upKep Linux Maintainer Test Runner ===="
echo "Running all test cases in $TEST_DIR"
echo ""

# Check if test directory exists
if [[ ! -d "$TEST_DIR" ]]; then
    print_color "$RED" "✗ Test directory not found: $TEST_DIR"
    exit 1
fi

# Run tests in specific order for better organization
test_order=(
    "test_utils.sh"
    "test_ascii_art.sh"
    "test_formatting.sh"
    "test_config_management.sh"
    "test_simple_env_overrides.sh"
    "test_state.sh"
    "test_interval_logic.sh"
    "test_core_modules.sh"
    "test_status_vars.sh"
    "test_summary_box.sh"
    "test_skip_note.sh"
    "test_flags.sh"
)

# Run tests in order if they exist, then any remaining tests
for test_case in "${test_order[@]}"; do
    test_file="$TEST_DIR/$test_case"
    if [[ -f "$test_file" ]]; then
        ((TOTAL_TESTS++))
        print_color "$BLUE" "→ Running $test_case"
        
        if bash "$test_file"; then
            print_color "$GREEN" "   ✔ Passed"
            ((PASSED_TESTS++))
        else
            print_color "$RED" "   ✖ Failed"
            ((FAILED_TESTS++))
        fi
        echo ""
    fi
done

# Run any remaining test files not in the ordered list
for test_case in "$TEST_DIR"/*.sh; do
    if [[ -f "$test_case" ]]; then
        test_name=$(basename "$test_case")
        
        # Skip if already run
        if [[ " ${test_order[*]} " == *" $test_name "* ]]; then
            continue
        fi
        
        ((TOTAL_TESTS++))
        print_color "$BLUE" "→ Running $test_name"
        
        if bash "$test_case"; then
            print_color "$GREEN" "   ✔ Passed"
            ((PASSED_TESTS++))
        else
            print_color "$RED" "   ✖ Failed"
            ((FAILED_TESTS++))
        fi
        echo ""
    fi
done

# Report final results
echo "==== Test Summary ===="
echo "Total tests run: $TOTAL_TESTS"
print_color "$GREEN" "Tests passed: $PASSED_TESTS"

if [[ $FAILED_TESTS -gt 0 ]]; then
    print_color "$RED" "Tests failed: $FAILED_TESTS"
fi

echo ""

# Calculate success rate
if [[ $TOTAL_TESTS -gt 0 ]]; then
    success_rate=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    echo "Success rate: ${success_rate}%"
    
    if [[ $success_rate -eq 100 ]]; then
        print_color "$GREEN" "🎉 All tests passed!"
        exit 0
    elif [[ $success_rate -ge 80 ]]; then
        print_color "$YELLOW" "⚠️  Most tests passed, but some need attention."
        exit 1
    else
        print_color "$RED" "❌ Many tests failed. Immediate attention required."
        exit 1
    fi
else
    print_color "$YELLOW" "⚠️  No tests found to run."
    exit 1
fi