#!/bin/bash

# upKep Advanced Module Template
# Template for creating advanced upKep modules with comprehensive features

# Module metadata
MODULE_NAME="{{MODULE_NAME}}"
MODULE_VERSION="{{MODULE_VERSION}}"
MODULE_DESCRIPTION="{{MODULE_DESCRIPTION}}"
MODULE_CATEGORY="{{MODULE_CATEGORY}}"
MODULE_AUTHOR="{{MODULE_AUTHOR}}"
MODULE_LICENSE="{{MODULE_LICENSE}}"

# Status variables (required)
{{MODULE_NAME_UPPER}}_STATUS=""
{{MODULE_NAME_UPPER}}_MESSAGE=""
{{MODULE_NAME_UPPER}}_ERROR=""

# Configuration
{{MODULE_NAME_UPPER}}_CONFIG_FILE="$HOME/.upkep/modules/{{MODULE_NAME}}.yaml"
{{MODULE_NAME_UPPER}}_LOG_FILE="$HOME/.upkep/logs/{{MODULE_NAME}}.log"
{{MODULE_NAME_UPPER}}_CACHE_FILE="$HOME/.upkep/cache/{{MODULE_NAME}}.cache"

# Default settings
{{MODULE_NAME_UPPER}}_ENABLED=true
{{MODULE_NAME_UPPER}}_INTERVAL_DAYS=7
{{MODULE_NAME_UPPER}}_TIMEOUT=300
{{MODULE_NAME_UPPER}}_PARALLEL=false
{{MODULE_NAME_UPPER}}_VERBOSE=false
{{MODULE_NAME_UPPER}}_DRY_RUN=false

# Module-specific variables
{{MODULE_NAME_UPPER}}_REQUIRED_COMMANDS=("{{REQUIRED_COMMANDS}}")
{{MODULE_NAME_UPPER}}_REQUIRED_PERMISSIONS=("{{REQUIRED_PERMISSIONS}}")
{{MODULE_NAME_UPPER}}_SUPPORTED_PLATFORMS=("{{SUPPORTED_PLATFORMS}}")

# Performance tracking
{{MODULE_NAME_UPPER}}_START_TIME=0
{{MODULE_NAME_UPPER}}_END_TIME=0
{{MODULE_NAME_UPPER}}_DURATION=0

# Load configuration with validation
load_{{MODULE_NAME}}_config() {
    if [[ -f "${{MODULE_NAME_UPPER}}_CONFIG_FILE" ]]; then
        # Validate YAML syntax if yamllint is available
        if command -v yamllint >/dev/null 2>&1; then
            if ! yamllint "${{MODULE_NAME_UPPER}}_CONFIG_FILE" >/dev/null 2>&1; then
                log_{{MODULE_NAME}}_activity "ERROR" "Invalid YAML syntax in config file"
                return 1
            fi
        fi
        
        # Load configuration values
        local enabled=$(grep "^enabled:" "${{MODULE_NAME_UPPER}}_CONFIG_FILE" | head -1 | sed 's/.*:[[:space:]]*//')
        local interval=$(grep "^interval_days:" "${{MODULE_NAME_UPPER}}_CONFIG_FILE" | head -1 | sed 's/.*:[[:space:]]*//')
        local timeout=$(grep "^timeout:" "${{MODULE_NAME_UPPER}}_CONFIG_FILE" | head -1 | sed 's/.*:[[:space:]]*//')
        local parallel=$(grep "^parallel:" "${{MODULE_NAME_UPPER}}_CONFIG_FILE" | head -1 | sed 's/.*:[[:space:]]*//')
        local verbose=$(grep "^verbose:" "${{MODULE_NAME_UPPER}}_CONFIG_FILE" | head -1 | sed 's/.*:[[:space:]]*//')
        
        # Apply configuration with validation
        if [[ -n "$enabled" ]]; then
            if [[ "$enabled" =~ ^(true|false)$ ]]; then
                {{MODULE_NAME_UPPER}}_ENABLED="$enabled"
            else
                log_{{MODULE_NAME}}_activity "WARN" "Invalid enabled value: $enabled, using default"
            fi
        fi
        
        if [[ -n "$interval" ]]; then
            if [[ "$interval" =~ ^[0-9]+$ ]] && [[ $interval -ge 1 ]] && [[ $interval -le 365 ]]; then
                {{MODULE_NAME_UPPER}}_INTERVAL_DAYS="$interval"
            else
                log_{{MODULE_NAME}}_activity "WARN" "Invalid interval value: $interval, using default"
            fi
        fi
        
        if [[ -n "$timeout" ]]; then
            if [[ "$timeout" =~ ^[0-9]+$ ]] && [[ $timeout -ge 1 ]] && [[ $timeout -le 3600 ]]; then
                {{MODULE_NAME_UPPER}}_TIMEOUT="$timeout"
            else
                log_{{MODULE_NAME}}_activity "WARN" "Invalid timeout value: $timeout, using default"
            fi
        fi
        
        if [[ -n "$parallel" ]]; then
            if [[ "$parallel" =~ ^(true|false)$ ]]; then
                {{MODULE_NAME_UPPER}}_PARALLEL="$parallel"
            else
                log_{{MODULE_NAME}}_activity "WARN" "Invalid parallel value: $parallel, using default"
            fi
        fi
        
        if [[ -n "$verbose" ]]; then
            if [[ "$verbose" =~ ^(true|false)$ ]]; then
                {{MODULE_NAME_UPPER}}_VERBOSE="$verbose"
            else
                log_{{MODULE_NAME}}_activity "WARN" "Invalid verbose value: $verbose, using default"
            fi
        fi
        
        log_{{MODULE_NAME}}_activity "INFO" "Configuration loaded from ${{MODULE_NAME_UPPER}}_CONFIG_FILE"
    else
        log_{{MODULE_NAME}}_activity "INFO" "No configuration file found, using defaults"
    fi
}

