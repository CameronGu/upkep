#!/bin/bash
# Debug script to analyze emoji spacing issues

source "scripts/modules/core/utils.sh"

echo "=== Emoji Spacing Debug ==="
echo

echo "1. Raw emoji map values:"
echo "Success: '${EMOJI_MAP[success]}'"
echo "Warning: '${EMOJI_MAP[warning]}'"
echo

echo "2. Individual component rendering:"
echo "Success emoji: '$(render_component "emoji:success")'"
echo "Warning emoji: '$(render_component "emoji:warning")'"
echo

echo "3. Character-by-character analysis:"
success_output=$(render_component "emoji:success")
warning_output=$(render_component "emoji:warning")

echo "Success emoji (${#success_output} chars):"
for ((i=0; i<${#success_output}; i++)); do
    char="${success_output:$i:1}"
    printf "  Pos %d: '%s' (hex: %02X)\n" $i "$char" "'$char"
done

echo "Warning emoji (${#warning_output} chars):"
for ((i=0; i<${#warning_output}; i++)); do
    char="${warning_output:$i:1}"
    printf "  Pos %d: '%s' (hex: %02X)\n" $i "$char" "'$char"
done

echo

echo "4. Full table row test:"
full_output=$(create_status_table_row 50 "Snap" "warning" "Held" "3")
echo "Output (${#full_output} chars): '$full_output'"

echo "Character-by-character:"
for ((i=0; i<${#full_output}; i++)); do
    char="${full_output:$i:1}"
    if [[ "$char" == " " ]]; then
        printf "  Pos %d: SPACE\n" $i
    else
        printf "  Pos %d: '%s' (hex: %02X)\n" $i "$char" "'$char"
    fi
done

echo

echo "5. Terminal info:"
echo "TERM: $TERM"
echo "LANG: $LANG"
echo "LC_ALL: $LC_ALL" 