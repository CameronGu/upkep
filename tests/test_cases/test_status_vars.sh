#!/usr/bin/env bash
# Test: Verify status variable defaults and draw_summary output

source "$(dirname "$0")/../../scripts/modules/utils.sh" # includes draw_summary

# Initialize variables as in main.sh
APT_STATUS="skipped"
SNAP_STATUS="skipped"
FLATPAK_STATUS="skipped"
CLEANUP_STATUS="skipped"
SKIP_NOTE="Test skip message"

output=$(draw_summary 2>&1)

# Checks
if [[ "$output" == *"APT"* ]] && [[ "$output" == *"skipped"* ]]; then
    echo "PASS: draw_summary shows APT status"
else
    echo "FAIL: draw_summary APT status missing"
    exit 1
fi

if [[ "$output" == *"Test skip message"* ]]; then
    echo "PASS: SKIP_NOTE is displayed"
else
    echo "FAIL: SKIP_NOTE not displayed"
    exit 1
fi
