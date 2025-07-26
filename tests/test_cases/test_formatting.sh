#!/bin/bash
# test_formatting.sh - Test box formatting

# Load required modules with correct paths
source "$(dirname "$0")/../../scripts/modules/core/utils.sh"

echo "Testing box formatting..."

# Test counter
TESTS_PASSED=0
TESTS_TOTAL=0

# Test helper function
run_test() {
    local test_name="$1"
    local test_command="$2"

    ((TESTS_TOTAL++))
    echo "Running test: $test_name"

    if eval "$test_command"; then
        echo "✓ PASS: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $test_name"
        return 1
    fi
}

# Test 1: Basic box drawing
test_basic_box() {
    local output=$(draw_box "This is a test message")
    [[ -n "$output" && "$output" == *"This is a test message"* ]]
}

# Test 2: Box with title
test_box_with_title() {
    local output=$(draw_box "This is a test message" "TEST TITLE")
    [[ -n "$output" && "$output" == *"TEST TITLE"* ]]
}

# Test 3: Box with color
test_box_with_color() {
    local output=$(draw_box "This is a test message" "" "success")
    [[ -n "$output" ]]
}

# Test 4: Box with title and color
test_box_with_title_and_color() {
    local output=$(draw_box "This is a test message" "TEST TITLE" "success")
    [[ -n "$output" && "$output" == *"TEST TITLE"* ]]
}

# Test 5: Status box
test_status_box() {
    local output=$(draw_status_box "success" "Task completed successfully" "OPERATION COMPLETE")
    [[ -n "$output" && "$output" == *"Task completed successfully"* ]]
}

# Test 6: Component-based box drawing
test_component_box() {
    local emoji_comp=$(make_emoji_component "success")
    local text_comp=$(make_text_component "Component-based test")
    local line=$(compose_line 0 "$emoji_comp" "$text_comp")
    [[ -n "$line" ]]
}

# Run all tests
echo "=== Box Formatting Tests ==="
echo

run_test "Basic Box Drawing" test_basic_box
run_test "Box with Title" test_box_with_title
run_test "Box with Color" test_box_with_color
run_test "Box with Title and Color" test_box_with_title_and_color
run_test "Status Box" test_status_box
run_test "Component-based Box" test_component_box

echo
echo "=== Test Summary ==="
echo "Tests passed: $TESTS_PASSED/$TESTS_TOTAL"

if [[ $TESTS_PASSED -eq $TESTS_TOTAL ]]; then
    echo "🎉 All box formatting tests passed!"
    exit 0
else
    echo "❌ Some tests failed!"
    exit 1
fi
