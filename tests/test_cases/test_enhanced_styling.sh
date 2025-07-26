#!/bin/bash
# test_enhanced_styling.sh - Test enhanced styling system

# Load required modules with correct paths
source "$(dirname "$0")/../../scripts/modules/core/utils.sh"

echo "Testing enhanced styling system..."

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

# Test 1: Color detection
test_color_detection() {
    local support=$(detect_color_support)
    [[ -n "$support" && ("$support" == "24bit" || "$support" == "256" || "$support" == "8" || "$support" == "none") ]]
}

# Test 2: Color retrieval
test_color_retrieval() {
    local success_color=$(get_color "success")
    local warning_color=$(get_color "warning")
    local error_color=$(get_color "error")
    local info_color=$(get_color "info")

    [[ -n "$success_color" && -n "$warning_color" && -n "$error_color" && -n "$info_color" ]]
}

# Test 3: Terminal width detection
test_terminal_width() {
    local width=$(get_terminal_width)
    [[ -n "$width" && "$width" -gt 0 && "$width" -le 2000 ]]
}

# Test 4: Box width calculation
test_box_width() {
    local box_width=$(get_box_width)
    [[ -n "$box_width" && "$box_width" -ge 60 && "$box_width" -le 120 ]]
}

# Test 5: Display width calculation
test_display_width() {
    local text_width=$(get_display_width "Hello World")
    local emoji_width=$(get_display_width "✅")

    [[ "$text_width" -eq 11 && "$emoji_width" -eq 2 ]]
}

# Test 6: Component system
test_component_system() {
    local emoji_comp=$(make_emoji_component "success")
    local text_comp=$(make_text_component "Hello World")
    local color_comp=$(make_color_component "success")
    local spacing_comp=$(make_spacing_component "3")

    [[ "$emoji_comp" == "emoji:success" && \
       "$text_comp" == "text:Hello World" && \
       "$color_comp" == "color:success" && \
       "$spacing_comp" == "spacing:3" ]]
}

# Test 7: Component width calculation
test_component_width() {
    local emoji_comp=$(make_emoji_component "success")
    local text_comp=$(make_text_component "Hello")
    local emoji_width=$(get_component_width "$emoji_comp")
    local text_width=$(get_component_width "$text_comp")

    [[ "$emoji_width" -eq 3 && "$text_width" -eq 5 ]]
}

# Test 8: Component rendering
test_component_rendering() {
    local emoji_comp=$(make_emoji_component "success")
    local text_comp=$(make_text_component "Hello")
    local emoji_rendered=$(render_component "$emoji_comp")
    local text_rendered=$(render_component "$text_comp")

    [[ -n "$emoji_rendered" && -n "$text_rendered" ]]
}

# Test 9: Line composition
test_line_composition() {
    local emoji_comp=$(make_emoji_component "success")
    local text_comp=$(make_text_component "Task completed")
    local line=$(compose_line 0 "$emoji_comp" "$text_comp")

    [[ -n "$line" ]]
}

# Test 10: Emoji map functions
test_emoji_functions() {
    local emoji=$(get_emoji "success")
    local width=$(get_emoji_width "success")
    local spacing=$(get_emoji_spacing "success")

    [[ "$emoji" == "✅" && "$width" -eq 2 && "$spacing" -eq 1 ]]
}

# Test 11: Status line creation
test_status_line() {
    local status_line=$(create_status_line "success" "Task completed successfully" "45")

    [[ -n "$status_line" && "$status_line" == *"✅"* && "$status_line" == *"Task completed successfully"* ]]
}

# Test 12: Draw box function
test_draw_box() {
    local box_output=$(draw_box "This is a test message" "TEST TITLE" "success")

    [[ -n "$box_output" ]]
}

# Test 13: Unicode support
test_unicode_support() {
    local spin="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    [[ "${#spin}" -eq 10 ]]
}

# Run all tests
echo "=== Enhanced Styling System Tests ==="
echo

run_test "Color Detection" test_color_detection
run_test "Color Retrieval" test_color_retrieval
run_test "Terminal Width Detection" test_terminal_width
run_test "Box Width Calculation" test_box_width
run_test "Display Width Calculation" test_display_width
run_test "Component System" test_component_system
run_test "Component Width Calculation" test_component_width
run_test "Component Rendering" test_component_rendering
run_test "Line Composition" test_line_composition
run_test "Emoji Functions" test_emoji_functions
run_test "Status Line Creation" test_status_line
run_test "Draw Box Function" test_draw_box
run_test "Unicode Support" test_unicode_support

echo
echo "=== Test Summary ==="
echo "Tests passed: $TESTS_PASSED/$TESTS_TOTAL"

if [[ $TESTS_PASSED -eq $TESTS_TOTAL ]]; then
    echo "🎉 All enhanced styling tests passed!"
    exit 0
else
    echo "❌ Some tests failed!"
    exit 1
fi