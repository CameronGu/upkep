#!/bin/bash
# test_enhanced_yaml_parsing.sh - Test enhanced YAML parsing functionality

# Set up test environment
TEST_CONFIG_DIR="/tmp/test_upkep_enhanced_yaml"
TEST_GLOBAL_CONFIG="$TEST_CONFIG_DIR/config.yaml"
TEST_MODULE_CONFIG_DIR="$TEST_CONFIG_DIR/modules"
TEST_MODULE_CONFIG="$TEST_MODULE_CONFIG_DIR/test_module.yaml"

# Create test directories
mkdir -p "$TEST_CONFIG_DIR" "$TEST_MODULE_CONFIG_DIR"

# Override config paths for testing
export HOME="/tmp"
export GLOBAL_CONFIG="$TEST_GLOBAL_CONFIG"
export MODULE_CONFIG_DIR="$TEST_MODULE_CONFIG_DIR"

# Load configuration modules
source "$(dirname "$0")/../../scripts/core/config/global.sh"
source "$(dirname "$0")/../../scripts/core/config/module.sh"

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

# Initialize complex test config
init_complex_test_config() {
    cat > "$TEST_GLOBAL_CONFIG" << 'EOF'
version: 2.0.0

# Simple keys
debug: false
timeout: 30

# Two-level nesting
defaults:
  update_interval: 7
  cleanup_interval: 30
  security_interval: 1

logging:
  level: info
  file: /var/log/upkep.log
  max_size: 10MB
  rotate: true

notifications:
  enabled: true
  email: false

# Three-level nesting
modules:
  apt_update:
    enabled: true
    interval_days: 7
    priority: high
    options:
      auto_remove: true
  snap_update:
    enabled: false
    interval_days: 14
    description: "Snap package updates"
  cleanup:
    enabled: true
    interval_days: 30

# Edge cases
special_chars: "quotes and 'apostrophes'"
numbers_as_strings: "123"
pure_numbers: 456
boolean_true: true
boolean_false: false
empty_value: ""
EOF
    return 0
}

# Initialize test module config
init_test_module_config() {
    cat > "$TEST_MODULE_CONFIG" << 'EOF'
enabled: true
interval_days: 7
description: "Test module for YAML parsing"
priority: medium

# Nested configuration
options:
  verbose: true
  timeout: 60
  retries: 3

# Advanced settings
advanced:
  parallel: false
  batch_size: 100
  settings:
    debug_mode: false
    log_level: info
EOF
    return 0
}

# Test simple key parsing (global config)
test_simple_key_parsing() {
    init_complex_test_config

    # Test various simple keys
    local debug_val timeout_val
    debug_val=$(get_global_config "debug" "unknown")
    timeout_val=$(get_global_config "timeout" "unknown")

    [[ "$debug_val" == "false" ]] && [[ "$timeout_val" == "30" ]]
}

# Test two-level nested key parsing
test_two_level_nested_parsing() {
    init_complex_test_config

    local update_interval log_level notifications
    update_interval=$(get_global_config "defaults.update_interval" "unknown")
    log_level=$(get_global_config "logging.level" "unknown")
    notifications=$(get_global_config "notifications.enabled" "unknown")

    [[ "$update_interval" == "7" ]] &&
    [[ "$log_level" == "info" ]] &&
    [[ "$notifications" == "true" ]]
}

# Test three-level nested key parsing
test_three_level_nested_parsing() {
    init_complex_test_config

    local apt_enabled apt_interval snap_enabled auto_remove
    apt_enabled=$(get_global_config "modules.apt_update.enabled" "unknown")
    apt_interval=$(get_global_config "modules.apt_update.interval_days" "unknown")
    snap_enabled=$(get_global_config "modules.snap_update.enabled" "unknown")
    auto_remove=$(get_global_config "modules.apt_update.options.auto_remove" "unknown")

    [[ "$apt_enabled" == "true" ]] &&
    [[ "$apt_interval" == "7" ]] &&
    [[ "$snap_enabled" == "false" ]] &&
    [[ "$auto_remove" == "true" ]]
}

