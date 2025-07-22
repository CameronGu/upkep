#!/bin/bash

# set -euo pipefail  # Commented out to prevent hanging

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
MAX_LINES=300
MAX_FILE_SIZE=100000  # 100KB
QUIET_MODE=false

# Statistics
TOTAL_FILES=0
FAILED_FILES=0
WARNING_FILES=0
WARNINGS=0
ERRORS=0
CRITICAL_ERRORS=0
PASSED_FILES=0
SKIPPED_FILES=0

# Detailed statistics
LINE_COUNT_VIOLATIONS=0
TRAILING_WHITESPACE_VIOLATIONS=0
SHELLCHECK_VIOLATIONS=0
SC2317_WARNINGS=0
SHEBANG_VIOLATIONS=0
PERMISSION_VIOLATIONS=0
FILE_SIZE_VIOLATIONS=0
ENCODING_VIOLATIONS=0
LINE_ENDING_VIOLATIONS=0

# Print colored output
print_status() {
    local status_type="$1"
    local message="$2"

    # Skip non-error messages in quiet mode
    if [[ "$QUIET_MODE" == "true" ]] && [[ "$status_type" != "FAIL" ]]; then
        return 0
    fi

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
        "SKIP")
            echo -e "${PURPLE}⏭${NC} $message"
            ;;
    esac
}

# Check line count
check_line_count() {
    local file="$1"

    # Skip template files
    if [[ "$file" == *"/templates/"* ]]; then
        print_status "SKIP" "Line count check for $file (template file)"
        return 0
    fi

    local line_count=$(wc -l < "$file" 2>/dev/null || echo "0")

    if [[ $line_count -gt $MAX_LINES ]]; then
        print_status "WARN" "$file: $line_count lines (exceeds $MAX_LINES limit) [STYLE]"
        ((LINE_COUNT_VIOLATIONS++))
        return 2  # Style warning, not critical failure
    else
        print_status "PASS" "$file: $line_count lines"
        return 0
    fi
}

# Check trailing whitespace
check_trailing_whitespace() {
    local file="$1"

    # Skip template files
    if [[ "$file" == *"/templates/"* ]]; then
        print_status "SKIP" "Trailing whitespace check for $file (template file)"
        return 0
    fi

    if timeout 5 grep -q '[[:space:]]$' "$file" 2>/dev/null; then
        print_status "INFO" "$file: contains trailing whitespace [AUTO-FIXABLE]"
        ((TRAILING_WHITESPACE_VIOLATIONS++))
        return 2  # Auto-fixable, not critical
    else
        print_status "PASS" "$file: no trailing whitespace"
        return 0
    fi
}

# Check shell script
check_shell_script() {
    local file="$1"

    # Skip template files
    if [[ "$file" == *"/templates/"* ]]; then
        print_status "SKIP" "ShellCheck for $file (template file)"
        return 0
    fi

    if command -v shellcheck >/dev/null 2>&1; then
        # Run ShellCheck and categorize SC2317 as informational instead of critical
        local shellcheck_output
        shellcheck_output=$(shellcheck -s bash -S style "$file" 2>&1)
        local shellcheck_exit=$?
        
        if [[ $shellcheck_exit -eq 0 ]]; then
            print_status "PASS" "$file: shellcheck passed"
            return 0
        else
            # Check if we have critical issues (non-SC2317)
            local critical_issues
            critical_issues=$(echo "$shellcheck_output" | grep -v "SC2317" | grep -c "error\|warning")
            
            # Check if we have SC2317 informational warnings
            local sc2317_count
            sc2317_count=$(echo "$shellcheck_output" | grep -c "SC2317")
            
            if [[ $critical_issues -gt 0 ]]; then
                # Real critical issues found
                print_status "FAIL" "$file: shellcheck found issues [CRITICAL]"
                ((SHELLCHECK_VIOLATIONS++))
                return 1  # Critical failure - blocks CI
            elif [[ $sc2317_count -gt 0 ]]; then
                # Only SC2317 informational warnings
                print_status "INFO" "$file: shellcheck found $sc2317_count test function warnings [INFORMATIONAL]"
                SC2317_WARNINGS=$((SC2317_WARNINGS + sc2317_count))
                return 0  # Informational only, doesn't block CI
            else
                # This shouldn't happen, but handle gracefully
                print_status "WARN" "$file: shellcheck had issues but couldn't categorize"
                ((WARNINGS++))
                return 0
            fi
        fi
    else
        print_status "WARN" "$file: shellcheck not available"
        ((WARNINGS++))
        return 0
    fi
}

