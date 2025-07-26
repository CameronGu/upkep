#!/bin/bash
# test_status_vars.sh - Test status variable handling

# Load required modules with correct paths
source "$(dirname "$0")/../../scripts/modules/core/utils.sh"
source "$(dirname "$0")/../../scripts/modules/core/state.sh"

# Set up test status variables
APT_STATUS="success"
SNAP_STATUS="failed"
FLATPAK_STATUS="skipped"
CLEANUP_STATUS="success"

# Test show_current_status function
output=$(show_current_status 2>&1)
if echo "$output" | grep -q "Last update"; then
    echo "Status variables test passed."
    exit 0
else
    echo "FAIL: show_current_status missing update information"
    exit 1
fi
