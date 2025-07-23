#!/bin/bash
# config.sh - Configuration management for upKep (simplified)

# Source the simplified configuration system
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/config_simple.sh" ]]; then
    source "$SCRIPT_DIR/config_simple.sh"
else
    echo "Error: Simplified configuration module not found: $SCRIPT_DIR/config_simple.sh"
    exit 1
fi

# Legacy compatibility functions - redirect to simplified system
get_global_config() {
    local key="$1"
    local default="$2"

    case "$key" in
        "defaults.update_interval")
            get_update_interval
            ;;
        "defaults.cleanup_interval")
            get_cleanup_interval
            ;;
        "logging.level")
            get_log_level
            ;;
        "notifications")
            if get_notifications_enabled; then
                echo "true"
            else
                echo "false"
            fi
            ;;
        "parallel_execution")
            if get_parallel_execution; then
                echo "true"
            else
                echo "false"
            fi
            ;;
        *)
            echo "$default"
            ;;
    esac
}

# Legacy function compatibility
get_module_config() {
    local module="$1"
    local key="$2"
    local default="$3"

    # For module-specific configs, return sensible defaults
    # since we've simplified away module-specific configuration
    case "$key" in
        "enabled") echo "true" ;;
        "interval_days") get_update_interval ;;
        "timeout") echo "600" ;;
        "parallel")
            if get_parallel_execution; then
                echo "true"
            else
                echo "false"
            fi
            ;;
        "verbose")
            local log_level=$(get_log_level)
            if [[ "$log_level" == "debug" ]]; then
                echo "true"
            else
                echo "false"
            fi
            ;;
        *) echo "$default" ;;
    esac
}

# Initialize configuration system
init_config() {
    init_simple_config
}

# Validate configuration (simplified)
validate_config() {
    validate_config_basic
}

# Show configuration
show_config() {
    show_simple_config
}

# Export for compatibility
export -f get_global_config get_module_config init_config validate_config show_config