# Validate environment comprehensively
validate_{{MODULE_NAME}}_environment() {
    # Check if module is enabled
    if [[ "${{MODULE_NAME_UPPER}}_ENABLED" != "true" ]]; then
        {{MODULE_NAME_UPPER}}_STATUS="skipped"
        {{MODULE_NAME_UPPER}}_MESSAGE="Module is disabled"
        return 0
    fi
    
    # Check platform compatibility
    local current_platform=$(uname -s | tr '[:upper:]' '[:lower:]')
    local platform_supported=false
    
    for platform in "${{{MODULE_NAME_UPPER}}_SUPPORTED_PLATFORMS[@]}"; do
        if [[ "$platform" == "$current_platform" ]]; then
            platform_supported=true
            break
        fi
    done
    
    if [[ "$platform_supported" == "false" ]]; then
        {{MODULE_NAME_UPPER}}_STATUS="failed"
        {{MODULE_NAME_UPPER}}_MESSAGE="Platform $current_platform not supported"
        {{MODULE_NAME_UPPER}}_ERROR="Supported platforms: ${{{MODULE_NAME_UPPER}}_SUPPORTED_PLATFORMS[*]}"
        return 1
    fi
    
    # Check required commands
    for cmd in "${{{MODULE_NAME_UPPER}}_REQUIRED_COMMANDS[@]}"; do
        if [[ -n "$cmd" ]] && ! command -v "$cmd" >/dev/null 2>&1; then
            {{MODULE_NAME_UPPER}}_STATUS="failed"
            {{MODULE_NAME_UPPER}}_MESSAGE="Required command '$cmd' not found"
            {{MODULE_NAME_UPPER}}_ERROR="Install $cmd to use this module"
            return 1
        fi
    done
    
    # Check required permissions
    for permission in "${{{MODULE_NAME_UPPER}}_REQUIRED_PERMISSIONS[@]}"; do
        case "$permission" in
            "sudo")
                if ! sudo -n true 2>/dev/null; then
                    {{MODULE_NAME_UPPER}}_STATUS="failed"
                    {{MODULE_NAME_UPPER}}_MESSAGE="Sudo privileges required"
                    {{MODULE_NAME_UPPER}}_ERROR="Run with sudo or configure sudoers"
                    return 1
                fi
                ;;
            "root")
                if [[ $EUID -ne 0 ]]; then
                    {{MODULE_NAME_UPPER}}_STATUS="failed"
                    {{MODULE_NAME_UPPER}}_MESSAGE="Root privileges required"
                    {{MODULE_NAME_UPPER}}_ERROR="Run as root or with sudo"
                    return 1
                fi
                ;;
            "network")
                if ! check_internet 5; then
                    {{MODULE_NAME_UPPER}}_STATUS="failed"
                    {{MODULE_NAME_UPPER}}_MESSAGE="Network connectivity required"
                    {{MODULE_NAME_UPPER}}_ERROR="Check internet connection"
                    return 1
                fi
                ;;
            "file_system")
                if [[ ! -w "$HOME/.upkep" ]]; then
                    {{MODULE_NAME_UPPER}}_STATUS="failed"
                    {{MODULE_NAME_UPPER}}_MESSAGE="File system write access required"
                    {{MODULE_NAME_UPPER}}_ERROR="Check permissions for ~/.upkep"
                    return 1
                fi
                ;;
        esac
    done
    
    # Create required directories
    mkdir -p "$(dirname "${{MODULE_NAME_UPPER}}_LOG_FILE")"
    mkdir -p "$(dirname "${{MODULE_NAME_UPPER}}_CACHE_FILE")"
    
    return 0
}

