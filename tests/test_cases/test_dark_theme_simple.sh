#!/bin/bash

# Simple test script for dark theme implementation
echo "Testing Dark Theme Implementation..."

# Source the utils file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
UTILS_FILE="$PROJECT_ROOT/scripts/modules/core/utils.sh"

if [[ ! -f "$UTILS_FILE" ]]; then
    echo "Error: utils.sh not found at $UTILS_FILE"
    exit 1
fi

echo "Sourcing utils.sh..."
source "$UTILS_FILE"
echo "✅ Utils sourced successfully"

echo "Testing colorblind mode detection..."
if is_colorblind_mode; then
    echo "❌ Colorblind mode should be OFF by default"
else
    echo "✅ Colorblind mode detection works (OFF)"
fi

echo "Testing color support detection..."
color_support=$(detect_color_support)
echo "✅ Color support: $color_support"

echo "Testing semantic colors..."
echo "PRIMARY_BG: $PRIMARY_BG"
echo "SUCCESS_GREEN: $SUCCESS_GREEN"
echo "ACCENT_CYAN: $ACCENT_CYAN"

echo "Testing get_color function..."
success_color=$(get_color "success")
echo "✅ Success color: $success_color"

echo "Testing colorblind mode..."
export UPKEP_COLORBLIND=1
if is_colorblind_mode; then
    echo "✅ Colorblind mode detection works (ON)"
else
    echo "❌ Colorblind mode should be ON"
fi

echo "Testing colorblind color..."
colorblind_success=$(get_color "success")
echo "✅ Colorblind success color: $colorblind_success"

unset UPKEP_COLORBLIND

echo "Testing component creation..."
emoji_comp=$(make_emoji_component "success")
color_comp=$(make_color_component "accent_cyan")
text_comp=$(make_text_component "Test")

echo "✅ Emoji component: $emoji_comp"
echo "✅ Color component: $color_comp"
echo "✅ Text component: $text_comp"

echo "Testing output functions..."
header_output=$(create_section_header "Test Header" 50)
if [[ -n "$header_output" ]]; then
    echo "✅ Section header creation works"
else
    echo "❌ Section header creation failed"
fi

echo "All tests completed!"