#!/bin/bash

# upKep Basic Module Template
# Template for creating new upKep modules

# Module metadata
MODULE_NAME="{{MODULE_NAME}}"
MODULE_VERSION="{{MODULE_VERSION}}"
MODULE_DESCRIPTION="{{MODULE_DESCRIPTION}}"
MODULE_CATEGORY="{{MODULE_CATEGORY}}"

# Status variables (required)
{{MODULE_NAME_UPPER}}_STATUS=""
{{MODULE_NAME_UPPER}}_MESSAGE=""
{{MODULE_NAME_UPPER}}_ERROR=""

# Configuration
{{MODULE_NAME_UPPER}}_CONFIG_FILE="$HOME/.upkep/modules/{{MODULE_NAME}}.yaml"
{{MODULE_NAME_UPPER}}_LOG_FILE="$HOME/.upkep/logs/{{MODULE_NAME}}.log"

# Default settings
{{MODULE_NAME_UPPER}}_ENABLED=true
{{MODULE_NAME_UPPER}}_INTERVAL_DAYS=7
{{MODULE_NAME_UPPER}}_TIMEOUT=300

# Load configuration
load_{{MODULE_NAME}}_config() {
    if [[ -f "${{MODULE_NAME_UPPER}}_CONFIG_FILE" ]]; then
        # Load YAML configuration
        local enabled=$(grep "^enabled:" "${{MODULE_NAME_UPPER}}_CONFIG_FILE" | head -1 | sed 's/.*:[[:space:]]*//')
        local interval=$(grep "^interval_days:" "${{MODULE_NAME_UPPER}}_CONFIG_FILE" | head -1 | sed 's/.*:[[:space:]]*//')
        local timeout=$(grep "^timeout:" "${{MODULE_NAME_UPPER}}_CONFIG_FILE" | head -1 | sed 's/.*:[[:space:]]*//')

        if [[ -n "$enabled" ]]; then
            {{MODULE_NAME_UPPER}}_ENABLED="$enabled"
        fi
        if [[ -n "$interval" ]]; then
            {{MODULE_NAME_UPPER}}_INTERVAL_DAYS="$interval"
        fi
        if [[ -n "$timeout" ]]; then
            {{MODULE_NAME_UPPER}}_TIMEOUT="$timeout"
        fi
    fi
}

# Validate environment
validate_{{MODULE_NAME}}_environment() {
    # Check if module is enabled
    if [[ "${{MODULE_NAME_UPPER}}_ENABLED" != "true" ]]; then
        {{MODULE_NAME_UPPER}}_STATUS="skipped"
        {{MODULE_NAME_UPPER}}_MESSAGE="Module is disabled"
        return 0
    fi

    # Add your environment validation here
    # Example: Check if required commands exist
    # if ! command -v some_command >/dev/null 2>&1; then
    #     {{MODULE_NAME_UPPER}}_STATUS="failed"
    #     {{MODULE_NAME_UPPER}}_MESSAGE="Required command 'some_command' not found"
    #     return 1
    # fi

    # Example: Check if running as root (if needed)
    # if [[ $EUID -ne 0 ]]; then
    #     {{MODULE_NAME_UPPER}}_STATUS="failed"
    #     {{MODULE_NAME_UPPER}}_MESSAGE="This module requires root privileges"
    #     return 1
    # fi

    return 0
}

# Get module status
get_{{MODULE_NAME}}_status() {
    echo "Module: $MODULE_NAME"
    echo "Version: $MODULE_VERSION"
    echo "Description: $MODULE_DESCRIPTION"
    echo "Category: $MODULE_CATEGORY"
    echo "Status: ${{MODULE_NAME_UPPER}}_STATUS"
    echo "Message: ${{MODULE_NAME_UPPER}}_MESSAGE"
    if [[ -n "${{MODULE_NAME_UPPER}}_ERROR" ]]; then
        echo "Error: ${{MODULE_NAME_UPPER}}_ERROR"
    fi
    echo "Enabled: ${{MODULE_NAME_UPPER}}_ENABLED"
    echo "Interval: ${{MODULE_NAME_UPPER}}_INTERVAL_DAYS days"
    echo "Timeout: ${{MODULE_NAME_UPPER}}_TIMEOUT seconds"
}

