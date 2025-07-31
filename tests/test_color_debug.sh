#!/bin/bash

# Test Color Debug
# This test helps debug the color issue

SCRIPT_DIR="$(cd "$(dirname "$0")/../scripts/core" && pwd)"
source "${SCRIPT_DIR}/palette.sh"

echo "=== Color Debug Test ==="
echo

echo "1. Testing get_color function:"
echo "   get_color success: $(get_color success)"
echo "   get_color error: $(get_color error)"
echo "   get_color warning: $(get_color warning)"
echo

echo "2. Testing direct ANSI escape sequences:"
echo -e "\033[32mThis should be green\033[0m"
echo -e "\033[31mThis should be red\033[0m"
echo -e "\033[33mThis should be yellow\033[0m"
echo

echo "3. Testing get_color with ANSI:"
echo -e "\033[$(get_color success)mThis should be green\033[0m"
echo -e "\033[$(get_color error)mThis should be red\033[0m"
echo -e "\033[$(get_color warning)mThis should be yellow\033[0m"
echo

echo "4. Testing render_html_cell directly:"
source "${SCRIPT_DIR}/box_builder.sh"
echo "   Input: <color=success>test</color>"
echo "   Output: "
render_html_cell "<color=success>test</color>" 20 ""
echo
echo "   Input: <color=error>test</color>"
echo "   Output: "
render_html_cell "<color=error>test</color>" 20 ""
echo

echo "5. Testing complete box with HTML:"
box_data=$(box_new 50 "Test" "info")
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_html '<color=success>test</color>')")
box_data=$(box_add_row "$box_data" "$row_data")
box_render "$box_data"
echo

echo "=== Debug Complete ===" 