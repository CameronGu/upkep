#!/bin/bash
# config_simple.sh - Simplified Configuration Management for upKep
# Replaces the over-engineered 3,009-line enterprise system with <300 lines focused on user needs

# Configuration file path
UPKEP_CONFIG="${HOME}/.upkep/config.yaml"

# Default configuration (exactly what users need, nothing more)
DEFAULT_CONFIG="# upKep Configuration - Simple Linux system maintenance settings

update_interval: 7          # Days between package updates
cleanup_interval: 30        # Days between cleanup operations
log_level: info             # Logging: error, warn, info, debug
notifications: true         # Show completion notifications
colorblind: false           # Enable colorblind-friendly colors"

# Initialize configuration system
init_simple_config() {
    # Create .upkep directory
    mkdir -p "$(dirname "$UPKEP_CONFIG")"

    # Create config file if it doesn't exist
    if [[ ! -f "$UPKEP_CONFIG" ]]; then
        echo "$DEFAULT_CONFIG" > "$UPKEP_CONFIG"
        chmod 600 "$UPKEP_CONFIG"
        echo "Created configuration file: $UPKEP_CONFIG"
    fi
}

# Get configuration value with environment variable override
# Priority: environment variable > config file > default
get_config() {
    local key="$1"
    local default="$2"

    # Special handling for colorblind mode
    if [[ "$key" == "colorblind" ]]; then
        if [[ -n "${UPKEP_COLORBLIND}" ]]; then
            echo "${UPKEP_COLORBLIND}"
            return 0
        fi
    fi

    # Check for environment variable override (UPKEP_KEY_NAME format)
    local env_var="UPKEP_$(echo "$key" | tr '[:lower:].' '[:upper:]_')"
    if [[ -n "${!env_var}" ]]; then
        echo "${!env_var}"
        return 0
    fi

    # Read from config file if it exists
    if [[ -f "$UPKEP_CONFIG" ]]; then
        local value
        # Simple YAML parsing - look for "key: value" pattern
        value=$(grep "^${key}:" "$UPKEP_CONFIG" 2>/dev/null | cut -d':' -f2- | sed 's/^[[:space:]]*//')

        # Remove inline comments (everything after first #)
        value=$(echo "$value" | sed 's/[[:space:]]*#.*$//')

        # Trim trailing whitespace
        value=$(echo "$value" | sed 's/[[:space:]]*$//')

        # Remove quotes if present
        value=$(echo "$value" | sed 's/^["\x27]\(.*\)["\x27]$/\1/')

        if [[ -n "$value" ]]; then
            echo "$value"
            return 0
        fi
    fi

    # Return default value
    echo "$default"
}

# Set configuration value
set_config() {
    local key="$1"
    local value="$2"

    # Initialize config if needed
    init_simple_config

    # Create temp file for atomic update
    local temp_file
    temp_file=$(mktemp)

    # Update or add the key
    if grep -q "^${key}:" "$UPKEP_CONFIG" 2>/dev/null; then
        # Update existing key
        sed "s|^${key}:.*|${key}: ${value}|" "$UPKEP_CONFIG" > "$temp_file"
    else
        # Add new key
        {
            cat "$UPKEP_CONFIG" 2>/dev/null || echo "# upKep Configuration"
            echo "${key}: ${value}"
        } > "$temp_file"
    fi

    # Replace original file
    mv "$temp_file" "$UPKEP_CONFIG"
    chmod 600 "$UPKEP_CONFIG"
}

# Show current configuration
show_config() {
    echo "upKep Configuration"
    echo "==================="

    if [[ -f "$UPKEP_CONFIG" ]]; then
        cat "$UPKEP_CONFIG"
    else
        echo "No configuration file found. Run 'upkep config reset' to create default."
    fi

    echo ""
    echo "Environment Overrides:"
    echo "======================"
    echo "UPKEP_DRY_RUN=${UPKEP_DRY_RUN:-not set}"
    echo "UPKEP_FORCE=${UPKEP_FORCE:-not set}"
    echo "UPKEP_LOG_LEVEL=${UPKEP_LOG_LEVEL:-not set}"
    echo "UPKEP_UPDATE_INTERVAL=${UPKEP_UPDATE_INTERVAL:-not set}"
    echo "UPKEP_CLEANUP_INTERVAL=${UPKEP_CLEANUP_INTERVAL:-not set}"
    echo "UPKEP_COLORBLIND=${UPKEP_COLORBLIND:-not set}"
}

