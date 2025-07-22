#!/bin/bash
# test_utils.sh - Test utility functions

# Load required modules with correct paths (enhanced utils)
source "$(dirname "$0")/../../scripts/core/utils.sh"

# Test print_color function
result=$(print_color "$RED" "Test message" 2>&1)
if [[ -n "$result" ]]; then
    echo "print_color test passed."
else
    echo "print_color failed: $result"
    exit 1
fi

# Test print_success function
result=$(print_success "Test success" 2>&1)
if echo "$result" | grep -q "✓"; then
    echo "print_success test passed."
else
    echo "print_success failed: $result"
    exit 1
fi

echo "All utility tests passed."
exit 0
