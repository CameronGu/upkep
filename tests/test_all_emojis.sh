#!/bin/bash
# test_all_emojis.sh - Test all emojis used in the project for Unicode width issues

source "$(dirname "$0")/../scripts/modules/core/utils.sh"

echo "=== Comprehensive Emoji Width Test ==="
echo

# All emojis used in the project (from DESIGN.md and visual_check.sh)
emojis=(
    # Status icons
    "✅" "❌" "❗" "⏳" "🔄" "⏭️" "📋" "🎯"

    # Timing and info
    "⏰" "⏱️" "📊" "💡" "🔧" "📦" "🗑️" "🔍"

    # System and actions
    "🖥️" "💾" "⚡" "📅" "🕐" "🕒" "📁" "🧹"

    # Package management
    "📦" "🔄" "📋" "🎯" "💡" "🔧" "📊" "🗑️"

    # Additional ones from visual_check.sh
    "⏸️" "📋" "🎯" "🔧" "📦" "🗑️" "🔍" "⏭️"
    "📅" "🕐" "🕒" "📁" "🧹" "📦" "🔄" "📋"
)

echo "Testing individual emoji widths:"
echo "Emoji | Char Count | Display Width | Difference | Status"
echo "------|------------|---------------|------------|--------"

for emoji in "${emojis[@]}"; do
    char_count=${#emoji}
    display_width=$(get_display_width "$emoji")
    difference=$((display_width - char_count))

    # Determine if this emoji is problematic
    if [[ $difference -gt 1 ]]; then
        status="❌ PROBLEMATIC"
    elif [[ $difference -eq 1 ]]; then
        status="⚠️  WIDE"
    else
        status="✅ NORMAL"
    fi

    printf "%-4s | %-10s | %-13s | %-10s | %s\n" \
        "$emoji" "$char_count" "$display_width" "$difference" "$status"
done

echo
echo "=== Testing Emojis in Context ==="
echo

# Test problematic emojis in actual usage contexts
problematic_tests=(
    "⏭️  Skipped - Last update was 2 days ago"
    "🎯 Action Required - Check configuration"
    "📋 New module needs setup"
    "⏸️  Operation paused"
)

echo "Testing potentially problematic emojis in context:"
for test_string in "${problematic_tests[@]}"; do
    echo "String: '$test_string'"
    echo "  Character count: ${#test_string}"
    echo "  Display width: $(get_display_width "$test_string")"
    echo "  Difference: $(( $(get_display_width "$test_string") - ${#test_string} ))"

    # Test in a box to see visual alignment
    echo "  Box output:"
    draw_box "$test_string" "TEST" "warning"
    echo
done

echo "=== Testing All Status Icons in Boxes ==="
echo

# Test all status icons in a consistent format
status_tests=(
    "✅ Task completed successfully"
    "❌ Task failed to complete"
    "❗ Task needs attention"
    "⏳ Task is waiting"
    "🔄 Task is running"
    "⏭️  Task was skipped"
    "📋 Task is new"
    "🎯 Task is due"
)

echo "Testing all status icons in consistent format:"
for test_string in "${status_tests[@]}"; do
    echo "Testing: '$test_string'"
    draw_box "$test_string" "STATUS TEST" "info"
done

echo
echo "=== Testing Component System with Emojis ==="
echo

# Test emojis using the component system
echo "Testing emojis with component system:"
emoji_keys=("success" "error" "warning" "pending" "running" "skip" "new" "action")
for key in "${emoji_keys[@]}"; do
    emoji_comp=$(make_emoji_component "$key")
    text_comp=$(make_text_component "Test with $key emoji")
    line=$(compose_line 0 "$emoji_comp" "$text_comp")
    echo "  $line"
done

echo
echo "=== Summary of Problematic Emojis ==="
echo

# Identify and list problematic emojis
problematic_emojis=()
for emoji in "${emojis[@]}"; do
    char_count=${#emoji}
    display_width=$(get_display_width "$emoji")
    difference=$((display_width - char_count))

    if [[ $difference -gt 1 ]]; then
        problematic_emojis+=("$emoji")
    fi
done

if [[ ${#problematic_emojis[@]} -gt 0 ]]; then
    echo "Problematic emojis (display width > char count + 1):"
    for emoji in "${problematic_emojis[@]}"; do
        char_count=${#emoji}
        display_width=$(get_display_width "$emoji")
        difference=$((display_width - char_count))
        echo "  $emoji: $char_count chars, $display_width display width (diff: $difference)"
    done
else
    echo "No problematic emojis found!"
fi

echo
echo "=== Recommendations ==="
echo

if [[ ${#problematic_emojis[@]} -gt 0 ]]; then
    echo "For problematic emojis, consider these alternatives:"
    echo "  ⏱️  → ⏰ (simpler clock emoji)"
    echo "  ⏭️  → ⏸️ (pause emoji)"
    echo "  🎯 → 🎪 (target emoji)"
    echo "  📋 → 📝 (clipboard emoji)"
else
    echo "All emojis are working well with the current system!"
fi

echo "=== Test Complete ==="