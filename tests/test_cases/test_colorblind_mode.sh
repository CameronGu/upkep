#!/bin/bash
# test_colorblind_mode.sh - Test colorblind mode functionality

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MAIN_SCRIPT="$PROJECT_ROOT/scripts/main.sh"

# Colors for test output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_exit="$3"

    echo -n "Testing: $test_name... "

    # Run the test command
    if eval "$test_command" >/dev/null 2>&1; then
        local exit_code=$?
        if [[ $exit_code -eq $expected_exit ]]; then
            echo -e "${GREEN}PASS${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}FAIL${NC} (exit code $exit_code, expected $expected_exit)"
            ((TESTS_FAILED++))
        fi
    else
        local exit_code=$?
        if [[ $exit_code -eq $expected_exit ]]; then
            echo -e "${GREEN}PASS${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}FAIL${NC} (exit code $exit_code, expected $expected_exit)"
            ((TESTS_FAILED++))
        fi
    fi
}

# Test colorblind mode detection
test_colorblind_detection() {
    echo "Testing colorblind mode detection..."

    # Test with environment variable
    export UPKEP_COLORBLIND=1
    run_test "Environment variable enabled" "source $PROJECT_ROOT/scripts/modules/core/utils.sh && is_colorblind_mode" 0

    export UPKEP_COLORBLIND=true
    run_test "Environment variable enabled (true)" "source $PROJECT_ROOT/scripts/modules/core/utils.sh && is_colorblind_mode" 0

    unset UPKEP_COLORBLIND
    run_test "Environment variable disabled" "source $PROJECT_ROOT/scripts/modules/core/utils.sh && is_colorblind_mode" 1

    echo ""
}

# Test command-line flags
test_command_line_flags() {
    echo "Testing command-line flags..."

    # Test --colorblind flag
    run_test "--colorblind flag" "bash $MAIN_SCRIPT --colorblind --help >/dev/null 2>&1" 0

    # Test -c flag
    run_test "-c flag" "bash $MAIN_SCRIPT -c --help >/dev/null 2>&1" 0

    # Test --no-colorblind flag
    run_test "--no-colorblind flag" "bash $MAIN_SCRIPT --no-colorblind --help >/dev/null 2>&1" 0

    echo ""
}

# Test subcommand functionality
test_subcommand() {
    echo "Testing colorblind subcommand..."

    # Test colorblind on
    run_test "colorblind on" "bash $MAIN_SCRIPT colorblind on >/dev/null 2>&1" 0

    # Test colorblind off
    run_test "colorblind off" "bash $MAIN_SCRIPT colorblind off >/dev/null 2>&1" 0

    # Test colorblind status
    run_test "colorblind status" "bash $MAIN_SCRIPT colorblind status >/dev/null 2>&1" 0

    # Test colorblind help
    run_test "colorblind help" "bash $MAIN_SCRIPT colorblind help >/dev/null 2>&1" 0

    echo ""
}

# Test configuration persistence
test_config_persistence() {
    echo "Testing configuration persistence..."

    # Create a temporary config directory
    local temp_config="$PROJECT_ROOT/tests/temp_config"
    mkdir -p "$temp_config"
    export UPKEP_CONFIG="$temp_config/config.yaml"

    # Initialize the config system with the temp config
    source "$PROJECT_ROOT/scripts/core/config_simple.sh"
    init_simple_config

    # Test setting colorblind mode
    run_test "Set colorblind mode" "UPKEP_CONFIG=$UPKEP_CONFIG bash $MAIN_SCRIPT colorblind on >/dev/null 2>&1" 0

    # Test that it was saved to config
    if [[ -f "$UPKEP_CONFIG" ]] && grep -q "colorblind: true" "$UPKEP_CONFIG"; then
        echo -e "${GREEN}PASS${NC}: Configuration saved correctly"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC}: Configuration not saved correctly"
        ((TESTS_FAILED++))
    fi

    # Test disabling colorblind mode
    run_test "Disable colorblind mode" "UPKEP_CONFIG=$UPKEP_CONFIG bash $MAIN_SCRIPT colorblind off >/dev/null 2>&1" 0

    # Test that it was saved to config
    if [[ -f "$UPKEP_CONFIG" ]] && grep -q "colorblind: false" "$UPKEP_CONFIG"; then
        echo -e "${GREEN}PASS${NC}: Configuration updated correctly"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC}: Configuration not updated correctly"
        ((TESTS_FAILED++))
    fi

    # Clean up
    rm -rf "$temp_config"
    unset UPKEP_CONFIG

    echo ""
}

# Test help text includes colorblind options
test_help_text() {
    echo "Testing help text includes colorblind options..."

    # Test main help includes colorblind
    if bash "$MAIN_SCRIPT" --help 2>/dev/null | grep -q "colorblind"; then
        echo -e "${GREEN}PASS${NC}: Main help includes colorblind options"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC}: Main help missing colorblind options"
        ((TESTS_FAILED++))
    fi

    # Test CLI help includes colorblind
    if bash "$MAIN_SCRIPT" help 2>/dev/null | grep -q "colorblind"; then
        echo -e "${GREEN}PASS${NC}: CLI help includes colorblind command"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC}: CLI help missing colorblind command"
        ((TESTS_FAILED++))
    fi

    echo ""
}

# Main test execution
main() {
    echo "Testing Colorblind Mode Functionality"
    echo "===================================="
    echo ""

    # Check if main script exists
    if [[ ! -f "$MAIN_SCRIPT" ]]; then
        echo -e "${RED}Error: Main script not found at $MAIN_SCRIPT${NC}"
        exit 1
    fi

    # Run tests
    test_colorblind_detection
    test_command_line_flags
    test_subcommand
    test_config_persistence
    test_help_text

    # Summary
    echo "Test Summary"
    echo "============"
    echo -e "${GREEN}Tests passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Tests failed: $TESTS_FAILED${NC}"
    echo ""

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed! Colorblind mode functionality is working correctly.${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed. Please review the implementation.${NC}"
        exit 1
    fi
}

# Run main function
main "$@"