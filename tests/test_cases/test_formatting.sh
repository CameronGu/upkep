#!/bin/bash
# test_formatting.sh - Test box drawing functions

source "$(dirname "$0")/../../scripts/modules/utils.sh"

# Capture output of a test box
output=$(draw_box "$BLUE" "TEST BOX" "Line 1" "Line 2")
if echo "$output" | grep -q "TEST BOX"; then
    echo "Box formatting test passed."
    exit 0
else
    echo "Box formatting test failed."
    echo "$output"
    exit 1
fi
