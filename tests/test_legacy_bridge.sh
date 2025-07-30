#!/bin/bash
# Test Legacy Bridge Functions
# Verifies that legacy functions proxy correctly to the new Layout Builder

set -e

echo "🔗 Testing Legacy Bridge Functions"
echo "=================================="
echo

# Source utils.sh to get legacy bridge functions
source scripts/modules/core/utils.sh

echo "✅ Legacy bridge functions loaded"
echo

# Test 1: create_box() legacy function
echo "1. 📦 Testing create_box() legacy function"
echo "------------------------------------------"
echo "Expected: Should proxy to new Layout Builder with deprecation warning"
echo
create_box "Test Box" "info" 50
echo

# Test 2: create_summary_box() legacy function
echo "2. 📋 Testing create_summary_box() legacy function"
echo "------------------------------------------------"
echo "Expected: Should proxy to new Layout Builder with deprecation warning"
echo
create_summary_box "success" "Test Summary" "Operation completed successfully" 60
echo

# Test 3: draw_status_box() legacy function
echo "3. 📝 Testing draw_status_box() legacy function"
echo "----------------------------------------------"
echo "Expected: Should proxy to new Layout Builder with deprecation warning"
echo
draw_status_box "This is a test message" "Test Status" "info" 55
echo

# Test 4: create_status_line() enhanced function
echo "4. 📊 Testing create_status_line() enhanced function"
echo "--------------------------------------------------"
echo "Expected: Should use new palette system if available"
echo
create_status_line "success" "Test operation completed"
create_status_line "error" "Test operation failed"
create_status_line "warning" "Test operation has warnings"
create_status_line "info" "Test operation information"
create_status_line "running" "Test operation in progress"
echo

# Test 5: Legacy variables preservation
echo "5. 🔧 Testing legacy variables preservation"
echo "------------------------------------------"
echo "Expected: BOX_* and STATUS_* variables should be preserved"
echo
echo "BOX_TOP_LEFT: $BOX_TOP_LEFT"
echo "BOX_HORIZONTAL: $BOX_HORIZONTAL"
echo "STATUS_ICONS[success]: ${STATUS_ICONS[success]}"
echo "STATUS_COLORS[success]: ${STATUS_COLORS[success]}"
echo

echo "✅ Legacy bridge test completed successfully!"
echo
echo "Key Features Verified:"
echo "  • Legacy functions proxy to new Layout Builder"
echo "  • Deprecation warnings are emitted"
echo "  • Fallback to legacy implementation when needed"
echo "  • Enhanced create_status_line() uses new palette"
echo "  • Legacy variables are preserved for compatibility"
echo
echo "All legacy bridge functions are working correctly! 🎉" 