# Test edge cases and special values
test_edge_cases() {
    init_complex_test_config

    local special_chars numbers_str pure_nums bool_true bool_false empty_val
    special_chars=$(get_global_config "special_chars" "unknown")
    numbers_str=$(get_global_config "numbers_as_strings" "unknown")
    pure_nums=$(get_global_config "pure_numbers" "unknown")
    bool_true=$(get_global_config "boolean_true" "unknown")
    bool_false=$(get_global_config "boolean_false" "unknown")
    empty_val=$(get_global_config "empty_value" "default")

    [[ "$special_chars" == "quotes and 'apostrophes'" ]] &&
    [[ "$numbers_str" == "123" ]] &&
    [[ "$pure_nums" == "456" ]] &&
    [[ "$bool_true" == "true" ]] &&
    [[ "$bool_false" == "false" ]] &&
    [[ "$empty_val" == "" ]]
}

# Test default value fallback
test_default_fallback() {
    init_complex_test_config

    local nonexistent nested_nonexistent deep_nonexistent
    nonexistent=$(get_global_config "nonexistent_key" "default_value")
    nested_nonexistent=$(get_global_config "nonexistent.nested" "nested_default")
    deep_nonexistent=$(get_global_config "modules.nonexistent.key" "deep_default")

    [[ "$nonexistent" == "default_value" ]] &&
    [[ "$nested_nonexistent" == "nested_default" ]] &&
    [[ "$deep_nonexistent" == "deep_default" ]]
}

# Test setting simple keys
test_set_simple_keys() {
    init_complex_test_config

    # Set and retrieve simple keys
    set_global_config "test_key" "test_value"
    set_global_config "timeout" "60"

    local test_val timeout_val
    test_val=$(get_global_config "test_key" "unknown")
    timeout_val=$(get_global_config "timeout" "unknown")

    [[ "$test_val" == "test_value" ]] && [[ "$timeout_val" == "60" ]]
}

# Test setting nested keys
test_set_nested_keys() {
    init_complex_test_config

    # Set nested keys
    set_global_config "defaults.update_interval" "14"
    set_global_config "new_section.new_key" "new_value"

    local update_interval new_value
    update_interval=$(get_global_config "defaults.update_interval" "unknown")
    new_value=$(get_global_config "new_section.new_key" "unknown")

    [[ "$update_interval" == "14" ]] && [[ "$new_value" == "new_value" ]]
}

# Test setting deep nested keys
test_set_deep_nested_keys() {
    init_complex_test_config

    # Set deep nested keys
    set_global_config "modules.apt_update.enabled" "false"
    set_global_config "modules.new_module.enabled" "true"

    local apt_enabled new_module_enabled
    apt_enabled=$(get_global_config "modules.apt_update.enabled" "unknown")
    new_module_enabled=$(get_global_config "modules.new_module.enabled" "unknown")

    [[ "$apt_enabled" == "false" ]] && [[ "$new_module_enabled" == "true" ]]
}

# Test module configuration parsing
test_module_config_parsing() {
    init_test_module_config

    local enabled interval desc priority
    enabled=$(get_module_config "test_module" "enabled" "unknown")
    interval=$(get_module_config "test_module" "interval_days" "unknown")
    desc=$(get_module_config "test_module" "description" "unknown")
    priority=$(get_module_config "test_module" "priority" "unknown")

    [[ "$enabled" == "true" ]] &&
    [[ "$interval" == "7" ]] &&
    [[ "$desc" == "Test module for YAML parsing" ]] &&
    [[ "$priority" == "medium" ]]
}

# Test module nested configuration parsing
test_module_nested_parsing() {
    init_test_module_config

    local verbose timeout retries debug_mode
    verbose=$(get_module_config "test_module" "options.verbose" "unknown")
    timeout=$(get_module_config "test_module" "options.timeout" "unknown")
    retries=$(get_module_config "test_module" "options.retries" "unknown")
    debug_mode=$(get_module_config "test_module" "advanced.settings.debug_mode" "unknown")

    [[ "$verbose" == "true" ]] &&
    [[ "$timeout" == "60" ]] &&
    [[ "$retries" == "3" ]] &&
    [[ "$debug_mode" == "false" ]]
}

