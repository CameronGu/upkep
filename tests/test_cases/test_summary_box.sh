#!/bin/bash
# test_summary_box.sh - Test summary box functionality

# Load required modules with correct paths
source "$(dirname "$0")/../../scripts/modules/core/utils.sh"

# Set up test status variables
APT_STATUS="success"
SNAP_STATUS="failed"
FLATPAK_STATUS="skipped"
CLEANUP_STATUS="success"

# Test summary output
echo "Testing summary box display:"

# Call the summary box function
output=$(draw_summary 2>&1)

if echo "$output" | grep -q "Summary" || echo "$output" | grep -q "APT"; then
    echo "Summary box test passed."
    exit 0
else
    echo "Summary box test failed."
    echo "Output was: $output"
    exit 1
fi
