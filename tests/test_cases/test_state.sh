#!/bin/bash
# test_state.sh - Test state file logic

# Use a temporary state file for testing
STATE_FILE="/tmp/test_upkep_state"
export STATE_FILE

# Load required modules with correct paths
source "$(dirname "$0")/../../scripts/modules/core/utils.sh"
source "$(dirname "$0")/../../scripts/modules/core/state.sh"

# Clean up any existing test state file
rm -f "$STATE_FILE"

# Ensure state loads or initializes
load_state
if [[ ! -f "$STATE_FILE" ]]; then
    echo "State file not created!"
    exit 1
fi

# Save state and verify
UPDATE_LAST_RUN=1234
CLEANUP_LAST_RUN=5678
save_state
grep -q "UPDATE_LAST_RUN=1234" "$STATE_FILE" && grep -q "CLEANUP_LAST_RUN=5678" "$STATE_FILE"
if [[ $? -eq 0 ]]; then
    echo "State file test passed."
    # Clean up test state file
    rm -f "$STATE_FILE"
    exit 0
else
    echo "State file test failed."
    # Clean up test state file
    rm -f "$STATE_FILE"
    exit 1
fi
