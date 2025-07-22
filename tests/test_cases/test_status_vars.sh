#!/bin/bash
# test_status_vars.sh - Test status variable handling

# Load required modules with correct paths
source "$(dirname "$0")/../../scripts/modules/core/utils.sh"

# Set up test status variables
APT_STATUS="success"
SNAP_STATUS="failed"
FLATPAK_STATUS="skipped"
CLEANUP_STATUS="success"

# Test draw_summary function
output=$(draw_summary 2>&1)
if echo "$output" | grep -q "APT"; then
    echo "Status variables test passed."
    exit 0
else
    echo "FAIL: draw_summary APT status missing"
    exit 1
fi
