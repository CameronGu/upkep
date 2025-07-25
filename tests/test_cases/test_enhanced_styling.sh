#!/bin/bash
# test_enhanced_styling.sh - Test enhanced styling system

# Load required modules with correct paths
source "$(dirname "$0")/../../scripts/modules/core/utils.sh"

echo "Testing enhanced styling system..."

# Test color detection
support=$(detect_color_support)
if [[ -n "$support" ]]; then
    echo "✅ Color support detection: $support"
else
    echo "❌ Color support detection failed"
    exit 1
fi

# Test color retrieval
success_color=$(get_color "success")
if [[ -n "$success_color" ]]; then
    echo "✅ Success color retrieval: OK"
else
    echo "❌ Success color retrieval failed"
    exit 1
fi

# Test terminal width detection
width=$(get_terminal_width)
if [[ -n "$width" && "$width" -gt 0 ]]; then
    echo "✅ Terminal width detection: $width"
else
    echo "❌ Terminal width detection failed"
    exit 1
fi

# Test box width calculation
box_width=$(get_box_width)
if [[ -n "$box_width" && "$box_width" -ge 60 && "$box_width" -le 120 ]]; then
    echo "✅ Box width calculation: $box_width"
else
    echo "❌ Box width calculation failed: $box_width"
    exit 1
fi

# Test box drawing functions
box_output=$(box_top "accent_cyan" "TEST TITLE")
if [[ -n "$box_output" ]]; then
    echo "✅ Box top drawing: OK"
else
    echo "❌ Box top drawing failed"
    exit 1
fi

# Test text line drawing
text_output=$(box_text_line "accent_magenta" "Test content")
if [[ -n "$text_output" ]]; then
    echo "✅ Box text line drawing: OK"
else
    echo "❌ Box text line drawing failed"
    exit 1
fi

# Test legacy compatibility
legacy_output=$(draw_box "success" "Legacy Test" "Line 1" "Line 2")
if [[ -n "$legacy_output" ]]; then
    echo "✅ Legacy draw_box compatibility: OK"
else
    echo "❌ Legacy draw_box compatibility failed"
    exit 1
fi

# Test Unicode support
spin="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
if [[ "${#spin}" -eq 10 ]]; then
    echo "✅ Unicode spinner characters: OK"
else
    echo "❌ Unicode spinner characters failed"
    exit 1
fi

echo "🎉 All enhanced styling tests passed!"
exit 0 