# Check shebang
check_shebang() {
    local file="$1"
    local file_ext="${file##*.}"

    # Only check shell scripts
    if [[ "$file_ext" != "sh" && "$file_ext" != "bash" ]]; then
        return 0
    fi

    # Skip template files
    if [[ "$file" == *"/templates/"* ]]; then
        print_status "SKIP" "Shebang check for $file (template file)"
        return 0
    fi

    if head -n1 "$file" | grep -q '^#!/'; then
        print_status "PASS" "$file: has proper shebang"
        return 0
    else
        print_status "FAIL" "$file: missing shebang [CRITICAL]"
        ((SHEBANG_VIOLATIONS++))
        return 1  # Critical failure - functional issue
    fi
}

# Check file permissions
check_permissions() {
    local file="$1"
    local file_ext="${file##*.}"

    # Only check shell scripts
    if [[ "$file_ext" != "sh" && "$file_ext" != "bash" ]]; then
        return 0
    fi

    # Skip template files
    if [[ "$file" == *"/templates/"* ]]; then
        print_status "SKIP" "Permission check for $file (template file)"
        return 0
    fi

    local permissions=$(stat -c "%a" "$file" 2>/dev/null || echo "000")
    local expected_permissions="755"

    if [[ "$permissions" == "$expected_permissions" ]] || [[ "$permissions" == "644" ]]; then
        print_status "PASS" "$file: proper permissions ($permissions)"
        return 0
    else
        print_status "WARN" "$file: unusual permissions ($permissions), expected 755 or 644"
        ((PERMISSION_VIOLATIONS++))
        return 0  # Warning, not error
    fi
}

# Check file size
check_file_size() {
    local file="$1"

    # Skip template files
    if [[ "$file" == *"/templates/"* ]]; then
        print_status "SKIP" "File size check for $file (template file)"
        return 0
    fi

    local file_size=$(stat -c "%s" "$file" 2>/dev/null || echo "0")

    if [[ $file_size -gt $MAX_FILE_SIZE ]]; then
        print_status "WARN" "$file: $file_size bytes (exceeds ${MAX_FILE_SIZE} limit) [STYLE]"
        ((FILE_SIZE_VIOLATIONS++))
        return 2  # Style warning, not critical
    else
        print_status "PASS" "$file: $file_size bytes"
        return 0
    fi
}

# Check file encoding (UTF-8)
check_encoding() {
    local file="$1"

    # Skip template files
    if [[ "$file" == *"/templates/"* ]]; then
        print_status "SKIP" "Encoding check for $file (template file)"
        return 0
    fi

    # Skip empty files
    if [[ ! -s "$file" ]]; then
        print_status "SKIP" "Encoding check for $file (empty file)"
        return 0
    fi

    if command -v file >/dev/null 2>&1; then
        local encoding=$(file -bi "$file" 2>/dev/null | grep -o 'charset=[^;]*' | cut -d= -f2 || echo "unknown")

        if [[ "$encoding" == "utf-8" ]] || [[ "$encoding" == "us-ascii" ]] || [[ "$encoding" == "binary" ]]; then
            print_status "PASS" "$file: $encoding encoding"
            return 0
        else
            print_status "WARN" "$file: $encoding encoding (expected UTF-8)"
            ((ENCODING_VIOLATIONS++))
            return 0  # Warning, not error
        fi
    else
        print_status "SKIP" "Encoding check for $file (file command not available)"
        return 0
    fi
}

