#!/bin/bash
# test_simple_env_overrides.sh - Test simple environment variable overrides

# Set up test environment
TEST_CONFIG_DIR="/tmp/test_upkep_simple_config"
TEST_CONFIG_FILE="$TEST_CONFIG_DIR/config.yaml"

# Create test config directory
mkdir -p "$TEST_CONFIG_DIR"

# Override config paths for testing
export HOME="/tmp"
export GLOBAL_CONFIG="$TEST_CONFIG_FILE"

# Load configuration modules with correct paths
source "$(dirname "$0")/../../scripts/core/config/global.sh"

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

# Initialize test config
init_test_config() {
    cat > "$TEST_CONFIG_FILE" << 'EOF'
version: 2.0.0

defaults:
  update_interval: 7
  cleanup_interval: 30

logging:
  level: info
  file: /tmp/.upkep/upkep.log

dry_run: false
parallel_execution: true

modules:
  apt_update:
    enabled: true
    interval_days: 7
EOF
    return 0
}

# Test basic config reading
test_basic_config() {
    init_test_config
    
    local value
    value=$(get_config "logging.level" "warn")
    [[ "$value" == "info" ]]
}

# Test environment variable override
test_env_var_override() {
    init_test_config
    
    # Test environment variable override
    UPKEP_LOGGING_LEVEL=debug
    local value
    value=$(get_config "logging.level" "warn")
    unset UPKEP_LOGGING_LEVEL
    [[ "$value" == "debug" ]]
}

# Test different key formats
test_key_formats() {
    init_test_config
    
    # Test dot notation conversion
    UPKEP_DEFAULTS_UPDATE_INTERVAL=14
    local value
    value=$(get_config "defaults.update_interval" "1")
    unset UPKEP_DEFAULTS_UPDATE_INTERVAL
    [[ "$value" == "14" ]] || return 1
    
    # Test simple keys
    UPKEP_DRY_RUN=true
    value=$(get_config "dry_run" "false")
    unset UPKEP_DRY_RUN
    [[ "$value" == "true" ]]
}

# Test fallback to config file
test_fallback_to_config() {
    init_test_config
    
    # No env var set, should use config file value
    local value
    value=$(get_config "parallel_execution" "false")
    [[ "$value" == "true" ]]
}

# Test fallback to default
test_fallback_to_default() {
    init_test_config
    
    # Non-existent key, should use default
    local value
    value=$(get_config "nonexistent.key" "default_value")
    [[ "$value" == "default_value" ]]
}

# Cleanup function
cleanup() {
    rm -rf "$TEST_CONFIG_DIR"
    unset UPKEP_LOGGING_LEVEL
    unset UPKEP_DEFAULTS_UPDATE_INTERVAL
    unset UPKEP_DRY_RUN
}

# Main test execution
main() {
    echo "Starting Simple Environment Variable Override Tests"
    echo "=================================================="
    echo ""

    # Clean up before tests
    cleanup

    # Run tests
    run_test "Basic Config Reading" "test_basic_config"
    run_test "Environment Variable Override" "test_env_var_override"
    run_test "Key Formats" "test_key_formats"
    run_test "Fallback to Config" "test_fallback_to_config"
    run_test "Fallback to Default" "test_fallback_to_default"

    # Clean up after tests
    cleanup

    # Print results
    echo ""
    echo "=================================================="
    echo "Test Results: $TESTS_PASSED/$TESTS_TOTAL passed"
    
    if [[ $TESTS_PASSED -eq $TESTS_TOTAL ]]; then
        echo "✓ All tests passed!"
        exit 0
    else
        echo "✗ Some tests failed"
        exit 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 