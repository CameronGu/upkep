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

# Demonstrate box_top centering
echo "1. Box Top Centering:"
echo "Title: 'SHORT TITLE'"
box_top "accent_cyan" "SHORT TITLE"
echo

echo "Title: 'VERY LONG TITLE THAT MIGHT OVERFLOW'"
box_top "accent_cyan" "VERY LONG TITLE THAT MIGHT OVERFLOW"
echo

echo "Title: 'MEDIUM TITLE'"
box_top "accent_cyan" "MEDIUM TITLE"
echo

# Demonstrate box_text_line padding
echo "2. Box Text Line Padding:"
echo "Short text:"
box_text_line "success" "Short text"
echo

echo "Medium text:"
box_text_line "success" "This is a medium length text line"
echo

echo "Long text (should wrap or truncate):"
box_text_line "success" "This is a very long text line that might exceed the box width and should be handled appropriately"
echo

# Demonstrate box_line alignment
echo "3. Box Line Left/Right Alignment:"
echo "Short left, short right:"
box_line "info" "Left" "Right"
echo

echo "Long left, short right:"
box_line "info" "Very long left text" "Right"
echo

echo "Short left, long right:"
box_line "info" "Left" "Very long right text"
echo

echo "Equal length:"
box_line "info" "Module" "Status"
echo

# Demonstrate complete boxes
echo "4. Complete Box Examples:"
echo

echo "Success Box:"
draw_box "success" "OPERATION COMPLETE" \
    "✅ Task completed successfully" \
    "⏱️  Execution time: 45 seconds" \
    "📊 12 items processed"
echo

echo "Warning Box:"
draw_box "warning" "ATTENTION REQUIRED" \
    "⚠️  Some items need attention" \
    "🔍 Check the logs for details" \
    "💡 Consider running --fix"
echo

echo "Error Box:"
draw_box "error" "OPERATION FAILED" \
    "❌ Task failed to complete" \
    "🔍 Error: Network timeout" \
    "💡 Check your connection"
echo

# Demonstrate table structure
echo "5. Table Structure:"
echo

box_top "accent_cyan" "SYSTEM STATUS TABLE"
box_line "accent_cyan" "Module" "Status" "Last Run"
box_line "accent_cyan" "─────" "──────" "────────"
box_line "accent_cyan" "APT" "✅ Done" "2 days ago"
box_line "accent_cyan" "Snap" "⚠️ Due" "Now"
box_line "accent_cyan" "Flatpak" "❌ Failed" "1 week ago"
box_line "accent_cyan" "Cleanup" "📋 New" "Never"
box_bottom "accent_cyan"
echo

# Demonstrate spacing calculations
echo "6. Spacing Calculation Examples:"
echo

box_width=$(get_box_width)
echo "Box width: $box_width"
echo "Border characters: 2 (│ and │)"
echo "Available content width: $((box_width - 2))"
echo

echo "Example 1: Title centering"
title=" TEST TITLE "
title_len=${#title}
left=$(( (box_width - title_len) / 2 ))
right=$(( box_width - left - title_len ))
echo "Title: '$title'"
echo "Title length: $title_len"
echo "Left padding: $left"
echo "Right padding: $right"
echo "Total: $((left + title_len + right)) = $box_width"
echo

echo "Example 2: Text line padding"
text="Sample text"
padding=$((box_width - 2))
echo "Text: '$text'"
echo "Text length: ${#text}"
echo "Required padding: $padding"
echo "Total line length: $((2 + ${#text} + padding)) = $((box_width + ${#text}))"
echo

echo "Example 3: Left/right alignment"
left_text="Left"
right_text="Right"
inner=$((box_width - 2))
pad=$(( inner - ${#left_text} - ${#right_text} ))
echo "Left text: '$left_text' (${#left_text} chars)"
echo "Right text: '$right_text' (${#right_text} chars)"
echo "Inner width: $inner"
echo "Padding needed: $pad"
echo "Total: $((2 + ${#left_text} + pad + ${#right_text})) = $box_width"
echo

# Demonstrate responsive behavior
echo "7. Responsive Behavior:"
echo

echo "Current terminal width: $(get_terminal_width)"
echo "Current box width: $(get_box_width)"
echo

# Show what happens with different terminal sizes
echo "If terminal was 50 characters wide:"
TERM_WIDTH_SAVE=$TERM
export TERM="dumb"
small_width=$(get_box_width)
echo "Box width would be: $small_width"
export TERM="$TERM_WIDTH_SAVE"
echo

echo "If terminal was 150 characters wide:"
export TERM="xterm-256color"
large_width=$(get_box_width)
echo "Box width would be: $large_width"
export TERM="$TERM_WIDTH_SAVE"
echo

# Demonstrate color fallback
echo "8. Color Fallback Demonstration:"
echo

echo "Current color support: $(detect_color_support)"
echo "Success color code: $(get_color "success")"
echo "Warning color code: $(get_color "warning")"
echo "Error color code: $(get_color "error")"
echo

# Show what happens with no color support
echo "Simulating no color support:"
original_term="$TERM"
export TERM="dumb"
echo "Color support: $(detect_color_support)"
echo "Success color code: '$(get_color "success")'"
export TERM="$original_term"
echo

echo "=== Box Drawing Demonstration Complete ==="
echo
echo "Key Takeaways:"
echo "• Box width adapts to terminal size (60-120 characters)"
echo "• Title centering divides remaining space equally"
echo "• Text lines use left-aligned padding to fill width"
echo "• Left/right alignment calculates padding between elements"
echo "• Color system provides graceful fallback for limited terminals"
echo "• All calculations ensure proper alignment and spacing" 