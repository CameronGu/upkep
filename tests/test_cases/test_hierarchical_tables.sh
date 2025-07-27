#!/bin/bash
# test_hierarchical_tables.sh - Test hierarchical table functions
# Tests the module overview table with hierarchical display functionality

# Load required modules with correct paths
source "$(dirname "$0")/../../scripts/modules/core/utils.sh"

echo "Testing hierarchical table functions..."

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

# =============================================================================
# TEST FUNCTIONS
# =============================================================================

# Test 1: Hierarchical row creation with proper indentation
test_hierarchical_row() {
    local output=$(create_hierarchical_row 60 "1" "APT" "2 days ago" "success" "Done" "5 days")
    [[ -n "$output" && "$output" == *"├─"* && "$output" == *"APT"* ]]
}

# Test 2: Hierarchical row creation for last child
test_hierarchical_row_last() {
    local output=$(create_hierarchical_row 60 "2" "Snap" "1 day ago" "warning" "Held" "3 days")
    [[ -n "$output" && "$output" == *"└─"* && "$output" == *"Snap"* ]]
}

# Test 3: Category header creation
test_category_header() {
    local output=$(create_category_header 60 "Package Managers")
    [[ -n "$output" && "$output" == *"Package Managers"* ]]
}

# Test 4: Bordered table creation (using existing function)
test_bordered_table() {
    local output=$(create_bordered_table "SYSTEM MAINTENANCE STATUS" 60 "Header Row")
    [[ -n "$output" && "$output" == *"SYSTEM MAINTENANCE STATUS"* && "$output" == *"╭"* && "$output" == *"╮"* ]]
}

# Test 5: Module overview table creation
test_module_overview_table() {
    local output=$(create_module_overview_table "TEST STATUS")
    [[ -n "$output" && "$output" == *"TEST STATUS"* && "$output" == *"Module"* && "$output" == *"Last Run"* ]]
}

# Test 6: Bordered table with sample data
test_bordered_table_with_data() {
    local output=$(create_bordered_table "SAMPLE DATA" 60 "Header Row" "Data Row 1" "Data Row 2")
    [[ -n "$output" && "$output" == *"SAMPLE DATA"* ]]
}

# Test 7: Unicode box drawing characters
test_unicode_box_characters() {
    local output=$(create_bordered_table "UNICODE TEST" 60 "Header Row")
    # Strip color codes and check for Unicode characters
    local stripped_output=$(echo "$output" | sed 's/\x1b\[[0-9;]*m//g')
    [[ -n "$stripped_output" && "$stripped_output" == *"╭"* && "$stripped_output" == *"╮"* ]]
}

# Test 8: Proper indentation levels
test_indentation_levels() {
    local output1=$(create_hierarchical_row 60 "0" "Category" "N/A" "info" "Header" "N/A")
    local output2=$(create_hierarchical_row 60 "1" "Module1" "2 days" "success" "Done" "5 days")
    local output3=$(create_hierarchical_row 60 "2" "Module2" "1 day" "warning" "Held" "3 days")

    [[ -n "$output1" && -n "$output2" && -n "$output3" &&
       "$output1" != *"├─"* && "$output1" != *"└─"* &&
       "$output2" == *"├─"* && "$output3" == *"└─"* ]]
}

# =============================================================================
# RUN TESTS
# =============================================================================

echo "=== Hierarchical Table Tests ==="
echo

run_test "Hierarchical Row Creation" test_hierarchical_row
run_test "Hierarchical Row Last Child" test_hierarchical_row_last
run_test "Category Header Creation" test_category_header
run_test "Bordered Table Creation" test_bordered_table
run_test "Module Overview Table" test_module_overview_table
run_test "Bordered Table with Data" test_bordered_table_with_data
run_test "Unicode Box Characters" test_unicode_box_characters
run_test "Proper Indentation Levels" test_indentation_levels

echo
echo "=== Test Summary ==="
echo "Tests passed: $TESTS_PASSED/$TESTS_TOTAL"

if [[ $TESTS_PASSED -eq $TESTS_TOTAL ]]; then
    echo "🎉 All hierarchical table tests passed!"
    exit 0
else
    echo "❌ Some hierarchical table tests failed!"
    exit 1
fi