#!/bin/bash
# test_formatting.sh - Test box formatting

# Load required modules with correct paths
source "$(dirname "$0")/../../scripts/modules/core/utils.sh"

# Test box drawing
draw_box "GREEN" "TEST" "This is a test message"
if [[ $? -eq 0 ]]; then
    echo "Box formatting test passed."
    exit 0
else
    echo "Box formatting test failed."
    exit 1
fi
