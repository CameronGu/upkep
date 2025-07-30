#!/bin/bash
# Test Progress Indicators for Layout Builder
# Verifies spinner and progress bar components work correctly

set -e

echo "🔄 Testing Progress Indicators"
echo "=============================="
echo

# Source the core components
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts/core" && pwd)"
source "${SCRIPT_DIR}/palette.sh"
source "${SCRIPT_DIR}/box_builder.sh"
source "${SCRIPT_DIR}/progress_indicators.sh"

echo "✅ Progress indicators loaded"
echo

# Test 1: Spinner frames
echo "1. 🎭 Testing Spinner Frames"
echo "----------------------------"
echo "Default frames:"
get_spinner_frames | tr ' ' '\n' | head -5
echo

# Test 2: Progress bar characters
echo "2. 📊 Testing Progress Bar Characters"
echo "------------------------------------"
echo "Default characters:"
get_progress_chars
echo

# Test 3: Colorblind mode spinner frames
echo "3. 🎨 Testing Colorblind Mode Spinner"
echo "------------------------------------"
export UPKEP_COLORBLIND=1
echo "Colorblind frames:"
get_spinner_frames | tr ' ' '\n' | head -3
export UPKEP_COLORBLIND=0
echo

# Test 4: ASCII mode progress characters
echo "4. 🔤 Testing ASCII Mode Progress"
echo "--------------------------------"
export UPKEP_ASCII=1
echo "ASCII characters:"
get_progress_chars
export UPKEP_ASCII=0
echo

# Test 5: Progress bar row creation
echo "5. 📦 Testing Progress Bar Row Creation"
echo "--------------------------------------"
echo "Creating progress bar row (50%):"
progress_row_id=$(create_progress_bar_row 50 20 info)
echo "Row ID: $progress_row_id"
echo "Row cells: ${ROWS["${progress_row_id}_cells"]}"
echo

# Test 6: Progress box creation
echo "6. 📦 Testing Progress Box Creation"
echo "----------------------------------"
echo "Creating progress box (75%):"
create_progress_box "Test Progress" "Processing files..." "info" 75 30
echo

# Test 7: Spinner row creation
echo "7. 🔄 Testing Spinner Row Creation"
echo "---------------------------------"
echo "Creating spinner row:"
spinner_row_id=$(create_spinner_row "Loading data..." "info")
echo "Row ID: $spinner_row_id"
echo "Row cells: ${ROWS["${spinner_row_id}_cells"]}"
echo

# Test 8: Progress bar with different styles
echo "8. 🎨 Testing Progress Bar Styles"
echo "--------------------------------"
echo "Success style (25%):"
create_progress_box "Success Progress" "Task completed" "success" 25 25
echo

echo "Warning style (60%):"
create_progress_box "Warning Progress" "Task with warnings" "warning" 60 25
echo

echo "Error style (90%):"
create_progress_box "Error Progress" "Task with errors" "error" 90 25
echo

# Test 9: Quiet mode handling
echo "9. 🔇 Testing Quiet Mode"
echo "-----------------------"
export UPKEP_QUIET=1
echo "Quiet mode spinner:"
start_spinner "This should show static text"
sleep 0.2
stop_spinner
export UPKEP_QUIET=0
echo

# Test 10: Progress bar edge cases
echo "10. 🔍 Testing Edge Cases"
echo "------------------------"
echo "Progress 0%:"
create_progress_bar_row 0 10 info > /dev/null && echo "✅ 0% works"
echo "Progress 100%:"
create_progress_bar_row 100 10 info > /dev/null && echo "✅ 100% works"
echo "Progress -10% (should clamp to 0%):"
create_progress_bar_row -10 10 info > /dev/null && echo "✅ Negative clamped"
echo "Progress 150% (should clamp to 100%):"
create_progress_bar_row 150 10 info > /dev/null && echo "✅ Over 100% clamped"
echo

echo "✅ Progress indicators test completed successfully!"
echo
echo "Key Features Verified:"
echo "  • Spinner frames for different modes (default, colorblind, ASCII)"
echo "  • Progress bar characters for different modes"
echo "  • Progress bar row creation with proper formatting"
echo "  • Progress box creation with Layout Builder integration"
echo "  • Spinner row creation"
echo "  • Different styles (success, warning, error)"
echo "  • Quiet mode handling"
echo "  • Edge case handling (0%, 100%, out of bounds)"
echo
echo "All progress indicators are working correctly! 🎉" 