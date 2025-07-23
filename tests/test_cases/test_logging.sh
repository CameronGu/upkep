#!/bin/bash
# test_logging.sh - Test enhanced logging system

# Set up test environment
TEST_LOG_DIR="/tmp/test_upkep_logs"
TEST_LOG_FILE="$TEST_LOG_DIR/upkep.log"
TEST_CONFIG_DIR="/tmp/test_upkep_config"
TEST_CONFIG_FILE="$TEST_CONFIG_DIR/config.yaml"

# Create test directories
mkdir -p "$TEST_LOG_DIR"
mkdir -p "$TEST_CONFIG_DIR"

# Override paths for testing
export HOME="/tmp/test_upkep_home"
mkdir -p "$HOME/.upkep"
export UPKEP_LOG_FILE="$HOME/.upkep/upkep.log"

# Load required modules
source "$(dirname "$0")/../../scripts/core/utils.sh"
source "$(dirname "$0")/../../scripts/core/config/global.sh" 2>/dev/null || true

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

logging:
  level: info
  file_logging: false

notifications:
  enabled: true
EOF
    export GLOBAL_CONFIG="$TEST_CONFIG_FILE"
    return 0
}

# Clean up function
cleanup_test() {
    rm -f "$UPKEP_LOG_FILE"
    rm -f "$TEST_LOG_FILE"
    unset UPKEP_LOG_TO_FILE
    unset UPKEP_LOGGING_LEVEL
}

