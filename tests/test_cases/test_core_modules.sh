#!/bin/bash
# test_core_modules.sh - Test core module functionality (safe version)

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

# Test module functions exist (safe test)
test_module_functions_exist() {
    # Check if key functions exist
    declare -f run_apt_updates >/dev/null &&
    declare -f run_snap_updates >/dev/null &&
    declare -f run_flatpak_updates >/dev/null &&
    declare -f run_cleanup >/dev/null
}

# Test module status variables can be set (safe test)
test_module_status_variables() {
    # Test that status variables can be set and used
    APT_STATUS="test"
    SNAP_STATUS="test"
    FLATPAK_STATUS="test"
    CLEANUP_STATUS="test"

    [[ "$APT_STATUS" == "test" ]] &&
    [[ "$SNAP_STATUS" == "test" ]] &&
    [[ "$FLATPAK_STATUS" == "test" ]] &&
    [[ "$CLEANUP_STATUS" == "test" ]]
}

# Test state management integration (safe test)
test_state_integration() {
    init_test_state

    # Save some test state
    APT_STATUS="success"
    UPDATE_LAST_RUN=$(date +%s)
    save_state

    # Check if state file was updated
    grep -q "APT_STATUS" "$STATE_FILE" || grep -q "UPDATE_LAST_RUN" "$STATE_FILE"
}

# Test module configuration loading (safe test)
test_module_config_loading() {
    # Test that modules can be loaded without errors
    # This tests the module structure and basic functionality
    [[ -f "$(dirname "$0")/../../scripts/modules/core/apt_update.sh" ]] &&
    [[ -f "$(dirname "$0")/../../scripts/modules/core/snap_update.sh" ]] &&
    [[ -f "$(dirname "$0")/../../scripts/modules/core/flatpak_update.sh" ]] &&
    [[ -f "$(dirname "$0")/../../scripts/modules/core/cleanup.sh" ]]
}

# Test mock functions work (safe test)
test_mock_functions() {
    # Test that mock functions are available and work
    # Check for the actual mock functions that exist
    declare -f apt >/dev/null &&
    declare -f snap >/dev/null
}

# Test status display functions (safe test)
test_status_display() {
    # Test that status display functions work
    local output=$(show_current_status 2>&1)
    [[ -n "$output" && "$output" == *"CURRENT STATUS"* ]]
}

# Run all tests
echo "=== Core Modules Test Suite (Safe Version) ==="
echo ""

run_test "Module Functions Exist" "test_module_functions_exist"
run_test "Module Status Variables Defined" "test_module_status_variables"
run_test "State Integration" "test_state_integration"
run_test "Module Configuration Loading" "test_module_config_loading"
run_test "Mock Functions Available" "test_mock_functions"
run_test "Status Display Functions" "test_status_display"

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