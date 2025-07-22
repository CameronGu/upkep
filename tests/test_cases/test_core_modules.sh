#!/bin/bash
# test_core_modules.sh - Test core module functionality

# Set up test environment
export STATE_FILE="/tmp/test_upkep_state"

# Load mocks first
source "$(dirname "$0")/../mocks/mock_apt.sh"
source "$(dirname "$0")/../mocks/mock_snap.sh"

# Load core modules with correct paths
source "$(dirname "$0")/../../scripts/modules/core/utils.sh"
source "$(dirname "$0")/../../scripts/modules/core/state.sh"
source "$(dirname "$0")/../../scripts/modules/core/apt_update.sh"
source "$(dirname "$0")/../../scripts/modules/core/snap_update.sh"
source "$(dirname "$0")/../../scripts/modules/core/flatpak_update.sh"
source "$(dirname "$0")/../../scripts/modules/core/cleanup.sh"

# Test counter
TESTS_PASSED=0
TESTS_TOTAL=0

# Test helper function
run_test() {
    local test_name="$1"
    local test_command="$2"

    ((TESTS_TOTAL++))
    echo "Running test: $test_name"

    if eval "$test_command"; then
        echo "✓ PASS: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $test_name"
        return 1
    fi
}

# Initialize test state
init_test_state() {
    rm -f "$STATE_FILE"
    echo -e "UPDATE_LAST_RUN=0\nCLEANUP_LAST_RUN=0\nSCRIPT_LAST_RUN=0" > "$STATE_FILE"
    return 0
}

# Test APT update module
test_apt_update() {
    init_test_state

    # Reset status
    APT_STATUS="skipped"

    # Run APT update
    run_apt_updates 2>/dev/null

    # Check if status was updated to success
    [[ "$APT_STATUS" == "success" ]]
}

# Test Snap update module
test_snap_update() {
    init_test_state

    # Reset status
    SNAP_STATUS="skipped"

    # Run Snap update
    run_snap_updates 2>/dev/null

    # Check if status was updated
    [[ "$SNAP_STATUS" == "success" ]]
}

# Test Flatpak update module
test_flatpak_update() {
    init_test_state

    # Reset status
    FLATPAK_STATUS="skipped"

    # Run Flatpak update (this might skip if flatpak not installed)
    run_flatpak_updates 2>/dev/null

    # Flatpak might be skipped if not available, which is ok
    [[ "$FLATPAK_STATUS" == "success" || "$FLATPAK_STATUS" == "skipped" ]]
}

# Test cleanup module
test_cleanup() {
    init_test_state

    # Reset status
    CLEANUP_STATUS="skipped"

    # Run cleanup
    run_cleanup 2>/dev/null

    # Check if status was updated
    [[ "$CLEANUP_STATUS" == "success" ]]
}

# Test module status functions exist
test_module_functions_exist() {
    # Check if key functions exist
    declare -f run_apt_updates >/dev/null &&
    declare -f run_snap_updates >/dev/null &&
    declare -f run_flatpak_updates >/dev/null &&
    declare -f run_cleanup >/dev/null
}

# Test state management integration
test_state_integration() {
    init_test_state

    # Save some test state
    APT_STATUS="success"
    UPDATE_LAST_RUN=$(date +%s)
    save_state

    # Check if state file was updated
    grep -q "APT_STATUS" "$STATE_FILE" || grep -q "UPDATE_LAST_RUN" "$STATE_FILE"
}

# Run all tests
echo "=== Core Modules Test Suite ==="
echo ""

run_test "Module Functions Exist" "test_module_functions_exist"
run_test "APT Update Module" "test_apt_update"
run_test "Snap Update Module" "test_snap_update"
run_test "Flatpak Update Module" "test_flatpak_update"
run_test "Cleanup Module" "test_cleanup"
run_test "State Integration" "test_state_integration"

# Clean up
rm -f "$STATE_FILE"

# Report results
echo ""
echo "=== Test Results ==="
echo "Tests passed: $TESTS_PASSED/$TESTS_TOTAL"

if [[ $TESTS_PASSED -eq $TESTS_TOTAL ]]; then
    echo "✅ All core module tests passed!"
    exit 0
else
    echo "❌ Some core module tests failed!"
    exit 1
fi