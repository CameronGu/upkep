#!/bin/bash
# box_drawing_demo.sh - Demonstration of box drawing system

# Source the enhanced utils
source "$(dirname "$0")/../scripts/modules/core/utils.sh"

echo "=== Box Drawing System Demonstration ==="
echo

# Show current terminal and box dimensions
echo "Terminal Information:"
echo "Terminal width: $(get_terminal_width) characters"
echo "Box width: $(get_box_width) characters"
echo "Color support: $(detect_color_support)"
echo

# Demonstrate color selection
echo "Color Selection Examples:"
echo -e "Success color: $(get_color "success")This is success text${RESET}"
echo -e "Warning color: $(get_color "warning")This is warning text${RESET}"
echo -e "Error color: $(get_color "error")This is error text${RESET}"
echo -e "Info color: $(get_color "info")This is info text${RESET}"
echo

# Demonstrate box drawing with titles
echo "1. Box Drawing with Titles:"
echo "Title: 'SHORT TITLE'"
draw_box "This is a test message" "SHORT TITLE" "success"
echo

echo "Title: 'VERY LONG TITLE THAT MIGHT OVERFLOW'"
draw_box "This is a test message" "VERY LONG TITLE THAT MIGHT OVERFLOW" "warning"
echo

echo "Title: 'MEDIUM TITLE'"
draw_box "This is a test message" "MEDIUM TITLE" "info"
echo

# Demonstrate different content lengths
echo "2. Box Content Length Examples:"
echo "Short text:"
draw_box "Short text" "CONTENT TEST" "success"
echo

echo "Medium text:"
draw_box "This is a medium length text line" "CONTENT TEST" "success"
echo

echo "Long text (should wrap or truncate):"
draw_box "This is a very long text line that might exceed the box width and should be handled appropriately" "CONTENT TEST" "success"
echo

# Demonstrate component-based line creation
echo "3. Component-Based Line Creation:"
echo "Simple line:"
emoji_comp=$(make_emoji_component "success")
text_comp=$(make_text_component "Task completed")
simple_line=$(compose_line 0 "$emoji_comp" "$text_comp")
echo "$simple_line"
echo

echo "Colored line:"
color_comp=$(make_color_component "success")
colored_line=$(compose_line 0 "$color_comp" "$emoji_comp" "$text_comp")
echo "$colored_line"
echo

echo "Padded line (target width 40):"
padded_line=$(compose_line 40 "$emoji_comp" "$text_comp")
echo "'$padded_line'"
echo

# Demonstrate complete boxes
echo "4. Complete Box Examples:"
echo

echo "Success Box:"
draw_box "Task completed successfully" "OPERATION COMPLETE" "success"
echo

echo "Warning Box:"
draw_box "Some items need attention" "ATTENTION REQUIRED" "warning"
echo

echo "Error Box:"
draw_box "Task failed to complete" "OPERATION FAILED" "error"
echo

# Demonstrate table structure using component system
echo "5. Table Structure Using Component System:"
echo

# Create a simple table using components
echo "Component-based table:"
header_components=(
    "$(make_text_component "Module")"
    "$(make_spacing_component "2")"
    "$(make_text_component "Status")"
    "$(make_spacing_component "2")"
    "$(make_text_component "Count")"
)
header_line=$(compose_line 50 "${header_components[@]}")
echo "$header_line"

# Table rows
row1_components=(
    "$(make_emoji_component "success")"
    "$(make_text_component "APT")"
    "$(make_spacing_component "2")"
    "$(make_text_component "Updated")"
    "$(make_spacing_component "2")"
    "$(make_text_component "45")"
)
row1_line=$(compose_line 50 "${row1_components[@]}")
echo "$row1_line"

row2_components=(
    "$(make_emoji_component "warning")"
    "$(make_text_component "Snap")"
    "$(make_spacing_component "2")"
    "$(make_text_component "Held")"
    "$(make_spacing_component "2")"
    "$(make_text_component "3")"
)
row2_line=$(compose_line 50 "${row2_components[@]}")
echo "$row2_line"
echo

# Demonstrate spacing calculation
echo "6. Spacing Calculation Examples:"
echo

box_width=$(get_box_width)
echo "Box width: $box_width"
echo "Border characters: 2 (│ and │)"
echo "Available content width: $((box_width - 2))"
echo

echo "Example 1: Title centering"
echo "Title: ' TEST TITLE '"
echo "Title length: 12"
echo "Left padding: $(((box_width - 12) / 2))"
echo "Right padding: $(((box_width - 12) / 2))"
echo

echo "Example 2: Component width calculation"
emoji_comp=$(make_emoji_component "success")
text_comp=$(make_text_component "Sample text")
emoji_width=$(get_component_width "$emoji_comp")
text_width=$(get_component_width "$text_comp")
echo "Emoji component width: $emoji_width"
echo "Text component width: $text_width"
echo "Total component width: $((emoji_width + text_width))"
echo

# Demonstrate responsive behavior
echo "7. Responsive Behavior:"
echo

current_terminal=$(get_terminal_width)
current_box=$(get_box_width)
echo "Current terminal width: $current_terminal"
echo "Current box width: $current_box"
echo

# Demonstrate color fallback
echo "8. Color Fallback Demonstration:"
echo

current_color_support=$(detect_color_support)
echo "Current color support: $current_color_support"
echo "Success color code: $(get_color "success")"
echo "Warning color code: $(get_color "warning")"
echo "Error color code: $(get_color "error")"
echo

echo "=== Box Drawing Demonstration Complete ==="
echo
echo "Key Takeaways:"
echo "• Box width adapts to terminal size (60-120 characters)"
echo "• Title centering divides remaining space equally"
echo "• Component system provides flexible line composition"
echo "• Color system provides graceful fallback for limited terminals"
echo "• All calculations ensure proper alignment and spacing"