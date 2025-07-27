#!/bin/bash
# execution_summary_demo.sh - Visual demonstration of enhanced execution summary boxes

BASE_DIR="$(dirname "$0")/../scripts/modules"
source "$BASE_DIR/core/utils.sh"
source "$BASE_DIR/core/ascii_art.sh"

echo "=== upKep Enhanced Execution Summary Boxes Demo ==="
echo

# =============================================================================
# 1. SUCCESS EXECUTION SUMMARY BOXES
# =============================================================================
echo "1. Success Execution Summary Boxes:"
echo "==================================="

echo "Full Success Box (APT Update):"
draw_success_summary_box \
    "APT Update" \
    "✅ 12 packages updated successfully" \
    "📦 42 packages upgraded, 0 newly installed, 0 to remove" \
    "12"

echo

echo "Simple Success Box (Snap Update):"
draw_success_summary_box \
    "Snap Update" \
    "✅ All snap packages are up to date" \
    "" \
    "0"

echo

# =============================================================================
# 2. ERROR EXECUTION SUMMARY BOXES
# =============================================================================
echo "2. Error Execution Summary Boxes:"
echo "================================="

echo "Full Error Box (APT Update Failed):"
draw_error_summary_box \
    "APT Update" \
    "❌ Failed to update package repository" \
    "🔍 Network connection timeout after 30 seconds" \
    "1"

echo

echo "Simple Error Box (Permission Denied):"
draw_error_summary_box \
    "System Cleanup" \
    "❌ Permission denied: cannot access /var/log" \
    "" \
    ""

echo

# =============================================================================
# 3. WARNING EXECUTION SUMMARY BOXES
# =============================================================================
echo "3. Warning Execution Summary Boxes:"
echo "==================================="

echo "Full Warning Box (Packages Held Back):"
draw_warning_summary_box \
    "APT Update" \
    "❗ Some packages were held back" \
    "📊 3 packages held back due to dependency conflicts" \
    "3"

echo

echo "Simple Warning Box (Disk Space):"
draw_warning_summary_box \
    "System Check" \
    "❗ Low disk space detected" \
    "📊 Available space: 2.1 GB" \
    ""

echo

# =============================================================================
# 4. INFO EXECUTION SUMMARY BOXES
# =============================================================================
echo "4. Info Execution Summary Boxes:"
echo "================================"

echo "Full Info Box (System Status):"
draw_info_summary_box \
    "System Status" \
    "ℹ️ System is running normally" \
    "⏰ Uptime: 5 days, 12 hours, 34 minutes" \
    ""

echo

echo "Simple Info Box (Log Rotation):"
draw_info_summary_box \
    "Log Rotation" \
    "ℹ️ Rotated 15 log files" \
    "" \
    "15"

echo

# =============================================================================
# 5. MULTI-LINE CONTENT DEMONSTRATION
# =============================================================================
echo "5. Multi-Line Content Demonstration:"
echo "===================================="

echo "Complex Success Box with Multiple Details:"
draw_success_summary_box \
    "System Maintenance" \
    "✅ All maintenance tasks completed successfully" \
    "📦 APT: 12 packages updated
📦 Snap: 3 packages refreshed
📦 Flatpak: 1 package updated
📊 Cleanup: 2.3 GB freed" \
    "16"

echo

# =============================================================================
# 6. DIFFERENT WIDTHS DEMONSTRATION
# =============================================================================
echo "6. Different Widths Demonstration:"
echo "=================================="

echo "Narrow Box (40 characters):"
UPKEP_BOX_WIDTH=40 draw_success_summary_box \
    "Test" \
    "✅ Short message" \
    "" \
    ""

echo

echo "Wide Box (80 characters):"
UPKEP_BOX_WIDTH=80 draw_success_summary_box \
    "Test" \
    "✅ This is a much longer message to demonstrate wide box formatting" \
    "" \
    ""

echo

# =============================================================================
# 7. ALL STATUS TYPES COMPARISON
# =============================================================================
echo "7. All Status Types Comparison:"
echo "==============================="

echo "Success:"
draw_success_summary_box "Test" "✅ Operation completed" "" ""

echo "Error:"
draw_error_summary_box "Test" "❌ Operation failed" "" ""

echo "Warning:"
draw_warning_summary_box "Test" "❗ Operation completed with warnings" "" ""

echo "Info:"
draw_info_summary_box "Test" "ℹ️ Operation information" "" ""

echo

echo "=== Demo Complete ==="
echo "The enhanced execution summary boxes now properly use the modular component"
echo "system with correct emoji width calculation and perfect alignment."