#!/bin/bash
# lint.sh - Simple linting system for upKep project

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MAX_LINES=300
IGNORE_FILES=("upkep.sh" "main.sh" "advanced_module.sh" "basic_module.sh")

# Statistics
TOTAL_FILES=0
FAILED_FILES=0
WARNINGS=0
ERRORS=0

# Print colored output
print_status() {
    local status_type="$1"
    local message="$2"
    case "$status_type" in
        "PASS")
            echo -e "${GREEN}✓${NC} $message"
            ;;
        "FAIL")
            echo -e "${RED}✗${NC} $message"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠${NC} $message"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ${NC} $message"
            ;;
    esac
}

# Check dependencies
check_dependencies() {
    if ! command -v shellcheck >/dev/null 2>&1; then
        echo "Warning: shellcheck not found. Install with: sudo apt install shellcheck"
    fi
    
    if ! command -v yamllint >/dev/null 2>&1; then
        echo "Warning: yamllint not found. Install with: sudo apt install yamllint"
    fi
    
    print_status "INFO" "Dependency check complete"
}

# Check line count
check_line_count() {
    local file="$1"
    local line_count=$(wc -l < "$file" 2>/dev/null || echo "0")
    
    # Check if file should be ignored
    for ignore_file in "${IGNORE_FILES[@]}"; do
        if [[ "$(basename "$file")" == "$ignore_file" ]]; then
            print_status "INFO" "Skipping line count check for $file (ignored)"
            return 0
        fi
    done
    
    if [[ $line_count -gt $MAX_LINES ]]; then
        print_status "FAIL" "$file: $line_count lines (exceeds $MAX_LINES limit)"
        ((FAILED_FILES++))
        ((ERRORS++))
        return 1
    else
        print_status "PASS" "$file: $line_count lines"
        return 0
    fi
}

# Check shell script
check_shell_script() {
    local file="$1"
    
    if command -v shellcheck >/dev/null 2>&1; then
        if shellcheck -s bash -S style "$file" >/dev/null 2>&1; then
            print_status "PASS" "$file: shellcheck passed"
            return 0
        else
            print_status "FAIL" "$file: shellcheck found issues"
            ((FAILED_FILES++))
            ((ERRORS++))
            return 1
        fi
    else
        print_status "WARN" "$file: shellcheck not available"
        ((WARNINGS++))
        return 0
    fi
}

# Check YAML file
check_yaml_file() {
    local file="$1"
    
    if command -v yamllint >/dev/null 2>&1; then
        if yamllint "$file" >/dev/null 2>&1; then
            print_status "PASS" "$file: yamllint passed"
            return 0
        else
            print_status "FAIL" "$file: yamllint found issues"
            ((FAILED_FILES++))
            ((ERRORS++))
            return 1
        fi
    else
        print_status "WARN" "$file: yamllint not available"
        ((WARNINGS++))
        return 0
    fi
}

# Check trailing whitespace
check_trailing_whitespace() {
    local file="$1"
    
    if grep -q '[[:space:]]$' "$file"; then
        print_status "FAIL" "$file: contains trailing whitespace"
        ((FAILED_FILES++))
        ((ERRORS++))
        return 1
    else
        print_status "PASS" "$file: no trailing whitespace"
        return 0
    fi
}

# Lint a single file
lint_file() {
    local file="$1"
    local file_ext="${file##*.}"
    local failed=0
    
    print_status "INFO" "Linting $file"
    ((TOTAL_FILES++))
    
    # Check line count
    if ! check_line_count "$file"; then
        failed=1
    fi
    
    # Check trailing whitespace
    if ! check_trailing_whitespace "$file"; then
        failed=1
    fi
    
    # Language-specific checks
    case "$file_ext" in
        "sh"|"bash")
            if ! check_shell_script "$file"; then
                failed=1
            fi
            ;;
        "yaml"|"yml")
            if ! check_yaml_file "$file"; then
                failed=1
            fi
            ;;
    esac
    
    echo ""
    return $failed
}

# Print summary
print_summary() {
    echo ""
    echo "=== Linting Summary ==="
    echo "Total files checked: $TOTAL_FILES"
    echo "Files with errors: $FAILED_FILES"
    echo "Total errors: $ERRORS"
    echo "Total warnings: $WARNINGS"
    
    if [[ $ERRORS -eq 0 ]] && [[ $FAILED_FILES -eq 0 ]]; then
        print_status "PASS" "All files passed linting!"
        exit 0
    else
        print_status "FAIL" "Linting failed with $ERRORS error(s) in $FAILED_FILES file(s)"
        exit 1
    fi
}

# Main function
main() {
    echo "=== upKep Linting System ==="
    echo "Max lines per file: $MAX_LINES"
    echo ""
    
    check_dependencies
    echo ""
    
    # Find and lint files
    local files=()
    
    # Shell scripts
    for file in $(find . -name "*.sh" -type f 2>/dev/null | sort); do
        files+=("$file")
    done
    
    # YAML files
    for file in $(find . -name "*.yaml" -type f 2>/dev/null | sort); do
        files+=("$file")
    done
    
    for file in $(find . -name "*.yml" -type f 2>/dev/null | sort); do
        files+=("$file")
    done
    
    if [[ ${#files[@]} -eq 0 ]]; then
        print_status "INFO" "No files found to lint"
        exit 0
    fi
    
    print_status "INFO" "Found ${#files[@]} files to lint"
    echo ""
    
    # Lint each file
    for file in "${files[@]}"; do
        lint_file "$file"
    done
    
    print_summary
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "upKep Linting System"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --fix          Auto-fix some issues (trailing whitespace)"
        echo ""
        echo "Rules:"
        echo "  - Max 300 lines per file (except ignored files)"
        echo "  - ShellCheck style checks"
        echo "  - YAML validation"
        echo "  - No trailing whitespace"
        exit 0
        ;;
    --fix)
        echo "Auto-fixing issues..."
        find . -name "*.sh" -o -name "*.yaml" -o -name "*.yml" | xargs sed -i 's/[[:space:]]*$//'
        print_status "INFO" "Fixed trailing whitespace in all files"
        exit 0
        ;;
    "")
        main
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac 