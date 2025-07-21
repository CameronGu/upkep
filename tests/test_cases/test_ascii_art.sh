#!/bin/bash
# test_ascii_art.sh - Test ASCII title rendering

source "$(dirname "$0")/../../scripts/modules/ascii_art.sh"

# Capture output
output=$(ascii_title 2>&1)
if [[ -n "$output" ]]; then
    echo "ASCII Art printed successfully."
    exit 0
else
    echo "ASCII Art did not print."
    exit 1
fi