# Get comprehensive module status
get_{{MODULE_NAME}}_status() {
    echo "Module Information"
    echo "=================="
    echo "Name: $MODULE_NAME"
    echo "Version: $MODULE_VERSION"
    echo "Description: $MODULE_DESCRIPTION"
    echo "Category: $MODULE_CATEGORY"
    echo "Author: $MODULE_AUTHOR"
    echo "License: $MODULE_LICENSE"
    echo ""
    echo "Current Status"
    echo "=============="
    echo "Status: ${{MODULE_NAME_UPPER}}_STATUS"
    echo "Message: ${{MODULE_NAME_UPPER}}_MESSAGE"
    if [[ -n "${{MODULE_NAME_UPPER}}_ERROR" ]]; then
        echo "Error: ${{MODULE_NAME_UPPER}}_ERROR"
    fi
    echo ""
    echo "Configuration"
    echo "============="
    echo "Enabled: ${{MODULE_NAME_UPPER}}_ENABLED"
    echo "Interval: ${{MODULE_NAME_UPPER}}_INTERVAL_DAYS days"
    echo "Timeout: ${{MODULE_NAME_UPPER}}_TIMEOUT seconds"
    echo "Parallel: ${{MODULE_NAME_UPPER}}_PARALLEL"
    echo "Verbose: ${{MODULE_NAME_UPPER}}_VERBOSE"
    echo "Config File: ${{MODULE_NAME_UPPER}}_CONFIG_FILE"
    echo "Log File: ${{MODULE_NAME_UPPER}}_LOG_FILE"
    echo "Cache File: ${{MODULE_NAME_UPPER}}_CACHE_FILE"
    echo ""
    echo "Requirements"
    echo "============"
    echo "Required Commands: ${{{MODULE_NAME_UPPER}}_REQUIRED_COMMANDS[*]}"
    echo "Required Permissions: ${{{MODULE_NAME_UPPER}}_REQUIRED_PERMISSIONS[*]}"
    echo "Supported Platforms: ${{{MODULE_NAME_UPPER}}_SUPPORTED_PLATFORMS[*]}"
    echo ""
    echo "Performance"
    echo "==========="
    echo "Last Duration: ${{{MODULE_NAME_UPPER}}_DURATION}s"
    
    # Show cache information if available
    if [[ -f "${{MODULE_NAME_UPPER}}_CACHE_FILE" ]]; then
        local cache_age=$(($(date +%s) - $(stat -c %Y "${{MODULE_NAME_UPPER}}_CACHE_FILE")))
        echo "Cache Age: ${cache_age}s"
    fi
}

# Update module state with performance tracking
update_{{MODULE_NAME}}_state() {
    local status="${{MODULE_NAME_UPPER}}_STATUS"
    local message="${{MODULE_NAME_UPPER}}_MESSAGE"
    local duration="${1:-0}"
    
    # Update performance tracking
    {{MODULE_NAME_UPPER}}_DURATION="$duration"
    
    # Update state using the state management system
    if declare -f update_module_state >/dev/null; then
        update_module_state "$MODULE_NAME" "$status" "$message" "$duration"
    fi
    
    # Cache results if successful
    if [[ "$status" == "success" ]]; then
        cache_{{MODULE_NAME}}_results
    fi
}

# Cache module results
cache_{{MODULE_NAME}}_results() {
    local cache_data="{
        \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
        \"status\": \"${{MODULE_NAME_UPPER}}_STATUS\",
        \"message\": \"${{MODULE_NAME_UPPER}}_MESSAGE\",
        \"duration\": ${{MODULE_NAME_UPPER}}_DURATION
    }"
    
    echo "$cache_data" > "${{MODULE_NAME_UPPER}}_CACHE_FILE"
    log_{{MODULE_NAME}}_activity "INFO" "Results cached to ${{MODULE_NAME_UPPER}}_CACHE_FILE"
}

