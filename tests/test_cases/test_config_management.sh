#!/bin/bash
# test_config_management.sh - Test configuration management system

# Set up test environment
TEST_CONFIG_DIR="/tmp/test_upkep_config"
TEST_CONFIG_FILE="$TEST_CONFIG_DIR/config.yaml"

# Create test config directory
mkdir -p "$TEST_CONFIG_DIR"

# Override config paths for testing
export GLOBAL_CONFIG="$TEST_CONFIG_FILE"
export HOME="/tmp"
export STATE_FILE="/tmp/test_upkep_state"

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

notifications:
  enabled: true
EOF
    return 0
}

# Test configuration reading
test_config_reading() {
    # Clean up from any previous test
    rm -f "$TEST_CONFIG_FILE"
    
    init_test_config
    
    # Re-export the test config path to ensure it's used
    export GLOBAL_CONFIG="$TEST_CONFIG_FILE"
    
    local value
    value=$(get_global_config "defaults.update_interval" "unknown")
    [[ "$value" == "7" ]]
}

# Test configuration writing
test_config_writing() {
    # Clean up and start fresh
    rm -f "$TEST_CONFIG_FILE"
    init_test_config
    export GLOBAL_CONFIG="$TEST_CONFIG_FILE"
    
    set_global_config "defaults.update_interval" "14"
    local value
    value=$(get_global_config "defaults.update_interval" "unknown")
    [[ "$value" == "14" ]]
}

# Test nested key creation
test_nested_key_creation() {
    # Clean up and start fresh
    rm -f "$TEST_CONFIG_FILE"
    init_test_config
    export GLOBAL_CONFIG="$TEST_CONFIG_FILE"
    
    set_global_config "new_section.new_key" "new_value"
    local value
    value=$(get_global_config "new_section.new_key" "unknown")
    [[ "$value" == "new_value" ]]
}

# Test configuration persistence
test_config_persistence() {
    # Clean up and start fresh
    rm -f "$TEST_CONFIG_FILE"
    init_test_config
    export GLOBAL_CONFIG="$TEST_CONFIG_FILE"
    
    # Set a value
    set_global_config "defaults.cleanup_interval" "45"
    
    # Read it back using a fresh function call
    local value
    value=$(get_global_config "defaults.cleanup_interval" "unknown")
    [[ "$value" == "45" ]]
}

# Test fallback method
test_fallback_method() {
    # Clean up and start fresh
    rm -f "$TEST_CONFIG_FILE"
    init_test_config
    export GLOBAL_CONFIG="$TEST_CONFIG_FILE"
    
    # Test with yq unavailable (if yq exists, this tests the fallback path)
    local old_yq=""
    if command -v yq >/dev/null 2>&1; then
        # Temporarily hide yq to force fallback
        export PATH="/tmp:$PATH"
        echo '#!/bin/bash\nexit 1' > /tmp/yq
        chmod +x /tmp/yq
    fi
    
    set_global_config "test.fallback_key" "fallback_value"
    local value
    value=$(get_global_config "test.fallback_key" "unknown")
    
    # Restore yq if needed
    if [[ -f /tmp/yq ]]; then
        rm -f /tmp/yq
        export PATH="${PATH#/tmp:}"
    fi
    
    [[ "$value" == "fallback_value" ]]
}

# Test default value handling
test_default_values() {
    # Clean up and start fresh
    rm -f "$TEST_CONFIG_FILE"
    init_test_config
    export GLOBAL_CONFIG="$TEST_CONFIG_FILE"
    
    local value
    value=$(get_global_config "nonexistent.key" "default_value")
    [[ "$value" == "default_value" ]]
}

# Run all tests
echo "=== Configuration Management Test Suite ==="
echo ""

run_test "Configuration Reading" "test_config_reading"
run_test "Configuration Writing" "test_config_writing"
run_test "Nested Key Creation" "test_nested_key_creation"
run_test "Configuration Persistence" "test_config_persistence"
run_test "Fallback Method" "test_fallback_method"
run_test "Default Value Handling" "test_default_values"

# Clean up
rm -rf "$TEST_CONFIG_DIR"
rm -f "$STATE_FILE"

# Report results
echo ""
echo "=== Test Results ==="
echo "Tests passed: $TESTS_PASSED/$TESTS_TOTAL"

if [[ $TESTS_PASSED -eq $TESTS_TOTAL ]]; then
    echo "✅ All configuration management tests passed!"
    exit 0
else
    echo "❌ Some configuration management tests failed!"
    exit 1
fi 