# Reset configuration to defaults
reset_config() {
    echo "Resetting configuration to defaults..."
    mkdir -p "$(dirname "$UPKEP_CONFIG")"
    echo "$DEFAULT_CONFIG" > "$UPKEP_CONFIG"
    chmod 600 "$UPKEP_CONFIG"
    echo "Configuration reset to: $UPKEP_CONFIG"
}

# Edit configuration in user's preferred editor
edit_config() {
    # Initialize if needed
    init_simple_config

    # Use user's preferred editor
    local editor="${EDITOR:-nano}"

    echo "Opening configuration in $editor..."
    "$editor" "$UPKEP_CONFIG"

    # Validate basic syntax after editing
    if ! validate_config_basic; then
        echo "Warning: Configuration may have syntax issues."
        echo "Run 'upkep config show' to review, or 'upkep config reset' to restore defaults."
    fi
}

# Basic configuration validation (just check if file is readable and has basic structure)
validate_config_basic() {
    if [[ ! -f "$UPKEP_CONFIG" ]]; then
        return 1
    fi

    if [[ ! -r "$UPKEP_CONFIG" ]]; then
        echo "Error: Cannot read configuration file: $UPKEP_CONFIG"
        return 1
    fi

    # Check for at least one valid setting
    if ! grep -q "^[a-z_]*:" "$UPKEP_CONFIG" 2>/dev/null; then
        echo "Error: Configuration file appears to be empty or invalid"
        return 1
    fi

    return 0
}

# Get specific configuration values with sensible defaults
get_update_interval() {
    get_config "update_interval" "7"
}

get_cleanup_interval() {
    get_config "cleanup_interval" "30"
}

get_log_level() {
    get_config "log_level" "info"
}

# Get notifications setting
get_notifications_enabled() {
    local value
    value=$(get_config "notifications" "true")
    [[ "$value" == "true" ]]
}

# Get colorblind setting
get_colorblind_enabled() {
    local value
    value=$(get_config "colorblind" "false")
    [[ "$value" == "true" || "$value" == "1" ]]
}

# Check if dry run mode is enabled (via environment variable)
is_dry_run() {
    [[ "${UPKEP_DRY_RUN:-false}" == "true" ]]
}

# Check if force mode is enabled (skip interval checks)
is_force_mode() {
    [[ "${UPKEP_FORCE:-false}" == "true" ]]
}

# Configuration management CLI interface
config_command() {
    local subcommand="$1"

    case "$subcommand" in
        "show"|"")
            show_config
            ;;
        "edit")
            edit_config
            ;;
        "reset")
            reset_config
            ;;
        "get")
            local key="$2"
            if [[ -z "$key" ]]; then
                echo "Usage: upkep config get <key>"
                echo "Available keys: update_interval, cleanup_interval, log_level, notifications"
                return 1
            fi
            get_config "$key" ""
            ;;
        "set")
            local key="$2"
            local value="$3"
            if [[ -z "$key" || -z "$value" ]]; then
                echo "Usage: upkep config set <key> <value>"
                echo "Available keys: update_interval, cleanup_interval, log_level, notifications"
                return 1
            fi
            set_config "$key" "$value"
            echo "Set $key = $value"
            ;;
        *)
            echo "Usage: upkep config [show|edit|reset|get <key>|set <key> <value>]"
            echo ""
            echo "Commands:"
            echo "  show              Display current configuration"
            echo "  edit              Edit configuration in \$EDITOR"
            echo "  reset             Reset to default configuration"
            echo "  get <key>         Get value of specific setting"
            echo "  set <key> <value> Set value of specific setting"
            echo ""
            echo "Environment overrides:"
            echo "  UPKEP_DRY_RUN=true      Test mode (show what would be done)"
            echo "  UPKEP_FORCE=true        Skip interval checks"
            echo "  UPKEP_LOG_LEVEL=debug   Temporary logging level"
            echo "  UPKEP_UPDATE_INTERVAL=1 Override update interval"
            echo "  UPKEP_NOTIFICATIONS=false upkep run"
            return 1
            ;;
    esac
}

# Initialize configuration on script load
init_simple_config

# Export functions for use in other scripts
export -f get_config get_update_interval get_cleanup_interval get_log_level
export -f is_dry_run is_force_mode get_notifications_enabled