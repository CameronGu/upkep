#!/bin/bash
# test_simple_config_system.sh - Test the simplified configuration system

# Set up test environment
TEST_HOME=$(mktemp -d)
export HOME="$TEST_HOME"
export UPKEP_CONFIG="$TEST_HOME/.upkep/config.yaml"

# Source the simplified config system
source "$(dirname "$0")/../../scripts/core/config_simple.sh"

# Test counter
TESTS_PASSED=0
TESTS_TOTAL=0

# Test helper function
run_test() {
    local test_name="$1"
    local test_command="$2"

    ((TESTS_TOTAL++))
    echo "Running test: $test_name"

    # Clear any environment variables that might interfere
    unset UPKEP_DRY_RUN UPKEP_FORCE UPKEP_LOG_LEVEL UPKEP_UPDATE_INTERVAL UPKEP_CLEANUP_INTERVAL

    if eval "$test_command"; then
        echo "✓ PASS: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $test_name"
        return 1
    fi
}

# Test initialization creates default config
test_initialization() {
    # Remove config file if it exists
    rm -f "$UPKEP_CONFIG"

    # Initialize should create default config
    init_simple_config

    # Check file exists and has expected content
    [[ -f "$UPKEP_CONFIG" ]] &&
    grep -q "update_interval: 7" "$UPKEP_CONFIG" &&
    grep -q "cleanup_interval: 30" "$UPKEP_CONFIG" &&
    grep -q "log_level: info" "$UPKEP_CONFIG"
}

# Test basic configuration reading
test_config_reading() {
    # Set up test config
    init_simple_config

    local update_interval cleanup_interval log_level
    update_interval=$(get_config "update_interval" "default")
    cleanup_interval=$(get_config "cleanup_interval" "default")
    log_level=$(get_config "log_level" "default")

    [[ "$update_interval" == "7" ]] &&
    [[ "$cleanup_interval" == "30" ]] &&
    [[ "$log_level" == "info" ]]
}

# Test configuration writing
test_config_writing() {
    init_simple_config

    # Set new values
    set_config "update_interval" "14"
    set_config "log_level" "debug"

    # Read them back
    local update_interval log_level
    update_interval=$(get_config "update_interval" "default")
    log_level=$(get_config "log_level" "default")

    [[ "$update_interval" == "14" ]] &&
    [[ "$log_level" == "debug" ]]
}

# Test environment variable overrides
test_env_overrides() {
    init_simple_config

    # Set environment variables
    export UPKEP_UPDATE_INTERVAL="3"
    export UPKEP_LOG_LEVEL="error"

    # Should get env values, not config values
    local update_interval log_level
    update_interval=$(get_config "update_interval" "default")
    log_level=$(get_config "log_level" "default")

    unset UPKEP_UPDATE_INTERVAL UPKEP_LOG_LEVEL

    [[ "$update_interval" == "3" ]] &&
    [[ "$log_level" == "error" ]]
}

# Test convenience functions
test_convenience_functions() {
    # Remove config file first to test clean initialization
    rm -f "$UPKEP_CONFIG"
    init_simple_config

    local update_interval cleanup_interval log_level
    update_interval=$(get_update_interval)
    cleanup_interval=$(get_cleanup_interval)
    log_level=$(get_log_level)

    # Debug output for troubleshooting
    if [[ "$update_interval" != "7" || "$cleanup_interval" != "30" || "$log_level" != "info" ]]; then
        echo "Debug: update_interval='$update_interval', cleanup_interval='$cleanup_interval', log_level='$log_level'"
        return 1
    fi

    return 0
}

# Test boolean functions
test_boolean_functions() {
    init_simple_config

    # Test notifications setting
    if get_notifications_enabled; then
        echo "✓ Notifications enabled"
    else
        echo "✗ Notifications disabled"
        return 1
    fi
}

# Test default value fallback
test_default_fallback() {
    init_simple_config

    # Test non-existent key
    local nonexistent
    nonexistent=$(get_config "nonexistent_key" "fallback_value")

    [[ "$nonexistent" == "fallback_value" ]]
}

# Test configuration reset
test_config_reset() {
    init_simple_config

    # Modify config
    set_config "update_interval" "99"

    # Reset should restore defaults
    reset_config

    local update_interval
    update_interval=$(get_config "update_interval" "default")

    [[ "$update_interval" == "7" ]]
}

# Test config validation
test_config_validation() {
    init_simple_config

    # Valid config should pass validation
    if validate_config_basic; then
        # Corrupt config should fail validation
        echo "invalid content" > "$UPKEP_CONFIG"
        if ! validate_config_basic; then
            # Restore and test again
            reset_config
            validate_config_basic
        else
            return 1
        fi
    else
        return 1
    fi
}

# Test quote handling
test_quote_handling() {
    init_simple_config

    # Add quoted values to config
    echo 'quoted_value: "test with spaces"' >> "$UPKEP_CONFIG"
    echo "single_quoted: 'another test'" >> "$UPKEP_CONFIG"

    local quoted_value single_quoted
    quoted_value=$(get_config "quoted_value" "default")
    single_quoted=$(get_config "single_quoted" "default")

    [[ "$quoted_value" == "test with spaces" ]] &&
    [[ "$single_quoted" == "another test" ]]
}

# Test file permissions
test_file_permissions() {
    init_simple_config

    # Check that config file has secure permissions (600)
    local perms
    perms=$(stat -c "%a" "$UPKEP_CONFIG" 2>/dev/null)

    [[ "$perms" == "600" ]]
}

# Cleanup function
cleanup() {
    rm -rf "$TEST_HOME"
    unset HOME UPKEP_CONFIG
    unset UPKEP_DRY_RUN UPKEP_FORCE UPKEP_LOG_LEVEL UPKEP_UPDATE_INTERVAL UPKEP_CLEANUP_INTERVAL
}

# Main test execution
main() {
    echo "Starting Simplified Configuration System Tests"
    echo "=============================================="
    echo ""

    # Run all tests
    run_test "Configuration Initialization" "test_initialization"
    run_test "Basic Configuration Reading" "test_config_reading"
    run_test "Configuration Writing" "test_config_writing"
    run_test "Environment Variable Overrides" "test_env_overrides"
    run_test "Convenience Functions" "test_convenience_functions"
    run_test "Boolean Functions" "test_boolean_functions"
    run_test "Default Value Fallback" "test_default_fallback"
    run_test "Configuration Reset" "test_config_reset"
    run_test "Configuration Validation" "test_config_validation"
    run_test "Quote Handling" "test_quote_handling"
    run_test "File Permissions" "test_file_permissions"

    # Print results
    echo ""
    echo "=============================================="
    echo "Test Results: $TESTS_PASSED/$TESTS_TOTAL passed"

    if [[ $TESTS_PASSED -eq $TESTS_TOTAL ]]; then
        echo "✓ All simplified configuration tests passed!"
        cleanup
        exit 0
    else
        echo "✗ Some simplified configuration tests failed"
        cleanup
        exit 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi