#!/bin/bash
# Visual Layout Builder Demo
# Demonstrates all core components with visual examples

set -e

echo "🎨 upKep Layout Builder - Visual Demo"
echo "====================================="
echo

# Source the core components
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts/core" && pwd)"
source "${SCRIPT_DIR}/palette.sh"
source "${SCRIPT_DIR}/box_builder.sh"
source "${SCRIPT_DIR}/layout_loader.sh"

# Demo 1: Basic Palette System
echo "1. 🎨 Palette System Demo"
echo "-------------------------"
echo "Default mode:"
echo "  Success: $(format_status success "Operation completed successfully")"
echo "  Error: $(format_status error "Something went wrong")"
echo "  Warning: $(format_status warning "Please check configuration")"
echo "  Info: $(format_status info "System information")"
echo "  Running: $(format_status running "Processing...")"
echo

# Demo 2: Colorblind Mode
echo "2. 🎨 Colorblind Mode Demo"
echo "--------------------------"
export UPKEP_COLORBLIND=1
choose_palette
echo "Colorblind mode:"
echo "  Success: $(format_status success "Operation completed successfully")"
echo "  Error: $(format_status error "Something went wrong")"
echo "  Warning: $(format_status warning "Please check configuration")"
echo "  Info: $(format_status info "System information")"
echo "  Running: $(format_status running "Processing...")"
echo

# Reset to default mode
export UPKEP_COLORBLIND=0
choose_palette

# Demo 3: Width Calculation
echo "3. 📏 Width Calculation Demo"
echo "----------------------------"
echo "ASCII text width: $(python3 "${SCRIPT_DIR}/width_helpers.py" width "hello")"
echo "Emoji width: $(python3 "${SCRIPT_DIR}/width_helpers.py" width "✅")"
echo "Mixed content width: $(python3 "${SCRIPT_DIR}/width_helpers.py" width "hello ✅ world")"
echo

# Demo 4: Text Truncation
echo "4. ✂️ Text Truncation Demo"
echo "--------------------------"
echo "Original: 'This is a very long text that needs truncation'"
echo "Ellipsis (20 chars): '$(python3 "${SCRIPT_DIR}/width_helpers.py" truncate "This is a very long text that needs truncation" 20 ellipsis)'"
echo "Wrap (15 chars):"
python3 "${SCRIPT_DIR}/width_helpers.py" fit "This is a very long text that needs wrapping" 15 wrap | sed 's/^/  /'
echo

# Demo 5: Basic Box Creation
echo "5. 📦 Basic Box Demo"
echo "-------------------"
create_simple_box "Basic Information Box" info 60
echo

# Demo 6: Box with Content
echo "6. 📦 Box with Content Demo"
echo "--------------------------"
box_id=$(box_new 60 "System Status" info)
row1=$(row_new)
row_add_cell "$row1" "$(make_emoji success)"
row_add_cell "$row1" "$(make_text "System is running normally")"
box_add_row "$box_id" "$row1"

row2=$(row_new)
row_add_cell "$row2" "$(make_emoji warning)"
row_add_cell "$row2" "$(make_text "3 packages need updates")"
box_add_row "$box_id" "$row2"

row3=$(row_new)
row_add_cell "$row3" "$(make_emoji info)"
row_add_cell "$row3" "$(make_text "Last update: 2 hours ago")"
box_add_row "$box_id" "$row3"

box_render "$box_id"
echo

# Demo 7: Different Border Styles
echo "7. 🎭 Border Styles Demo"
echo "-----------------------"
create_simple_box "Major Style Box" major 50
create_simple_box "Minor Style Box" minor 50
create_simple_box "Emphasis Style Box" emphasis 50
echo

# Demo 8: JSON-Driven Layout
echo "8. 📄 JSON-Driven Layout Demo"
echo "----------------------------"
cat <<'JSON' | render_layout_from_stdin
{
  "title": "Package Update Summary",
  "style": "info",
  "rows": [
    {
      "cells": [
        {"emoji": "success"},
        {"text": "APT packages updated successfully"},
        {"text": "45 packages"}
      ]
    },
    {
      "cells": [
        {"emoji": "warning"},
        {"text": "Snap packages held back"},
        {"text": "3 packages"}
      ]
    },
    {
      "cells": [
        {"emoji": "info"},
        {"text": "Flatpak packages checked"},
        {"text": "12 packages"}
      ]
    }
  ]
}
JSON
echo

# Demo 9: ASCII Fallback Mode
echo "9. 🔤 ASCII Fallback Demo"
echo "------------------------"
export UPKEP_ASCII=1
create_simple_box "ASCII Mode Box" info 50
export UPKEP_ASCII=0
echo

# Demo 10: Responsive Layout
echo "10. 📱 Responsive Layout Demo"
echo "----------------------------"
echo "Narrow terminal (40 cols):"
create_simple_box "Responsive Test" info 40
echo
echo "Wide terminal (80 cols):"
create_simple_box "Responsive Test" info 80
echo

# Demo 11: Complex Table
echo "11. 📊 Complex Table Demo"
echo "------------------------"
box_id=$(box_new 80 "Module Status Overview" info)

# Header row
header_row=$(row_new)
row_add_cell "$header_row" "$(make_text "Module")"
row_add_cell "$header_row" "$(make_text "Status")"
row_add_cell "$header_row" "$(make_text "Last Run")"
row_add_cell "$header_row" "$(make_text "Next Due")"
box_add_row "$box_id" "$header_row"

# Data rows
row1=$(row_new)
row_add_cell "$row1" "$(make_text "apt_update")"
row_add_cell "$row1" "$(make_emoji success)"
row_add_cell "$row1" "$(make_text "2 hours ago")"
row_add_cell "$row1" "$(make_text "Tomorrow")"
box_add_row "$box_id" "$row1"

row2=$(row_new)
row_add_cell "$row2" "$(make_text "snap_update")"
row_add_cell "$row2" "$(make_emoji warning)"
row_add_cell "$row2" "$(make_text "1 day ago")"
row_add_cell "$row2" "$(make_text "Today")"
box_add_row "$box_id" "$row2"

row3=$(row_new)
row_add_cell "$row3" "$(make_text "flatpak_update")"
row_add_cell "$row3" "$(make_emoji info)"
row_add_cell "$row3" "$(make_text "3 days ago")"
row_add_cell "$row3" "$(make_text "Next week")"
box_add_row "$box_id" "$row3"

box_render "$box_id"
echo

# Demo 12: Color Transitions
echo "12. 🌈 Color Transitions Demo"
echo "----------------------------"
box_id=$(box_new 70 "Color Transition Test" info)
row1=$(row_new)
row_add_cell "$row1" "$(make_color success)"
row_add_cell "$row1" "$(make_text "Green text")"
row_add_cell "$row1" "$(make_color reset)"
row_add_cell "$row1" "$(make_color error)"
row_add_cell "$row1" "$(make_text "Red text")"
row_add_cell "$row1" "$(make_color reset)"
box_add_row "$box_id" "$row1"
box_render "$box_id"
echo

echo "✅ Visual demo completed successfully!"
echo
echo "Key Features Demonstrated:"
echo "  • Palette system with colorblind support"
echo "  • Unicode width calculation and text fitting"
echo "  • Box creation with different border styles"
echo "  • JSON-driven layout rendering"
echo "  • ASCII fallback mode"
echo "  • Responsive layout adaptation"
echo "  • Complex table rendering"
echo "  • Color transitions and formatting"
echo
echo "All components are working correctly! 🎉" 