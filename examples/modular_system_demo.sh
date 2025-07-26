#!/bin/bash
# modular_system_demo.sh - Practical examples of the component-based system

source "$(dirname "$0")/../scripts/modules/core/utils.sh"

echo "=== Component-Based Modular System Demo ==="
echo

# Example 1: Status reporting with improved alignment
echo "1. Status Reporting (Improved Alignment):"
echo "========================================="

# Use the new convenience function for consistent alignment
echo "$(create_status_line "success" "APT packages updated successfully" "45")"
echo "$(create_status_line "warning" "Some packages were held back" "3")"
echo "$(create_status_line "error" "Failed to update repository")"
echo

# Example 2: Progress indicators
echo "2. Progress Indicators:"
echo "======================"

echo "$(create_status_line "running" "Updating system packages...")"
echo "$(create_status_line "pending" "Waiting for lock...")"
echo

# Example 3: Information display with better spacing
echo "3. Information Display (Better Spacing):"
echo "======================================="

# Stats with timing - using components for better control
stats_components=(
    "$(make_color_component "info")"
    "$(make_emoji_component "stats")"
    "$(make_spacing_component "1")"
    "$(make_text_component "Updated 45 packages")"
    "$(make_spacing_component "3")"
    "$(make_emoji_component "timing")"
    "$(make_spacing_component "1")"
    "$(make_text_component "in 2m 30s")"
    "$(make_color_component "reset")"
)
stats_line=$(compose_line 0 "${stats_components[@]}")
echo "$stats_line"

echo "$(create_status_line "info" "Consider running cleanup to free space")"
echo

# Example 4: Formatted tables with proper alignment
echo "4. Formatted Tables (Proper Alignment):"
echo "======================================"

# Use the new table functions for better alignment
echo "$(create_header_row 50 "Package Manager" "Status" "Packages")"
echo "$(create_table_row 50 "APT" "✅ Updated" "45")"
echo "$(create_table_row 50 "Snap" "⚠️ Held" "3")"
echo

# Example 5: Box drawing with colors
echo "5. Box Drawing (With Colors):"
echo "============================"

# Simple colored box
echo "Success Box:"
draw_box "APT: 45 packages updated | Snap: 3 held | Flatpak: 12 updated" "Summary" "success"
echo

# Error box
echo "Error Box:"
draw_box "Failed to update repository. Check network connection." "Error" "error"
echo

# Warning box
echo "Warning Box:"
draw_box "Some packages were held back due to conflicts." "Warning" "warning"
echo

# Info box
echo "Info Box:"
draw_box "System update completed successfully." "Info" "info"
echo

# Example 6: Status boxes
echo "6. Status Boxes:"
echo "================"

echo "Success Status Box:"
draw_status_box "success" "All packages updated successfully" "System Update"
echo

echo "Warning Status Box:"
draw_status_box "warning" "Some packages were held back" "Update Status"
echo

# Example 7: Complex layout with proper spacing
echo "7. Complex Layout (Proper Spacing):"
echo "==================================="

echo "System Status Summary:"
echo "====================="

# Create a complex status display with proper spacing
complex_components=(
    "$(make_color_component "success")"
    "$(make_emoji_component "success")"
    "$(make_spacing_component "1")"
    "$(make_text_component "System is up to date")"
    "$(make_color_component "reset")"
    "$(make_spacing_component "5")"
    "$(make_color_component "info")"
    "$(make_emoji_component "timing")"
    "$(make_spacing_component "1")"
    "$(make_text_component "Last update: 2 hours ago")"
    "$(make_color_component "reset")"
)

complex_line=$(compose_line 60 "${complex_components[@]}")
echo "$complex_line"

# Example 8: Alignment comparison
echo
echo "8. Alignment Comparison:"
echo "======================="

echo "Old way (inconsistent spacing):"
echo "✅ APT packages updated successfully"
echo "⚠️ Some packages were held back"
echo "❌ Failed to update repository"
echo

echo "New way (consistent spacing):"
echo "$(create_status_line "success" "APT packages updated successfully")"
echo "$(create_status_line "warning" "Some packages were held back")"
echo "$(create_status_line "error" "Failed to update repository")"
echo

# Example 9: Table with status indicators
echo "9. Table with Status Indicators:"
echo "================================"

# Create a table with colored status indicators
echo "$(create_header_row "Service" "Status" "Details" 50)"

# Row 1 with success status
row1_components=(
    "$(make_text_component "APT")"
    "$(make_spacing_component "10")"
    "$(make_color_component "success")"
    "$(make_emoji_component "success")"
    "$(make_spacing_component "1")"
    "$(make_text_component "Updated")"
    "$(make_color_component "reset")"
    "$(make_spacing_component "10")"
    "$(make_text_component "45 packages")"
)
row1_line=$(compose_line 50 "${row1_components[@]}")
echo "$row1_line"

# Row 2 with warning status
row2_components=(
    "$(make_text_component "Snap")"
    "$(make_spacing_component "10")"
    "$(make_color_component "warning")"
    "$(make_emoji_component "warning")"
    "$(make_spacing_component "1")"
    "$(make_text_component "Held")"
    "$(make_color_component "reset")"
    "$(make_spacing_component "10")"
    "$(make_text_component "3 packages")"
)
row2_line=$(compose_line 50 "${row2_components[@]}")
echo "$row2_line"

echo
echo "=== Demo Complete ==="