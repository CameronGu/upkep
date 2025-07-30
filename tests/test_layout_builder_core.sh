#!/bin/bash
# Test script for core layout builder components
# Validates palette.sh, width_helpers.py, box_builder.sh, and layout_loader.sh

set -e

# Colors for test output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_output="$3"
    
    echo -n "Testing $test_name... "
    
    local actual_output
    actual_output=$(eval "$test_command" 2>/dev/null || echo "ERROR")
    
    if [[ "$actual_output" == "$expected_output" ]]; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Expected: '$expected_output'"
        echo "  Got:      '$actual_output'"
        ((TESTS_FAILED++))
    fi
}

# Test palette system
echo "=== Testing Palette System ==="
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts/core" && pwd)"
source "${SCRIPT_DIR}/palette.sh"

# Test emoji retrieval
run_test "emoji success" "get_emoji success" "✅"
run_test "emoji error" "get_emoji error" "❌"
run_test "emoji warning" "get_emoji warning" "❗"

# Test color retrieval
run_test "color success" "get_color success" "32"
run_test "color error" "get_color error" "31"
run_test "color warning" "get_color warning" "33"

# Test colorblind mode
export UPKEP_COLORBLIND=1
choose_palette
run_test "colorblind emoji success" "get_emoji success" "✔"
run_test "colorblind emoji error" "get_emoji error" "✖"
run_test "colorblind color success" "get_color success" "97;1"

# Reset to default mode
export UPKEP_COLORBLIND=0
choose_palette

# Test width helpers
echo -e "\n=== Testing Width Helpers ==="
WIDTH_HELPERS="${SCRIPT_DIR}/width_helpers.py"

run_test "width ASCII" "python3 $WIDTH_HELPERS width 'hello'" "5"
run_test "width emoji" "python3 $WIDTH_HELPERS width '✅'" "2"
run_test "width mixed" "python3 $WIDTH_HELPERS width 'hello ✅'" "7"

# Test truncation
run_test "truncate ellipsis" "python3 $WIDTH_HELPERS truncate 'hello world' 8 ellipsis" "hello …"
run_test "truncate wrap" "python3 $WIDTH_HELPERS fit 'hello world' 8 wrap" "hello\nworld"

# Test box builder DSL
echo -e "\n=== Testing Box Builder DSL ==="
source "${SCRIPT_DIR}/box_builder.sh"

# Test token creation
run_test "make_text" "make_text 'hello'" "text;hello"
run_test "make_emoji" "make_emoji success" "emoji;success"
run_test "make_color" "make_color success" "color;success"

# Test box creation
run_test "box_new" "box_new 40 'Test Box' info" "box_1"
run_test "row_new" "row_new" "row_1"

# Test layout loader
echo -e "\n=== Testing Layout Loader ==="
source "${SCRIPT_DIR}/layout_loader.sh"

# Test simple box creation
run_test "create_simple_box" "create_simple_box 'Test Title' info 40 | head -1" "┌─ Test Title ──────────────────────┐"

# Test JSON rendering (basic)
JSON_DATA='{"title":"JSON Test","style":"info","rows":[{"cells":[{"text":"Hello"},{"emoji":"success"}]}]}'
run_test "JSON rendering" "render_layout_from_json '$JSON_DATA' | head -1" "┌─ JSON Test ───────────────────────┐"

# Test terminal width caching
echo -e "\n=== Testing Terminal Width Caching ==="
run_test "term_cols" "_term_cols; echo \$COLUMNS" "$(tput cols 2>/dev/null || echo 80)"

# Test ASCII fallback
echo -e "\n=== Testing ASCII Fallback ==="
export UPKEP_ASCII=1
run_test "ASCII box" "create_simple_box 'ASCII Test' info 30 | head -1" "+-- ASCII Test --+"
export UPKEP_ASCII=0

# Summary
echo -e "\n=== Test Summary ==="
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi 