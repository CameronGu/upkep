#!/bin/bash
# test_state.sh - Test state file logic

STATE_FILE="/tmp/test_upkep_state"
export STATE_FILE

# Load required modules
source "$(dirname "$0")/../../scripts/modules/utils.sh"
source "$(dirname "$0")/../../scripts/modules/state.sh"

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
    exit 0
else
    echo "State file test failed."
    exit 1
fi
