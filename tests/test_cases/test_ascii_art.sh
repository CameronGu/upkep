#!/bin/bash
# test_ascii_art.sh - Test ASCII art display

# Load required modules with correct paths
source "$(dirname "$0")/../../scripts/modules/core/ascii_art.sh"

# Test ASCII title function
ascii_title > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "ASCII Art printed successfully."
    exit 0
else
    echo "ASCII Art test failed."
    exit 1
fi