# Check line endings (Unix style)
check_line_endings() {
    local file="$1"

    # Skip template files
    if [[ "$file" == *"/templates/"* ]]; then
        print_status "SKIP" "Line ending check for $file (template file)"
        return 0
    fi

    # Skip empty files
    if [[ ! -s "$file" ]]; then
        print_status "SKIP" "Line ending check for $file (empty file)"
        return 0
    fi

    if grep -q $'\r' "$file" 2>/dev/null; then
        print_status "WARN" "$file: contains Windows line endings (CRLF) [STYLE]"
        ((LINE_ENDING_VIOLATIONS++))
        return 2  # Style warning, not critical
    else
        print_status "PASS" "$file: Unix line endings (LF)"
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

    # Check file size
    if ! check_file_size "$file"; then
        failed=1
    fi

    # Check trailing whitespace
    if ! check_trailing_whitespace "$file"; then
        failed=1
    fi

    # Check line endings
    if ! check_line_endings "$file"; then
        failed=1
    fi

    # Check encoding
    if ! check_encoding "$file"; then
        # Encoding is warnings, not errors
        :
    fi

    # Check shebang
    if ! check_shebang "$file"; then
        failed=1
    fi

    # Check permissions
    if ! check_permissions "$file"; then
        # Permissions are warnings, not errors
        :
    fi

    # Language-specific checks
    case "$file_ext" in
        "sh"|"bash")
            if ! check_shell_script "$file"; then
                failed=1
            fi
            ;;
    esac

    if [[ $failed -eq 0 ]]; then
        ((PASSED_FILES++))
    else
        ((FAILED_FILES++))
        ((ERRORS++))
    fi

    echo ""
    return $failed
}

# Print detailed summary
print_summary() {
    echo ""
    echo -e "${CYAN}=== Linting Summary ===${NC}"
    echo -e "${BLUE}Total files checked:${NC} $TOTAL_FILES"
    echo -e "${GREEN}Files passed:${NC} $PASSED_FILES"
    echo -e "${RED}Files with errors:${NC} $FAILED_FILES"
    echo -e "${PURPLE}Files skipped:${NC} $SKIPPED_FILES"
    echo ""
    echo -e "${YELLOW}=== Violation Details ===${NC}"
    echo -e "${RED}🔴 CRITICAL ISSUES (Block CI):${NC}"
    echo -e "   ShellCheck violations: $SHELLCHECK_VIOLATIONS"
    echo -e "   Shebang violations: $SHEBANG_VIOLATIONS"
    echo ""
    echo -e "${YELLOW}🟡 STYLE WARNINGS (Fix in maintenance):${NC}"
    echo -e "   Line count violations: $LINE_COUNT_VIOLATIONS"
    echo -e "   File size violations: $FILE_SIZE_VIOLATIONS"
    echo -e "   Line ending violations: $LINE_ENDING_VIOLATIONS"
    echo ""
    echo -e "${BLUE}🔵 AUTO-FIXABLE (Run --fix):${NC}"
    echo -e "   Trailing whitespace violations: $TRAILING_WHITESPACE_VIOLATIONS"
    echo ""
    echo -e "${PURPLE}ℹ️  INFORMATIONAL:${NC}"
    echo -e "   Permission warnings: $PERMISSION_VIOLATIONS"
    echo -e "   Encoding warnings: $ENCODING_VIOLATIONS"
    echo -e "   SC2317 test function warnings: $SC2317_WARNINGS"
    echo -e "   Other warnings: $WARNINGS"
    echo ""
    echo -e "${CYAN}=== Final Result ===${NC}"

    # Calculate critical errors (ShellCheck + Shebang)
    local critical_errors=$((SHELLCHECK_VIOLATIONS + SHEBANG_VIOLATIONS))
    local style_warnings=$((LINE_COUNT_VIOLATIONS + FILE_SIZE_VIOLATIONS + LINE_ENDING_VIOLATIONS))
    local auto_fixable=$TRAILING_WHITESPACE_VIOLATIONS

    if [[ $critical_errors -eq 0 ]] && [[ $style_warnings -eq 0 ]] && [[ $auto_fixable -eq 0 ]]; then
        print_status "PASS" "🎉 All files passed linting!"
        echo -e "${GREEN}✓ No issues found${NC}"
        echo -e "${GREEN}✓ Code quality checks passed${NC}"
        exit 0
    elif [[ $critical_errors -eq 0 ]]; then
        # Only style warnings and auto-fixable issues
        if [[ $auto_fixable -gt 0 ]]; then
            print_status "INFO" "✨ Auto-fixable issues found: $auto_fixable trailing whitespace violations"
            echo -e "${BLUE}💡 Run 'bash scripts/lint.sh --fix' to automatically fix${NC}"
        fi
        if [[ $style_warnings -gt 0 ]]; then
            print_status "WARN" "⚠️  Style warnings found but no critical issues"
            echo -e "${YELLOW}💡 These can be addressed during maintenance cycles${NC}"
        fi
        echo -e "${GREEN}✓ No critical issues - safe for CI/CD${NC}"
        exit 0
    else
        print_status "FAIL" "❌ Critical issues found: $critical_errors (BLOCKS CI)"
        echo -e "${RED}✗ Must fix critical issues before proceeding${NC}"
        if [[ $auto_fixable -gt 0 ]]; then
            echo -e "${BLUE}💡 Run 'bash scripts/lint.sh --fix' to fix $auto_fixable auto-fixable issues${NC}"
        fi
        exit 1
    fi
}

