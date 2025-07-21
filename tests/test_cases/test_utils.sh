#!/bin/bash
# test_utils.sh - Test utility functions

source "$(dirname "$0")/../../scripts/modules/utils.sh"

# Test repeat_char
repeated=$(repeat_char "*" 5)
if [[ "$repeated" == "*****" ]]; then
    echo "repeat_char passed."
else
    echo "repeat_char failed: $repeated"
    exit 1
fi

# Test spinner (quick mock)
(sleep 0.5) & spinner $! "Test Spinner"
echo "Spinner test completed."

exit 0
