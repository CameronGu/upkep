#!/bin/bash
# test_execution_summary_boxes.sh - Test enhanced execution summary box functionality

# Load required modules with correct paths
source "$(dirname "$0")/../../scripts/modules/core/utils.sh"

echo "Testing enhanced execution summary box functionality..."

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

# Test 1: Basic execution summary box
test_basic_execution_summary_box() {
    local output=$(draw_execution_summary_box "success" "TEST" "Basic test line")
    [[ -n "$output" && "$output" == *"TEST"* && "$output" == *"Basic test line"* ]]
}

# Test 2: Success summary box with full parameters
test_success_summary_box() {
    local output=$(draw_success_summary_box "APT Update" "12 packages updated successfully" "42 packages upgraded, 0 newly installed, 0 to remove" "12")
    [[ -n "$output" && "$output" == *"APT Update"* && "$output" == *"12 packages updated successfully"* && "$output" == *"Total: 12"* ]]
}

# Test 3: Success summary box with minimal parameters
test_success_summary_box_minimal() {
    local output=$(draw_success_summary_box "Snap Update" "3 packages updated")
    [[ -n "$output" && "$output" == *"Snap Update"* && "$output" == *"3 packages updated"* ]]
}

# Test 4: Warning summary box with full parameters
test_warning_summary_box() {
    local output=$(draw_warning_summary_box "APT Update" "Some packages were held back" "3 packages held back due to dependency conflicts" "3")
    [[ -n "$output" && "$output" == *"APT Update"* && "$output" == *"Some packages were held back"* && "$output" == *"Held: 3"* ]]
}

# Test 5: Warning summary box with minimal parameters
test_warning_summary_box_minimal() {
    local output=$(draw_warning_summary_box "APT Update" "Skipped - too soon")
    [[ -n "$output" && "$output" == *"APT Update"* && "$output" == *"Skipped - too soon"* ]]
}

# Test 6: Error summary box with full parameters
test_error_summary_box() {
    local output=$(draw_error_summary_box "Snap Update" "Failed to refresh snaps" "Network timeout during download" "1")
    [[ -n "$output" && "$output" == *"Snap Update"* && "$output" == *"Failed to refresh snaps"* && "$output" == *"Failed: 1"* ]]
}

# Test 7: Error summary box with minimal parameters
test_error_summary_box_minimal() {
    local output=$(draw_error_summary_box "APT Update" "Update failed")
    [[ -n "$output" && "$output" == *"APT Update"* && "$output" == *"Update failed"* ]]
}

# Test 8: Info summary box
test_info_summary_box() {
    local output=$(draw_info_summary_box "System Status" "All systems operational" "No maintenance required")
    [[ -n "$output" && "$output" == *"System Status"* && "$output" == *"All systems operational"* ]]
}

# Test 9: Empty lines in content
test_empty_lines_in_content() {
    local output=$(draw_execution_summary_box "success" "TEST" "Line 1" "" "Line 3")
    [[ -n "$output" && "$output" == *"Line 1"* && "$output" == *"Line 3"* ]]
}

# Test 10: Different status colors
test_status_colors() {
    local success_output=$(draw_execution_summary_box "success" "SUCCESS TEST" "test")
    local error_output=$(draw_execution_summary_box "error" "ERROR TEST" "test")
    local warning_output=$(draw_execution_summary_box "warning" "WARNING TEST" "test")
    local info_output=$(draw_execution_summary_box "info" "INFO TEST" "test")

    [[ -n "$success_output" && -n "$error_output" && -n "$warning_output" && -n "$info_output" ]]
}

# Test 11: Long content lines
test_long_content_lines() {
    local long_line="This is a very long line that should be handled properly by the box drawing system"
    local output=$(draw_execution_summary_box "info" "LONG LINE TEST" "$long_line")
    [[ -n "$output" && "$output" == *"$long_line"* ]]
}

# Test 12: Special characters in content
test_special_characters() {
    local special_content="Line with special chars: @#$%^&*()_+-=[]{}|;':\",./<>?"
    local output=$(draw_execution_summary_box "warning" "SPECIAL CHARS" "$special_content")
    [[ -n "$output" && "$output" == *"$special_content"* ]]
}

# Test 13: Backward compatibility with draw_status_box
test_backward_compatibility() {
    local output=$(draw_status_box "success" "Backward compatibility test" "LEGACY TEST")
    [[ -n "$output" && "$output" == *"Backward compatibility test"* ]]
}

# Test 14: Box width calculation
test_box_width_calculation() {
    local output=$(draw_execution_summary_box "success" "WIDTH TEST" "test line")
    local line_count=$(echo "$output" | wc -l)
    # Should have at least 3 lines (top border, content, bottom border)
    [[ $line_count -ge 3 ]]
}

# Test 15: Unicode box characters
test_unicode_box_characters() {
    local output=$(draw_execution_summary_box "info" "UNICODE TEST" "test")
    # Check for Unicode box drawing characters
    [[ "$output" == *"┌"* && "$output" == *"┐"* && "$output" == *"└"* && "$output" == *"┘"* && "$output" == *"│"* && "$output" == *"─"* ]]
}

# Run all tests
echo "=== Enhanced Execution Summary Box Tests ==="
echo

run_test "Basic Execution Summary Box" test_basic_execution_summary_box
run_test "Success Summary Box (Full)" test_success_summary_box
run_test "Success Summary Box (Minimal)" test_success_summary_box_minimal
run_test "Warning Summary Box (Full)" test_warning_summary_box
run_test "Warning Summary Box (Minimal)" test_warning_summary_box_minimal
run_test "Error Summary Box (Full)" test_error_summary_box
run_test "Error Summary Box (Minimal)" test_error_summary_box_minimal
run_test "Info Summary Box" test_info_summary_box
run_test "Empty Lines in Content" test_empty_lines_in_content
run_test "Different Status Colors" test_status_colors
run_test "Long Content Lines" test_long_content_lines
run_test "Special Characters" test_special_characters
run_test "Backward Compatibility" test_backward_compatibility
run_test "Box Width Calculation" test_box_width_calculation
run_test "Unicode Box Characters" test_unicode_box_characters

# Test summary
echo
echo "=== Test Summary ==="
echo "Tests passed: $TESTS_PASSED/$TESTS_TOTAL"

if [[ $TESTS_PASSED -eq $TESTS_TOTAL ]]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ Some tests failed. Please check the implementation."
    exit 1
fi