# Update module state
update_{{MODULE_NAME}}_state() {
    local status="${{MODULE_NAME_UPPER}}_STATUS"
    local message="${{MODULE_NAME_UPPER}}_MESSAGE"
    local duration="${1:-0}"

    # Update state using the state management system
    if declare -f update_module_state >/dev/null; then
        update_module_state "$MODULE_NAME" "$status" "$message" "$duration"
    fi
}

# Log module activity
log_{{MODULE_NAME}}_activity() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Create log directory if it doesn't exist
    mkdir -p "$(dirname "${{MODULE_NAME_UPPER}}_LOG_FILE")"

    # Log to module-specific log file
    echo "[$timestamp] [$level] $message" >> "${{MODULE_NAME_UPPER}}_LOG_FILE"

    # Also log to main upKep log if available
    if declare -f log_message >/dev/null; then
        log_message "$level" "[$MODULE_NAME] $message"
    fi
}

# Main execution function (required)
run_{{MODULE_NAME}}() {
    local start_time=$(date +%s)

    # Load configuration
    load_{{MODULE_NAME}}_config

    # Validate environment
    if ! validate_{{MODULE_NAME}}_environment; then
        update_{{MODULE_NAME}}_state 0
        return 1
    fi

    # Log start
    log_{{MODULE_NAME}}_activity "INFO" "Starting {{MODULE_NAME}} module execution"

    # Initialize status
    {{MODULE_NAME_UPPER}}_STATUS="running"
    {{MODULE_NAME_UPPER}}_MESSAGE="Module execution started"

    # Add your module logic here
    # Example:
    # echo "Executing {{MODULE_NAME}} module..."
    #
    # # Your main logic
    # if some_operation; then
    #     {{MODULE_NAME_UPPER}}_STATUS="success"
    #     {{MODULE_NAME_UPPER}}_MESSAGE="Operation completed successfully"
    # else
    #     {{MODULE_NAME_UPPER}}_STATUS="failed"
    #     {{MODULE_NAME_UPPER}}_MESSAGE="Operation failed"
    #     {{MODULE_NAME_UPPER}}_ERROR="Error details here"
    # fi

    # Placeholder logic - replace with actual implementation
    echo "{{MODULE_NAME}} module placeholder - replace with actual implementation"
    {{MODULE_NAME_UPPER}}_STATUS="success"
    {{MODULE_NAME_UPPER}}_MESSAGE="Module executed successfully (placeholder)"

    # Calculate execution time
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Log completion
    log_{{MODULE_NAME}}_activity "INFO" "Module execution completed in ${duration}s"

    # Update state
    update_{{MODULE_NAME}}_state "$duration"

    # Return appropriate exit code
    if [[ "${{MODULE_NAME_UPPER}}_STATUS" == "success" ]]; then
        return 0
    elif [[ "${{MODULE_NAME_UPPER}}_STATUS" == "skipped" ]]; then
        return 0
    else
        return 1
    fi
}

# Show help information
show_{{MODULE_NAME}}_help() {
    echo "{{MODULE_NAME}} Module Help"
    echo "========================"
    echo ""
    echo "Description: $MODULE_DESCRIPTION"
    echo "Version: $MODULE_VERSION"
    echo "Category: $MODULE_CATEGORY"
    echo ""
    echo "Usage:"
    echo "  run_{{MODULE_NAME}}           - Execute the module"
    echo "  get_{{MODULE_NAME}}_status    - Show module status"
    echo "  validate_{{MODULE_NAME}}_environment - Validate environment"
    echo "  show_{{MODULE_NAME}}_help     - Show this help"
    echo ""
    echo "Configuration:"
    echo "  Config file: ${{MODULE_NAME_UPPER}}_CONFIG_FILE"
    echo "  Log file: ${{MODULE_NAME_UPPER}}_LOG_FILE"
    echo ""
    echo "Status Variables:"
    echo "  {{MODULE_NAME_UPPER}}_STATUS  - Current status (success/failed/skipped)"
    echo "  {{MODULE_NAME_UPPER}}_MESSAGE - Status message"
    echo "  {{MODULE_NAME_UPPER}}_ERROR   - Error details (if failed)"
}

# Handle command line arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        "run")
            run_{{MODULE_NAME}}
            ;;
        "status")
            get_{{MODULE_NAME}}_status
            ;;
        "validate")
            validate_{{MODULE_NAME}}_environment
            ;;
        "help"|"--help"|"-h")
            show_{{MODULE_NAME}}_help
            ;;
        *)
            echo "Usage: $0 {run|status|validate|help}"
            exit 1
            ;;
    esac
fi