# Test module configuration setting
test_module_config_setting() {
    init_test_module_config

    # Set various module config values
    set_module_config "test_module" "enabled" "false"
    set_module_config "test_module" "interval_days" "14"
    set_module_config "test_module" "options.verbose" "false"

    local enabled interval verbose
    enabled=$(get_module_config "test_module" "enabled" "unknown")
    interval=$(get_module_config "test_module" "interval_days" "unknown")
    verbose=$(get_module_config "test_module" "options.verbose" "unknown")

    [[ "$enabled" == "false" ]] &&
    [[ "$interval" == "14" ]] &&
    [[ "$verbose" == "false" ]]
}

# Test YAML structure validation
test_yaml_validation() {
    init_complex_test_config

    # Test valid structure
    if validate_yaml_structure "$TEST_GLOBAL_CONFIG" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Test error handling
test_error_handling() {
    # Test with non-existent file
    export GLOBAL_CONFIG="/nonexistent/path/config.yaml"

    local result
    result=$(get_global_config "test.key" "default_value")

    # Reset to valid config
    export GLOBAL_CONFIG="$TEST_GLOBAL_CONFIG"

    [[ "$result" == "default_value" ]]
}

# Test environment variable overrides
test_env_var_overrides() {
    init_complex_test_config

    # Set environment variables
    UPKEP_DEBUG=true
    UPKEP_DEFAULTS_UPDATE_INTERVAL=21

    local debug_val interval_val
    debug_val=$(get_config "debug" "unknown")
    interval_val=$(get_config "defaults.update_interval" "unknown")

    # Clean up
    unset UPKEP_DEBUG UPKEP_DEFAULTS_UPDATE_INTERVAL

    [[ "$debug_val" == "true" ]] && [[ "$interval_val" == "21" ]]
}

# Cleanup function
cleanup() {
    rm -rf "$TEST_CONFIG_DIR"
    unset UPKEP_DEBUG UPKEP_DEFAULTS_UPDATE_INTERVAL
    export GLOBAL_CONFIG="$HOME/.upkep/config.yaml"
    export MODULE_CONFIG_DIR="$HOME/.upkep/modules"
}

# Main test execution
main() {
    echo "Starting Enhanced YAML Parsing Tests"
    echo "====================================="
    echo ""

    # Clean up before tests
    cleanup
    mkdir -p "$TEST_CONFIG_DIR" "$TEST_MODULE_CONFIG_DIR"

    # Set test environment variables after cleanup
    export GLOBAL_CONFIG="$TEST_GLOBAL_CONFIG"
    export MODULE_CONFIG_DIR="$TEST_MODULE_CONFIG_DIR"

    # Run tests
    run_test "Simple Key Parsing" "test_simple_key_parsing"
    run_test "Two-Level Nested Parsing" "test_two_level_nested_parsing"
    run_test "Three-Level Nested Parsing" "test_three_level_nested_parsing"
    run_test "Edge Cases and Special Values" "test_edge_cases"
    run_test "Default Value Fallback" "test_default_fallback"
    run_test "Setting Simple Keys" "test_set_simple_keys"
    run_test "Setting Nested Keys" "test_set_nested_keys"
    run_test "Setting Deep Nested Keys" "test_set_deep_nested_keys"
    run_test "Module Config Parsing" "test_module_config_parsing"
    run_test "Module Nested Parsing" "test_module_nested_parsing"
    run_test "Module Config Setting" "test_module_config_setting"
    run_test "YAML Structure Validation" "test_yaml_validation"
    run_test "Error Handling" "test_error_handling"
    run_test "Environment Variable Overrides" "test_env_var_overrides"

    # Clean up after tests
    cleanup

    # Print results
    echo ""
    echo "====================================="
    echo "Test Results: $TESTS_PASSED/$TESTS_TOTAL passed"

    if [[ $TESTS_PASSED -eq $TESTS_TOTAL ]]; then
        echo "✓ All enhanced YAML parsing tests passed!"
        exit 0
    else
        echo "✗ Some enhanced YAML parsing tests failed"
        exit 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi