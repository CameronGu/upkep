#!/bin/bash
# test_summary_box.sh - Test summary box output

source "$(dirname "$0")/../../scripts/modules/utils.sh"

# Mock summary variables
APT_STATUS="success"
SNAP_STATUS="success"
FLATPAK_STATUS="failed"
CLEANUP_STATUS="success"

draw_summary() {
    box_top "$MAGENTA" "SUMMARY"
    box_text_line "$MAGENTA" "APT       : $APT_STATUS"
    box_text_line "$MAGENTA" "Snap      : $SNAP_STATUS"
    box_text_line "$MAGENTA" "Flatpak   : $FLATPAK_STATUS"
    box_text_line "$MAGENTA" "Cleanup   : $CLEANUP_STATUS"
    box_bottom "$MAGENTA"
}

# Capture output
output=$(draw_summary)
echo "$output" | grep -q "Flatpak   : failed"
if [[ $? -eq 0 ]]; then
    echo "Summary box test passed."
    exit 0
else
    echo "Summary box test failed."
    echo "$output"
    exit 1
fi