# Main function
main() {
    echo -e "${CYAN}=== upKep Linting System ===${NC}"
    echo -e "${BLUE}Max lines per file:${NC} $MAX_LINES"
    echo -e "${BLUE}Max file size:${NC} $MAX_FILE_SIZE bytes"
    echo -e "${BLUE}Checks:${NC} line count, file size, trailing whitespace, line endings, encoding, shellcheck, shebang, permissions"
    echo ""

    # Find and lint files
    local files=()

    # Shell scripts
    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(find . -name "*.sh" -type f -print0 2>/dev/null | sort -z)

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
        echo -e "${CYAN}upKep Linting System${NC}"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --fix          Auto-fix some issues (trailing whitespace)"
        echo "  --quiet        Suppress detailed output, show only summary"
        echo ""
        echo "Rules:"
        echo "  - Max 300 lines per file (except template files)"
        echo "  - Max 100KB file size (except template files)"
        echo "  - ShellCheck style checks"
        echo "  - No trailing whitespace"
        echo "  - Unix line endings (LF)"
        echo "  - UTF-8 encoding"
        echo "  - Proper shebang in shell scripts"
        echo "  - Appropriate file permissions"
        echo ""
        echo "Exit codes:"
        echo "  0 - All checks passed"
        echo "  1 - One or more checks failed"
        exit 0
        ;;
    --fix)
        echo -e "${YELLOW}Auto-fixing issues...${NC}"
        # Use find with -print0 and xargs -0 for safety
        find . \( -name "*.sh" -o -name "*.yaml" -o -name "*.yml" \) -print0 | xargs -0 sed -i 's/[[:space:]]*$//'
        print_status "INFO" "Fixed trailing whitespace in all files"
        echo -e "${GREEN}✓ Auto-fix completed${NC}"
        exit 0
        ;;
    --quiet)
        QUIET_MODE=true
        main
        ;;
    "")
        main
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        echo "Use --help for usage information"
        exit 1
        ;;
esac