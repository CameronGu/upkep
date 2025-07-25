#!/bin/bash
# test_modular_system.sh - Test the new component-based modular system

source "$(dirname "$0")/../scripts/modules/core/utils.sh"

echo "=== Component-Based Modular System Test ==="
echo

# Test 1: Emoji map and basic functions
echo "1. Testing Emoji Map and Basic Functions:"
echo "Emoji Key | Emoji | Width | Spacing"
echo "----------|-------|-------|---------"

emoji_keys=("success" "error" "warning" "pending" "running" "timing" "stats" "suggestion")
for key in "${emoji_keys[@]}"; do
    emoji=$(get_emoji "$key")
    width=$(get_emoji_width "$key")
    spacing=$(get_emoji_spacing "$key")
    printf "%-10s | %-5s | %-5s | %-7s\n" "$key" "$emoji" "$width" "$spacing"
done
echo

# Test 2: Component builders
echo "2. Testing Component Builders:"
emoji_comp=$(make_emoji_component "success")
text_comp=$(make_text_component "Hello World")
color_comp=$(make_color_component "success")
spacing_comp=$(make_spacing_component "3")

echo "Emoji component: $emoji_comp"
echo "Text component: $text_comp"
echo "Color component: $color_comp"
echo "Spacing component: $spacing_comp"
echo

# Test 3: Component width calculation
echo "3. Testing Component Width Calculation:"
emoji_width=$(get_component_width "$emoji_comp")
text_width=$(get_component_width "$text_comp")
color_width=$(get_component_width "$color_comp")
spacing_width=$(get_component_width "$spacing_comp")

echo "Emoji width: $emoji_width"
echo "Text width: $text_width"
echo "Color width: $color_width"
echo "Spacing width: $spacing_width"
echo

# Test 4: Component rendering
echo "4. Testing Component Rendering:"
emoji_rendered=$(render_component "$emoji_comp")
text_rendered=$(render_component "$text_comp")
color_rendered=$(render_component "$color_comp")
spacing_rendered=$(render_component "$spacing_comp")

echo "Emoji rendered: '$emoji_rendered'"
echo "Text rendered: '$text_rendered'"
echo "Color rendered: '$color_rendered'"
echo "Spacing rendered: '$spacing_rendered'"
echo

# Test 5: Line composition
echo "5. Testing Line Composition:"
echo "Simple line:"
simple_line=$(compose_line 0 "$emoji_comp" "$text_comp")
echo "$simple_line"
echo

echo "Colored line:"
colored_line=$(compose_line 0 "$color_comp" "$emoji_comp" "$text_comp")
echo "$colored_line"
echo

echo "Padded line (target width 30):"
padded_line=$(compose_line 30 "$emoji_comp" "$text_comp")
echo "'$padded_line'"
echo

# Test 6: Complex composition
echo "6. Testing Complex Composition:"
complex_components=(
    "$(make_color_component "success")"
    "$(make_emoji_component "success")"
    "$(make_spacing_component "1")"
    "$(make_text_component "Task completed successfully")"
    "$(make_color_component "reset")"
)

complex_line=$(compose_line 40 "${complex_components[@]}")
echo "Complex line:"
echo "$complex_line"
echo

# Test 7: Box drawing with colors
echo "7. Testing Box Drawing (With Colors):"
echo "Simple box:"
draw_box "This is a test message"
echo

echo "Titled box:"
draw_box "This is a test message" "Test Title"
echo

echo "Colored success box:"
draw_box "This is a success message" "Success" "success"
echo

echo "Colored error box:"
draw_box "This is an error message" "Error" "error"
echo

echo "Wide box:"
draw_box "Short message" "" "" 50
echo

# Test 8: Status boxes
echo "8. Testing Status Boxes:"
echo "Success status box:"
draw_status_box "success" "All packages updated successfully" "System Update"
echo

echo "Warning status box:"
draw_status_box "warning" "Some packages were held back" "Update Status"
echo

# Test 9: Convenience functions
echo "9. Testing Convenience Functions:"
echo "Status lines:"
echo "$(create_status_line "success" "APT packages updated successfully" "45")"
echo "$(create_status_line "warning" "Some packages were held back" "3")"
echo "$(create_status_line "error" "Failed to update repository")"
echo

echo "Table rows (Component-based):"
# Calculate column widths for component-based table
module_width=$(calculate_column_width "Package Manager" "APT" "Snap")
status_width=$(calculate_column_width "Status" "✅ Updated" "❗ Held")
packages_width=$(calculate_column_width "Packages" "45" "3")

create_component_header_row 50 "$module_width" "$status_width" "$packages_width"
create_component_table_row 50 "APT" "success" "Updated" "45"
create_component_table_row 50 "Snap" "warning" "Held" "3"
echo

# Test 10: Color codes
echo "10. Testing Color Codes:"
echo "$(create_status_line "success" "Success color (green)")"
echo "$(create_status_line "error" "Error color (red)")"
echo "$(create_status_line "warning" "Warning color (yellow)")"
echo "$(create_status_line "info" "Info color (cyan)")"
echo "$(create_status_line "pending" "Pending color (magenta)")"
echo "$(create_status_line "running" "Running color (blue)")"
echo

# Test 11: Error handling
echo "11. Testing Error Handling:"
echo "Unknown emoji:"
unknown_emoji=$(get_emoji "unknown_key")
echo "Result: '$unknown_emoji'"

echo "Unknown emoji width:"
unknown_width=$(get_emoji_width "unknown_key")
echo "Result: $unknown_width"

echo "Unknown color code:"
unknown_color=$(get_color_code "unknown_color")
echo "Result: $unknown_color"
echo

# Test 12: Alignment comparison
echo "12. Testing Alignment Comparison:"
echo "Old way (inconsistent):"
echo "✅ APT packages updated successfully"
echo "⚠️ Some packages were held back"
echo "❌ Failed to update repository"
echo

echo "New way (consistent):"
echo "$(create_status_line "success" "APT packages updated successfully")"
echo "$(create_status_line "warning" "Some packages were held back")"
echo "$(create_status_line "error" "Failed to update repository")"
echo

echo "=== Test Complete ===" 