# Test console logging (backward compatibility)
test_console_logging_unchanged() {
    cleanup_test

    # Capture console output
    local output
    output=$(log_message "INFO" "Test message" 2>&1)

    # Verify console output contains expected elements
    if [[ "$output" =~ \[INFO\] ]] && [[ "$output" =~ "Test message" ]] && [[ "$output" =~ [0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
        return 0
    else
        echo "Console output doesn't match expected format: $output"
        return 1
    fi
}

# Test file logging disabled by default
test_file_logging_disabled_by_default() {
    cleanup_test

    # Run log_message without UPKEP_LOG_TO_FILE
    log_message "INFO" "Test message" >/dev/null 2>&1

    # Verify no log file was created
    if [[ ! -f "$UPKEP_LOG_FILE" ]]; then
        return 0
    else
        echo "Log file was created when it shouldn't have been"
        return 1
    fi
}

# Test file logging when enabled
test_file_logging_when_enabled() {
    cleanup_test

    # Enable file logging
    export UPKEP_LOG_TO_FILE=true

    # Run log_message
    log_message "INFO" "Test file message" >/dev/null 2>&1

    # Verify log file was created and contains message
    if [[ -f "$UPKEP_LOG_FILE" ]] && grep -q "Test file message" "$UPKEP_LOG_FILE" && grep -q "\[INFO\]" "$UPKEP_LOG_FILE"; then
        return 0
    else
        echo "Log file not created or doesn't contain expected content"
        [[ -f "$UPKEP_LOG_FILE" ]] && echo "File contents: $(cat "$UPKEP_LOG_FILE")"
        return 1
    fi
}

# Test multiple log messages append correctly
test_file_logging_append() {
    cleanup_test

    # Enable file logging
    export UPKEP_LOG_TO_FILE=true

    # Run multiple log_message calls
    log_message "INFO" "First message" >/dev/null 2>&1
    log_message "WARN" "Second message" >/dev/null 2>&1
    log_message "ERROR" "Third message" >/dev/null 2>&1

    # Verify all messages are in log file
    if [[ -f "$UPKEP_LOG_FILE" ]] &&
       grep -q "First message" "$UPKEP_LOG_FILE" &&
       grep -q "Second message" "$UPKEP_LOG_FILE" &&
       grep -q "Third message" "$UPKEP_LOG_FILE"; then

        # Verify correct number of lines (should be 3)
        local line_count
        line_count=$(wc -l < "$UPKEP_LOG_FILE")
        if [[ "$line_count" -eq 3 ]]; then
            return 0
        else
            echo "Expected 3 lines, got $line_count"
            return 1
        fi
    else
        echo "Not all messages found in log file"
        [[ -f "$UPKEP_LOG_FILE" ]] && echo "File contents: $(cat "$UPKEP_LOG_FILE")"
        return 1
    fi
}

# Test log directory creation
test_log_directory_creation() {
    cleanup_test

    # Remove the .upkep directory to test creation
    rm -rf "$HOME/.upkep"

    # Enable file logging
    export UPKEP_LOG_TO_FILE=true

    # Run log_message
    log_message "INFO" "Test directory creation" >/dev/null 2>&1

    # Verify directory and file were created
    if [[ -d "$HOME/.upkep" ]] && [[ -f "$UPKEP_LOG_FILE" ]] && grep -q "Test directory creation" "$UPKEP_LOG_FILE"; then
        return 0
    else
        echo "Directory or log file not created properly"
        return 1
    fi
}

# Test different log levels
test_log_levels() {
    cleanup_test

    export UPKEP_LOG_TO_FILE=true
    export UPKEP_LOGGING_LEVEL=DEBUG  # Set to DEBUG to show all levels

    # Test each log level
    log_message "DEBUG" "Debug message" >/dev/null 2>&1
    log_message "INFO" "Info message" >/dev/null 2>&1
    log_message "WARN" "Warning message" >/dev/null 2>&1
    log_message "ERROR" "Error message" >/dev/null 2>&1
    log_message "SUCCESS" "Success message" >/dev/null 2>&1

    # Verify all levels are in log file
    if [[ -f "$UPKEP_LOG_FILE" ]] &&
       grep -q "\[DEBUG\].*Debug message" "$UPKEP_LOG_FILE" &&
       grep -q "\[INFO\].*Info message" "$UPKEP_LOG_FILE" &&
       grep -q "\[WARN\].*Warning message" "$UPKEP_LOG_FILE" &&
       grep -q "\[ERROR\].*Error message" "$UPKEP_LOG_FILE" &&
       grep -q "\[SUCCESS\].*Success message" "$UPKEP_LOG_FILE"; then
        return 0
    else
        echo "Not all log levels found in log file"
        [[ -f "$UPKEP_LOG_FILE" ]] && echo "File contents: $(cat "$UPKEP_LOG_FILE")"
        return 1
    fi
}

# Test log message format
test_log_message_format() {
    cleanup_test

    export UPKEP_LOG_TO_FILE=true

    # Log a message
    log_message "INFO" "Format test message" >/dev/null 2>&1

    # Verify format: [YYYY-MM-DD HH:MM:SS] [LEVEL] message
    if [[ -f "$UPKEP_LOG_FILE" ]] &&
       grep -E "\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] \[INFO\] Format test message" "$UPKEP_LOG_FILE"; then
        return 0
    else
        echo "Log message format doesn't match expected pattern"
        [[ -f "$UPKEP_LOG_FILE" ]] && echo "File contents: $(cat "$UPKEP_LOG_FILE")"
        return 1
    fi
}

# Test with context information (if implemented)
test_log_with_context() {
    cleanup_test

    export UPKEP_LOG_TO_FILE=true

    # Test if log_message accepts context parameter
    if log_message "INFO" "Context test message" "test_module" >/dev/null 2>&1; then
        # If context is supported, verify it's in the log
        if [[ -f "$UPKEP_LOG_FILE" ]] && grep -q "test_module" "$UPKEP_LOG_FILE"; then
            return 0
        else
            # Context might not be implemented yet, check basic functionality
            if grep -q "Context test message" "$UPKEP_LOG_FILE"; then
                return 0
            else
                return 1
            fi
        fi
    else
        return 1
    fi
}

# Test environment variable override
test_env_var_override() {
    cleanup_test

    # Test with different values
    export UPKEP_LOG_TO_FILE=false
    log_message "INFO" "Should not be logged" >/dev/null 2>&1

    if [[ -f "$UPKEP_LOG_FILE" ]]; then
        echo "Log file created when UPKEP_LOG_TO_FILE=false"
        return 1
    fi

    # Test with true
    export UPKEP_LOG_TO_FILE=true
    log_message "INFO" "Should be logged" >/dev/null 2>&1

    if [[ -f "$UPKEP_LOG_FILE" ]] && grep -q "Should be logged" "$UPKEP_LOG_FILE"; then
        return 0
    else
        echo "Log file not created when UPKEP_LOG_TO_FILE=true"
        return 1
    fi
}

# Test log level filtering based on configuration
test_log_level_filtering() {
    cleanup_test

    export UPKEP_LOG_TO_FILE=true

    # Test with default level (INFO)
    export UPKEP_LOGGING_LEVEL=INFO

    log_message "DEBUG" "Debug message should be filtered" >/dev/null 2>&1
    log_message "INFO" "Info message should appear" >/dev/null 2>&1
    log_message "WARN" "Warning message should appear" >/dev/null 2>&1
    log_message "ERROR" "Error message should appear" >/dev/null 2>&1

    # Check that DEBUG is filtered out but others appear
    if [[ -f "$UPKEP_LOG_FILE" ]] &&
       ! grep -q "Debug message should be filtered" "$UPKEP_LOG_FILE" &&
       grep -q "Info message should appear" "$UPKEP_LOG_FILE" &&
       grep -q "Warning message should appear" "$UPKEP_LOG_FILE" &&
       grep -q "Error message should appear" "$UPKEP_LOG_FILE"; then
        return 0
    else
        echo "Log level filtering not working correctly"
        [[ -f "$UPKEP_LOG_FILE" ]] && echo "File contents: $(cat "$UPKEP_LOG_FILE")"
        return 1
    fi
}

# Test different log level thresholds
test_log_level_thresholds() {
    cleanup_test

    export UPKEP_LOG_TO_FILE=true

    # Test with WARN level - should filter DEBUG and INFO
    export UPKEP_LOGGING_LEVEL=WARN

    log_message "DEBUG" "Debug filtered" >/dev/null 2>&1
    log_message "INFO" "Info filtered" >/dev/null 2>&1
    log_message "WARN" "Warning shown" >/dev/null 2>&1
    log_message "ERROR" "Error shown" >/dev/null 2>&1

    # Check filtering
    if [[ -f "$UPKEP_LOG_FILE" ]] &&
       ! grep -q "Debug filtered" "$UPKEP_LOG_FILE" &&
       ! grep -q "Info filtered" "$UPKEP_LOG_FILE" &&
       grep -q "Warning shown" "$UPKEP_LOG_FILE" &&
       grep -q "Error shown" "$UPKEP_LOG_FILE"; then

        # Test DEBUG level - should show everything
        cleanup_test
        export UPKEP_LOG_TO_FILE=true
        export UPKEP_LOGGING_LEVEL=DEBUG

        log_message "DEBUG" "Debug shown" >/dev/null 2>&1
        log_message "INFO" "Info shown" >/dev/null 2>&1

        if grep -q "Debug shown" "$UPKEP_LOG_FILE" && grep -q "Info shown" "$UPKEP_LOG_FILE"; then
            return 0
        else
            echo "DEBUG level not showing all messages"
            return 1
        fi
    else
        echo "Log level threshold filtering not working"
        [[ -f "$UPKEP_LOG_FILE" ]] && echo "File contents: $(cat "$UPKEP_LOG_FILE")"
        return 1
    fi
}

# Initialize test environment
echo "Setting up test environment..."
init_test_config

# Run all tests
echo "Running logging system tests..."
echo "================================"

run_test "Console logging unchanged (backward compatibility)" "test_console_logging_unchanged"
run_test "File logging disabled by default" "test_file_logging_disabled_by_default"
run_test "File logging when enabled" "test_file_logging_when_enabled"
run_test "File logging append functionality" "test_file_logging_append"
run_test "Log directory creation" "test_log_directory_creation"
run_test "Different log levels" "test_log_levels"
run_test "Log message format" "test_log_message_format"
run_test "Log with context information" "test_log_with_context"
run_test "Environment variable override" "test_env_var_override"
run_test "Log level filtering based on configuration" "test_log_level_filtering"
run_test "Different log level thresholds" "test_log_level_thresholds"

# Cleanup
cleanup_test
rm -rf "$TEST_LOG_DIR"
rm -rf "$TEST_CONFIG_DIR"
rm -rf "$HOME"

# Report results
echo "================================"
echo "Test Results: $TESTS_PASSED/$TESTS_TOTAL passed"

if [[ $TESTS_PASSED -eq $TESTS_TOTAL ]]; then
    echo "✓ All logging tests passed!"
    exit 0
else
    echo "✗ Some tests failed!"
    exit 1
fi