# Load cached results
load_{{MODULE_NAME}}_cache() {
    if [[ -f "${{MODULE_NAME_UPPER}}_CACHE_FILE" ]]; then
        if command -v jq >/dev/null 2>&1; then
            local cached_status=$(jq -r '.status' "${{MODULE_NAME_UPPER}}_CACHE_FILE" 2>/dev/null)
            local cached_message=$(jq -r '.message' "${{MODULE_NAME_UPPER}}_CACHE_FILE" 2>/dev/null)
            local cached_duration=$(jq -r '.duration' "${{MODULE_NAME_UPPER}}_CACHE_FILE" 2>/dev/null)
            
            if [[ -n "$cached_status" ]] && [[ "$cached_status" != "null" ]]; then
                {{MODULE_NAME_UPPER}}_STATUS="$cached_status"
                {{MODULE_NAME_UPPER}}_MESSAGE="$cached_message"
                {{MODULE_NAME_UPPER}}_DURATION="$cached_duration"
                return 0
            fi
        fi
    fi
    return 1
}

# Enhanced logging with levels and formatting
log_{{MODULE_NAME}}_activity() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Create log directory if it doesn't exist
    mkdir -p "$(dirname "${{MODULE_NAME_UPPER}}_LOG_FILE")"
    
    # Format log entry
    local log_entry="[$timestamp] [$level] [$MODULE_NAME] $message"
    
    # Log to module-specific log file
    echo "$log_entry" >> "${{MODULE_NAME_UPPER}}_LOG_FILE"
    
    # Also log to main upKep log if available
    if declare -f log_message >/dev/null; then
        log_message "$level" "$message"
    fi
    
    # Print to console if verbose mode is enabled
    if [[ "${{MODULE_NAME_UPPER}}_VERBOSE" == "true" ]]; then
        case "$level" in
            "ERROR") print_error "$message" ;;
            "WARN") print_warning "$message" ;;
            "SUCCESS") print_success "$message" ;;
            "INFO") print_info "$message" ;;
            *) echo "$message" ;;
        esac
    fi
}

# Check if module should run based on interval
should_run_{{MODULE_NAME}}() {
    # Check if we have cached results
    if load_{{MODULE_NAME}}_cache; then
        local cache_age=$(($(date +%s) - $(stat -c %Y "${{MODULE_NAME_UPPER}}_CACHE_FILE")))
        local interval_seconds=$(({{MODULE_NAME_UPPER}}_INTERVAL_DAYS * 24 * 60 * 60))
        
        if [[ $cache_age -lt $interval_seconds ]]; then
            {{MODULE_NAME_UPPER}}_STATUS="skipped"
            {{MODULE_NAME_UPPER}}_MESSAGE="Module executed recently (${cache_age}s ago)"
            return 0
        fi
    fi
    
    return 1
}

