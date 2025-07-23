#!/bin/bash
# test_config_backup_system.sh - Test automatic config backup before changes
# shellcheck disable=SC2317  # Test functions called indirectly via eval

# Source the core modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source utilities directly
source "$PROJECT_ROOT/scripts/core/utils.sh" 2>/dev/null || {
    echo "Warning: Cannot source utilities - some functions may not be available"
}

# Source config modules
source "$PROJECT_ROOT/scripts/core/config.sh" 2>/dev/null || {
    echo "Error: Cannot source config.sh"
    exit 1
}

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

# Test setup
setup_test_env() {
    local test_name="$1"
    TEST_HOME=$(mktemp -d)
    export HOME="$TEST_HOME"

    # Set up config paths for test environment
    export GLOBAL_CONFIG="$HOME/.upkep/config.yaml"
    export MODULE_CONFIG_DIR="$HOME/.upkep/modules"
    export BACKUP_DIR="$HOME/.upkep/backups"
}

# Test cleanup
cleanup_test_env() {
    if [[ -n "$TEST_HOME" && -d "$TEST_HOME" ]]; then
        rm -rf "$TEST_HOME"
    fi
}

# Count backups in backup directory
count_backups() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        echo "0"
        return
    fi

    find "$BACKUP_DIR" -maxdepth 1 -type d -name "*backup*" | wc -l
}

# Test 1: set_global_config creates automatic backup
test_global_config_backup() {
    setup_test_env "global_config_backup"

    # Initialize config
    init_config >/dev/null 2>&1

    # Verify initial state - should have no backups initially
    local initial_backups
    initial_backups=$(count_backups)

    # Make a configuration change
    set_global_config "defaults.update_interval" "14" >/dev/null 2>&1

    # Check that backup was created
    local after_backups
    after_backups=$(count_backups)

    cleanup_test_env

    # Should have at least one backup after the change
    [[ $after_backups -gt $initial_backups ]]
}

# Test 2: set_module_config creates automatic backup
test_module_config_backup() {
    setup_test_env "module_config_backup"

    # Initialize config
    init_config >/dev/null 2>&1

    # Create a module config (this will create one backup)
    set_module_config "test_module" "enabled" "true" >/dev/null 2>&1

    # Count backups after initial creation
    local initial_backups
    initial_backups=$(count_backups)

    # Sleep to ensure different timestamp
    sleep 1

    # Make another configuration change
    set_module_config "test_module" "interval_days" "21" >/dev/null 2>&1

    # Check that backup was created
    local after_backups
    after_backups=$(count_backups)

    cleanup_test_env

    # Should have more backups after the second change
    [[ $after_backups -gt $initial_backups ]]
}

# Test 3: restore_config creates automatic backup
test_restore_config_backup() {
    setup_test_env "restore_config_backup"

    # Initialize config and make some changes
    init_config >/dev/null 2>&1
    set_global_config "defaults.update_interval" "7" >/dev/null 2>&1
    set_module_config "test_module" "enabled" "true" >/dev/null 2>&1

    # Create a manual backup to restore from
    backup_config "test_restore_backup" >/dev/null 2>&1

    # Make additional changes
    set_global_config "defaults.update_interval" "14" >/dev/null 2>&1
    set_module_config "test_module" "enabled" "false" >/dev/null 2>&1

    # Count backups before restore (should be several by now)
    local initial_backups
    initial_backups=$(count_backups)

    # Sleep to ensure different timestamp
    sleep 1

    # Restore from backup (with confirm=true to skip prompt)
    restore_config "$BACKUP_DIR/test_restore_backup" "true" >/dev/null 2>&1

    # Check that automatic backup was created
    local after_backups
    after_backups=$(count_backups)

    cleanup_test_env

    # Should have more backups after restore (restore creates backup before restoring)
    [[ $after_backups -gt $initial_backups ]]
}

# Test 4: Multiple changes create multiple backups with retention
test_backup_retention() {
    setup_test_env "backup_retention"

    # Initialize config
    init_config >/dev/null 2>&1

    # Make multiple configuration changes to generate backups
    for i in {1..7}; do
        set_global_config "defaults.update_interval" "$i" >/dev/null 2>&1
        sleep 1  # Ensure different timestamps
    done

    # Check backup count (should be limited to 5 auto-backups due to retention)
    local backup_count
    backup_count=$(find "$BACKUP_DIR" -maxdepth 1 -type d -name "auto_backup_*" | wc -l)

    cleanup_test_env

    # Should have 5 or fewer auto-backups due to retention policy
    [[ $backup_count -le 5 ]]
}

# Test 5: Backup doesn't interfere with normal operation when no config exists
test_backup_with_no_existing_config() {
    setup_test_env "no_existing_config"

    # Try to set config without initializing first
    set_global_config "defaults.update_interval" "7" >/dev/null 2>&1

    # Should create config and set value without error
    local value
    value=$(get_global_config "defaults.update_interval" "")

    cleanup_test_env

    [[ "$value" == "7" ]]
}

# Test 6: Error handling when backup directory is not accessible
test_backup_error_handling() {
    setup_test_env "backup_error_handling"

    # Initialize config
    init_config >/dev/null 2>&1

    # Make backup directory unwritable
    chmod 000 "$BACKUP_DIR" 2>/dev/null

    # Try to make a config change - should handle backup error gracefully
    set_global_config "defaults.update_interval" "14" >/dev/null 2>&1
    local config_result=$?

    # Restore permissions for cleanup
    chmod 755 "$BACKUP_DIR" 2>/dev/null

    # Verify the config was still set despite backup failure
    local value
    value=$(get_global_config "defaults.update_interval" "")

    cleanup_test_env

    # Should succeed in setting config even if backup fails
    [[ $config_result -eq 0 && "$value" == "14" ]]
}

# Run all tests
echo "=== Automatic Config Backup System Tests ==="
echo ""

run_test "Global Config Backup" "test_global_config_backup"
run_test "Module Config Backup" "test_module_config_backup"
run_test "Restore Config Backup" "test_restore_config_backup"
run_test "Backup Retention System" "test_backup_retention"
run_test "Backup With No Existing Config" "test_backup_with_no_existing_config"
run_test "Backup Error Handling" "test_backup_error_handling"

# Report results
echo ""
echo "=== Test Results ==="
echo "Tests passed: $TESTS_PASSED/$TESTS_TOTAL"

if [[ $TESTS_PASSED -eq $TESTS_TOTAL ]]; then
    echo "✅ All automatic config backup tests passed!"
    exit 0
else
    echo "❌ Some automatic config backup tests failed!"
    exit 1
fi