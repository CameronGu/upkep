#!/bin/bash
# test_flags.sh - Test CLI flags for main.sh

SCRIPT_PATH="$(dirname "$0")/../../scripts/main.sh"

# Run with --status flag and check for 'CURRENT STATUS'
output=$(bash "$SCRIPT_PATH" --status 2>&1)
echo "$output" | grep -q "CURRENT STATUS"
if [[ $? -eq 0 ]]; then
    echo "--status flag test passed."
    exit 0
else
    echo "--status flag test failed."
    echo "$output"
    exit 1
fi
