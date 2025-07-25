#!/bin/bash
# test_all_emojis.sh - Test all emojis used in the project for Unicode width issues

source "$(dirname "$0")/../scripts/modules/core/utils.sh"

echo "=== Comprehensive Emoji Width Test ==="
echo

# All emojis used in the project (from DESIGN.md and visual_check.sh)
emojis=(
    # Status icons
    "✅" "❌" "⚠️" "⏳" "🔄" "⏭️" "📋" "🎯"
    
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
    box_text_line "warning" "$test_string"
    echo
done

echo "=== Testing All Status Icons in Boxes ==="
echo

# Test all status icons in a consistent format
status_tests=(
    "✅ Task completed successfully"
    "❌ Task failed to complete"
    "⚠️  Task needs attention"
    "⏳ Task is waiting"
    "🔄 Task is running"
    "⏭️  Task was skipped"
    "📋 Task is new"
    "🎯 Task is due"
)

echo "Testing all status icons in consistent format:"
for test_string in "${status_tests[@]}"; do
    echo "Testing: '$test_string'"
    box_text_line "info" "$test_string"
done

echo
echo "=== Summary of Problematic Emojis ==="
echo

# Identify and list problematic emojis
echo "Problematic emojis (display width > char count + 1):"
problematic_found=false

for emoji in "${emojis[@]}"; do
    char_count=${#emoji}
    display_width=$(get_display_width "$emoji")
    difference=$((display_width - char_count))
    
    if [[ $difference -gt 1 ]]; then
        echo "  $emoji: $char_count chars, $display_width display width (diff: $difference)"
        problematic_found=true
    fi
done

if [[ "$problematic_found" == "false" ]]; then
    echo "  None found! All emojis have normal width characteristics."
fi

echo
echo "=== Recommendations ==="
echo

if [[ "$problematic_found" == "true" ]]; then
    echo "For problematic emojis, consider these alternatives:"
    echo "  ⏱️  → ⏰ (simpler clock emoji)"
    echo "  ⏭️  → ⏸️ (pause emoji)"
    echo "  🎯 → 🎪 (target emoji)"
    echo "  📋 → 📝 (clipboard emoji)"
fi

echo "=== Test Complete ===" 