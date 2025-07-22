#!/bin/bash
# test_interval_logic.sh - Test interval calculation

# Load required modules with correct paths
source "$(dirname "$0")/../../scripts/modules/core/utils.sh"
source "$(dirname "$0")/../../scripts/modules/core/state.sh"

# Override STATE_FILE for testing
STATE_FILE="/tmp/test_upkep_state"
echo -e "UPDATE_LAST_RUN=$(( $(date +%s) - 3*86400 ))\nCLEANUP_LAST_RUN=0\nSCRIPT_LAST_RUN=0" > "$STATE_FILE"

# Run show_current_status and check expected days
output=$(show_current_status 2>&1)
echo "$output" | grep -q "3 day(s) ago"
if [[ $? -eq 0 ]]; then
    echo "Interval logic test passed."
    exit 0
else
    echo "Interval logic test failed."
    echo "$output"
    exit 1
fi