# Main execution function with comprehensive features
run_{{MODULE_NAME}}() {
    {{MODULE_NAME_UPPER}}_START_TIME=$(date +%s)
    
    # Load configuration
    if ! load_{{MODULE_NAME}}_config; then
        {{MODULE_NAME_UPPER}}_STATUS="failed"
        {{MODULE_NAME_UPPER}}_MESSAGE="Failed to load configuration"
        update_{{MODULE_NAME}}_state 0
        return 1
    fi
    
    # Validate environment
    if ! validate_{{MODULE_NAME}}_environment; then
        update_{{MODULE_NAME}}_state 0
        return 1
    fi
    
    # Check if module should run
    if should_run_{{MODULE_NAME}}; then
        update_{{MODULE_NAME}}_state 0
        return 0
    fi
    
    # Log start
    log_{{MODULE_NAME}}_activity "INFO" "Starting {{MODULE_NAME}} module execution"
    
    # Initialize status
    {{MODULE_NAME_UPPER}}_STATUS="running"
    {{MODULE_NAME_UPPER}}_MESSAGE="Module execution started"
    
    # Set up timeout if specified
    if [[ ${{MODULE_NAME_UPPER}}_TIMEOUT -gt 0 ]]; then
        # Start timeout monitoring in background
        (
            sleep ${{MODULE_NAME_UPPER}}_TIMEOUT
            if [[ "${{MODULE_NAME_UPPER}}_STATUS" == "running" ]]; then
                {{MODULE_NAME_UPPER}}_STATUS="failed"
                {{MODULE_NAME_UPPER}}_MESSAGE="Module execution timed out"
                {{MODULE_NAME_UPPER}}_ERROR="Timeout after ${{{MODULE_NAME_UPPER}}_TIMEOUT}s"
                log_{{MODULE_NAME}}_activity "ERROR" "Module execution timed out"
            fi
        ) &
        local timeout_pid=$!
    fi
    
    # Add your module logic here
    # Example:
    # echo "Executing {{MODULE_NAME}} module..."
    # 
    # # Your main logic with error handling
    # if some_operation; then
    #     {{MODULE_NAME_UPPER}}_STATUS="success"
    #     {{MODULE_NAME_UPPER}}_MESSAGE="Operation completed successfully"
    # else
    #     {{MODULE_NAME_UPPER}}_STATUS="failed"
    #     {{MODULE_NAME_UPPER}}_MESSAGE="Operation failed"
    #     {{MODULE_NAME_UPPER}}_ERROR="Error details here"
    # fi
    
    # Placeholder logic - replace with actual implementation
    echo "{{MODULE_NAME}} advanced module placeholder - replace with actual implementation"
    {{MODULE_NAME_UPPER}}_STATUS="success"
    {{MODULE_NAME_UPPER}}_MESSAGE="Module executed successfully (placeholder)"
    
    # Kill timeout process if it's still running
    if [[ -n "$timeout_pid" ]] && kill -0 "$timeout_pid" 2>/dev/null; then
        kill "$timeout_pid" 2>/dev/null
    fi
    
    # Calculate execution time
    {{MODULE_NAME_UPPER}}_END_TIME=$(date +%s)
    {{MODULE_NAME_UPPER}}_DURATION=$(({{MODULE_NAME_UPPER}}_END_TIME - {{MODULE_NAME_UPPER}}_START_TIME))
    
    # Log completion
    log_{{MODULE_NAME}}_activity "INFO" "Module execution completed in ${{{MODULE_NAME_UPPER}}_DURATION}s"
    
    # Update state
    update_{{MODULE_NAME}}_state "${{MODULE_NAME_UPPER}}_DURATION"
    
    # Return appropriate exit code
    if [[ "${{MODULE_NAME_UPPER}}_STATUS" == "success" ]]; then
        return 0
    elif [[ "${{MODULE_NAME_UPPER}}_STATUS" == "skipped" ]]; then
        return 0
    else
        return 1
    fi
}

# Show comprehensive help information
show_{{MODULE_NAME}}_help() {
    echo "{{MODULE_NAME}} Advanced Module Help"
    echo "=================================="
    echo ""
    echo "Description: $MODULE_DESCRIPTION"
    echo "Version: $MODULE_VERSION"
    echo "Category: $MODULE_CATEGORY"
    echo "Author: $MODULE_AUTHOR"
    echo "License: $MODULE_LICENSE"
    echo ""
    echo "Usage:"
    echo "  run_{{MODULE_NAME}}           - Execute the module"
    echo "  get_{{MODULE_NAME}}_status    - Show comprehensive module status"
    echo "  validate_{{MODULE_NAME}}_environment - Validate environment"
    echo "  show_{{MODULE_NAME}}_help     - Show this help"
    echo ""
    echo "Configuration:"
    echo "  Config file: ${{MODULE_NAME_UPPER}}_CONFIG_FILE"
    echo "  Log file: ${{MODULE_NAME_UPPER}}_LOG_FILE"
    echo "  Cache file: ${{MODULE_NAME_UPPER}}_CACHE_FILE"
    echo ""
    echo "Status Variables:"
    echo "  {{MODULE_NAME_UPPER}}_STATUS  - Current status (success/failed/skipped/running)"
    echo "  {{MODULE_NAME_UPPER}}_MESSAGE - Status message"
    echo "  {{MODULE_NAME_UPPER}}_ERROR   - Error details (if failed)"
    echo "  {{MODULE_NAME_UPPER}}_DURATION - Execution duration in seconds"
    echo ""
    echo "Features:"
    echo "  - Comprehensive environment validation"
    echo "  - Performance tracking and caching"
    echo "  - Timeout protection"
    echo "  - Platform compatibility checking"
    echo "  - Permission validation"
    echo "  - Enhanced logging with levels"
    echo "  - Configuration validation"
    echo "  - Interval-based execution control"
    echo ""
    echo "Configuration Options:"
    echo "  enabled: true/false          - Enable/disable module"
    echo "  interval_days: 1-365         - Execution interval in days"
    echo "  timeout: 1-3600              - Execution timeout in seconds"
    echo "  parallel: true/false         - Allow parallel execution"
    echo "  verbose: true/false          - Enable verbose output"
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