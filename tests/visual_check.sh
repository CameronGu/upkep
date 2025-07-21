#!/bin/bash
# visual_check.sh - Manual visual verification of upKep Linux Maintainer UI elements

BASE_DIR="$(dirname "$0")/../scripts/modules"
source "$BASE_DIR/utils.sh"
source "$BASE_DIR/ascii_art.sh"

echo "=== Visual Check ==="
ascii_title

draw_box "$BLUE" "DEMO TITLE" "This is a test line 1" "This is a test line 2"
echo
draw_box "$GREEN" "ANOTHER BOX" "Lorem ipsum dolor sit amet"

APT_STATUS="success"
SNAP_STATUS="failed"
FLATPAK_STATUS="success"
CLEANUP_STATUS="success"

draw_summary() {
    box_top "$MAGENTA" "SUMMARY"
    box_text_line "$MAGENTA" "APT       : $APT_STATUS"
    box_text_line "$MAGENTA" "Snap      : $SNAP_STATUS"
    box_text_line "$MAGENTA" "Flatpak   : $FLATPAK_STATUS"
    box_text_line "$MAGENTA" "Cleanup   : $CLEANUP_STATUS"
    box_bottom "$MAGENTA"
}
echo
draw_summary

echo "=== End of Visual Check ==="
