#!/bin/bash
# Simple test to compare emoji rendering

source "scripts/modules/core/utils.sh"

echo "=== Simple Emoji Test ==="
echo

echo "1. Direct emoji comparison:"
echo "Success: '$(get_emoji success)'"
echo "Warning: '$(get_emoji warning)'"
echo

echo "2. With spacing from map:"
echo "Success: '$(render_component "emoji:success")'"
echo "Warning: '$(render_component "emoji:warning")'"
echo

echo "3. Manual construction:"
success_manual="$(get_emoji success) "
warning_manual="$(get_emoji warning) "
echo "Success manual: '$success_manual'"
echo "Warning manual: '$warning_manual'"
echo

echo "4. Character count:"
echo "Success manual length: ${#success_manual}"
echo "Warning manual length: ${#warning_manual}"
echo

echo "5. Hex dump:"
echo "Success: $(echo -n "$success_manual" | xxd -p)"
echo "Warning: $(echo -n "$warning_manual" | xxd -p)" 