#!/bin/bash

# Comprehensive DSL Test for Layout Builder
# This demonstrates all the new simplified DSL functions

# Get the script directory more reliably
SCRIPT_DIR="$(cd "$(dirname "$0")/../scripts/core" && pwd)"
source "${SCRIPT_DIR}/layout_dsl.sh"

echo "=== upKep Comprehensive DSL Test ==="
echo "This test demonstrates all the new simplified DSL functions"
echo

echo "Available DSL Functions:"
echo "• create_quick_box(title, content, style, width)"
echo "• create_colored_box(title, content, color, style, width)"
echo "• create_quick_table(title, width, headers...)"
echo "• create_status_box(title, emoji, message, color, style, width)"
echo "• create_progress_box(title, emoji, message, progress, width)"
echo "• create_dashboard_box(title, width, info_items...)"
echo "• create_comparison_table(title, width, label1, value1, label2, value2...)"
echo "• create_warning_box(title, message, width)"
echo "• create_error_box(title, message, width)"
echo "• create_success_box(title, message, width)"
echo "• create_info_box(title, message, width)"
echo

# Test 1: Basic boxes
echo "1. Basic Boxes:"
create_quick_box "System Status" "All systems operational" "success" 45
echo

create_colored_box "Update Status" "12 packages updated" "success" "success" 45
echo

# Test 2: Tables
echo "2. Tables:"
create_quick_table "Package Status" 70 "Package" "Status" "Version" "Last Updated"
echo

create_comparison_table "System Information" 60 "OS" "Ubuntu 22.04" "Kernel" "5.15.0" "Uptime" "3 days"
echo

# Test 3: Status boxes
echo "3. Status Boxes:"
create_status_box "APT Update" "✅" "45 packages updated successfully" "success" "success" 55
echo

create_status_box "Snap Update" "⚠️" "3 packages held back" "warning" "warning" 55
echo

create_status_box "Network" "❌" "Connection failed" "error" "error" 55
echo

# Test 4: Progress boxes
echo "4. Progress Boxes:"
create_progress_box "Installation Progress" "🔄" "Processing" "45% complete" 60
echo

create_progress_box "Download Progress" "📦" "Downloading" "2.3GB / 5.1GB" 60
echo

# Test 5: Dashboard
echo "5. Dashboard:"
create_dashboard_box "System Dashboard" 70 "🖥️ System: Ubuntu 22.04 LTS" "💾 Disk: 89.4GB free" "📊 Total modules: 7" "⏰ Last run: 2 hours ago"
echo

# Test 6: Specialized boxes
echo "6. Specialized Boxes:"
create_warning_box "System Warning" "3 packages held back due to dependencies" 60
echo

create_error_box "Installation Failed" "Network timeout during download" 60
echo

create_success_box "Update Complete" "All packages updated successfully" 60
echo

create_info_box "System Info" "Check logs for detailed information" 60
echo

# Test 7: Complex layouts
echo "7. Complex Layouts:"
echo "Creating a comprehensive status report..."

# Create multiple boxes to simulate a status report
create_success_box "APT Update" "12 packages updated successfully" 55
echo

create_warning_box "Snap Update" "3 packages held back" 55
echo

create_error_box "Flatpak Update" "Network connection failed" 55
echo

create_info_box "Next Run" "Scheduled for 5 days from now" 55
echo

echo "=== Comprehensive DSL Test Complete ==="
echo
echo "Summary of DSL Benefits:"
echo "✅ Simple, intuitive function names"
echo "✅ Consistent parameter ordering"
echo "✅ Automatic color and style handling"
echo "✅ Built-in emoji support"
echo "✅ Flexible width and styling options"
echo "✅ Easy to use in scripts and modules"
echo
echo "Usage Examples:"
echo "• create_success_box \"Update Complete\" \"All packages updated\""
echo "• create_warning_box \"System Warning\" \"3 packages held back\""
echo "• create_error_box \"Installation Failed\" \"Network timeout\""
echo "• create_dashboard_box \"System Status\" 70 \"Info 1\" \"Info 2\" \"Info 3\""
echo 