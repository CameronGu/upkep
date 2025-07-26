#!/bin/bash
# test_summary_box.sh - Test summary box functionality

# Load required modules with correct paths
source "$(dirname "$0")/../../scripts/modules/core/utils.sh"

echo "Testing summary box functionality..."

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

# Test 1: Status table row creation
test_status_table_row() {
    local output=$(create_status_table_row 60 "APT" "2 days ago" "success" "Done" "5 days")
    [[ -n "$output" && "$output" == *"APT"* && "$output" == *"✅"* ]]
}

# Test 2: Aligned header row creation
test_aligned_header_row() {
    local output=$(create_aligned_header_row 60 "Module" "Last Run" "Status" "Next Due")
    [[ -n "$output" && "$output" == *"Module"* && "$output" == *"Last Run"* ]]
}

# Test 3: Component table row creation
test_component_table_row() {
    local output=$(create_component_table_row 60 "APT" "success" "Updated" "45")
    [[ -n "$output" && "$output" == *"APT"* ]]
}

# Test 4: Component header row creation
test_component_header_row() {
    local output=$(create_component_header_row 60 15 12 8 "Package Manager" "Status" "Packages")
    [[ -n "$output" && "$output" == *"Package Manager"* ]]
}

# Test 5: Auto table row creation
test_auto_table_row() {
    local output=$(create_auto_table_row 60 15 12 8 "APT" "Updated" "45 packages")
    [[ -n "$output" && "$output" == *"APT"* ]]
}

# Test 6: Auto header row creation
test_auto_header_row() {
    local output=$(create_auto_header_row 60 15 12 8 "Module" "Status" "Count")
    [[ -n "$output" && "$output" == *"Module"* ]]
}

# Test 7: Status line creation
test_status_line() {
    local output=$(create_status_line "success" "APT packages updated successfully" "45")
    [[ -n "$output" && "$output" == *"✅"* && "$output" == *"APT packages updated successfully"* ]]
}

# Test 8: Box with summary content
test_summary_box() {
    local summary_content="APT: ✅ Updated (45 packages)\nSnap: ⚠️ Held (3 packages)\nFlatpak: ❌ Failed"
    local output=$(draw_box "$summary_content" "SYSTEM SUMMARY" "info")
    [[ -n "$output" && "$output" == *"SYSTEM SUMMARY"* ]]
}

# Run all tests
echo "=== Summary Box Tests ==="
echo

run_test "Status Table Row Creation" test_status_table_row
run_test "Aligned Header Row Creation" test_aligned_header_row
run_test "Component Table Row Creation" test_component_table_row
run_test "Component Header Row Creation" test_component_header_row
run_test "Auto Table Row Creation" test_auto_table_row
run_test "Auto Header Row Creation" test_auto_header_row
run_test "Status Line Creation" test_status_line
run_test "Summary Box Creation" test_summary_box

echo
echo "=== Test Summary ==="
echo "Tests passed: $TESTS_PASSED/$TESTS_TOTAL"

if [[ $TESTS_PASSED -eq $TESTS_TOTAL ]]; then
    echo "🎉 All summary box tests passed!"
    exit 0
else
    echo "❌ Some tests failed!"
    exit 1
fi
