#!/bin/bash
# test_unicode_width.sh - Test Unicode width calculation

# Source the enhanced utils
source "$(dirname "$0")/../scripts/modules/core/utils.sh"

echo "=== Unicode Width Calculation Test ==="
echo

# Test basic width calculation
echo "1. Basic Width Tests:"
echo "Regular text 'Hello': $(get_display_width "Hello")"
echo "With emoji '✅ Hello': $(get_display_width "✅ Hello")"
echo "With multiple emojis '✅ ⏱️ 📊': $(get_display_width "✅ ⏱️ 📊")"
echo "Mixed content '✅ Task completed ⏱️ 45s': $(get_display_width "✅ Task completed ⏱️ 45s")"
echo

# Test specific problematic strings
echo "2. Problematic String Tests:"
test_strings=(
    "✅ Task completed successfully"
    "⏰  Execution time: 45 seconds"
    "📊 12 items processed"
    "⚠️  Some items need attention"
    "❌ Task failed to complete"
    "🔍 Check the logs for details"
    "💡 Consider running --fix"
)

for str in "${test_strings[@]}"; do
    echo "String: '$str'"
    echo "  Character count: ${#str}"
    echo "  Display width: $(get_display_width "$str")"
    echo "  Difference: $(( $(get_display_width "$str") - ${#str} ))"
    echo
done

# Test box drawing with emojis
echo "3. Box Drawing with Emojis:"
echo

draw_box "success" "TEST WITH EMOJIS" \
    "✅ Task completed successfully" \
    "⏰  Execution time: 45 seconds" \
    "📊 12 items processed"
echo

# Test table with emojis
echo "4. Table with Emojis:"
echo

box_top "accent_cyan" "STATUS TABLE"
box_line "accent_cyan" "Module" "Status" "Last Run"
box_line "accent_cyan" "─────" "──────" "────────"
box_line "accent_cyan" "APT" "✅ Done" "2 days ago"
box_line "accent_cyan" "Snap" "⚠️ Due" "Now"
box_line "accent_cyan" "Flatpak" "❌ Failed" "1 week ago"
box_line "accent_cyan" "Cleanup" "📋 New" "Never"
box_bottom "accent_cyan"
echo

# Test edge cases
echo "5. Edge Cases:"
echo "Empty string: $(get_display_width "")"
echo "Single emoji: $(get_display_width "✅")"
echo "Multiple emojis: $(get_display_width "✅⏱️📊")"
echo "Emoji with text: $(get_display_width "✅Done")"
echo "Text with emoji: $(get_display_width "Done✅")"
echo

echo "=== Unicode Width Test Complete ==="