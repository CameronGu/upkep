#!/bin/bash
# global.sh - Global configuration management for upKep

# Configuration paths
GLOBAL_CONFIG="$HOME/.upkep/config.yaml"

# Default configuration
DEFAULT_CONFIG="version: 2.0.0

defaults:
  update_interval: 7
  cleanup_interval: 30
  security_interval: 1

logging:
  level: info
  file: $HOME/.upkep/upkep.log
  max_size: 10MB
  max_files: 5

notifications:
  enabled: true

dry_run: false
parallel_execution: true

modules:
  apt_update:
    enabled: true
    interval_days: 7
    description: Update APT packages and repositories
  snap_update:
    enabled: true
    interval_days: 7
    description: Update Snap packages
  flatpak_update:
    enabled: true
    interval_days: 7
    description: Update Flatpak packages
  cleanup:
    enabled: true
    interval_days: 30
    description: Perform system cleanup"

# Initialize configuration system
init_config() {
    # Use secure initialization
    secure_init_config
}

# Get global configuration value
get_global_config() {
    local key="$1"
    local default="$2"

    if [[ -f "$GLOBAL_CONFIG" ]]; then
        if command -v yq >/dev/null 2>&1; then
            local value
            value=$(yq eval ".$key" "$GLOBAL_CONFIG" 2>/dev/null)
            if [[ "$value" != "null" && -n "$value" ]]; then
                echo "$value"
                return 0
            fi
        else
            # Fallback to grep if yq is not available
            local value
            value=$(grep "^[[:space:]]*${key//./[[:space:]]*}: " "$GLOBAL_CONFIG" | sed 's/.*:[[:space:]]*//')
            if [[ -n "$value" ]]; then
                echo "$value"
                return 0
            fi
        fi
    fi

    echo "$default"
}

# Set global configuration value
set_global_config() {
    local key="$1"
    local value="$2"

    if [[ ! -f "$GLOBAL_CONFIG" ]]; then
        init_config
    fi

    if command -v yq >/dev/null 2>&1; then
        # Escape special characters in the value
        local escaped_value
        escaped_value=$(echo "$value" | sed 's/"/\\"/g')
        yq eval ".$key = \"$escaped_value\"" -i "$GLOBAL_CONFIG" 2>/dev/null || {
            # Fallback if yq fails
            local temp_file
            temp_file=$(mktemp)
            cp "$GLOBAL_CONFIG" "$temp_file"

            # Convert dot notation to nested structure
            local path_parts=(${key//./ })
            local current_path=""
            local indent=""

            for part in "${path_parts[@]}"; do
                if [[ -z "$current_path" ]]; then
                    current_path="$part"
                    indent=""
                else
                    current_path="${current_path}.$part"
                    indent="  $indent"
                fi

                # Check if the path exists
                if ! grep -q "^${indent}${part}:" "$temp_file"; then
                    # Add the key if it doesn't exist
                    echo "${indent}${part}:" >> "$temp_file"
                fi
            done

            # Update the value
            sed -i "s/^${indent}${path_parts[-1]}:[[:space:]]*.*/${indent}${path_parts[-1]}: $escaped_value/" "$temp_file"

            mv "$temp_file" "$GLOBAL_CONFIG"
        }
    else
        # Fallback to sed if yq is not available
        local temp_file
        temp_file=$(mktemp)
        cp "$GLOBAL_CONFIG" "$temp_file"

        # Convert dot notation to nested structure
        local path_parts=(${key//./ })
        local current_path=""
        local indent=""

        for part in "${path_parts[@]}"; do
            if [[ -z "$current_path" ]]; then
                current_path="$part"
                indent=""
            else
                current_path="${current_path}.$part"
                indent="  $indent"
            fi

            # Check if the path exists
            if ! grep -q "^${indent}${part}:" "$temp_file"; then
                # Add the key if it doesn't exist
                echo "${indent}${part}:" >> "$temp_file"
            fi
        done

        # Update the value
        sed -i "s/^${indent}${path_parts[-1]}:[[:space:]]*.*/${indent}${path_parts[-1]}: $value/" "$temp_file"

        mv "$temp_file" "$GLOBAL_CONFIG"
    fi
}

# Show configuration
show_config() {
    local config_type="${1:-global}"
    local module="${2:-}"

    case "$config_type" in
        "global")
            if [[ -f "$GLOBAL_CONFIG" ]]; then
                echo "=== Global Configuration ==="
                if command -v yq >/dev/null 2>&1; then
                    yq eval '.' "$GLOBAL_CONFIG"
                else
                    cat "$GLOBAL_CONFIG"
                fi
            else
                echo "Global configuration file not found: $GLOBAL_CONFIG"
                echo "Run 'upkep config init' to create it."
            fi
            ;;
        "module")
            if [[ -z "$module" ]]; then
                echo "Error: Module name required for module config"
                return 1
            fi
            local module_config="$MODULE_CONFIG_DIR/${module}.yaml"
            if [[ -f "$module_config" ]]; then
                echo "=== Module Configuration: $module ==="
                if command -v yq >/dev/null 2>&1; then
                    yq eval '.' "$module_config"
                else
                    cat "$module_config"
                fi
            else
                echo "Module configuration file not found: $module_config"
            fi
            ;;
        *)
            echo "Error: Invalid config type. Use 'global' or 'module'"
            return 1
            ;;
    esac
}

# Secure file creation
secure_file_create() {
    local file="$1"
    local content="$2"
    local permissions="${3:-600}"

    # Create directory if it doesn't exist
    local dir
    dir=$(dirname "$file")
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        chmod 700 "$dir"
    fi

    # Create file with secure permissions
    echo "$content" > "$file"
    chmod "$permissions" "$file"

    # Verify file was created securely
    validate_file_permissions "$file" "$permissions"
}

# Validate file permissions
validate_file_permissions() {
    local file="$1"
    local expected_permissions="${2:-600}"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    local actual_permissions
    actual_permissions=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%Lp" "$file" 2>/dev/null)

    if [[ "$actual_permissions" == "$expected_permissions" ]]; then
        return 0
    else
        return 1
    fi
}

# Repair file permissions
repair_permissions() {
    local file="$1"
    local expected_permissions="${2:-600}"

    if [[ -f "$file" ]]; then
        chmod "$expected_permissions" "$file"
        if validate_file_permissions "$file" "$expected_permissions"; then
            echo "Permissions repaired for: $file"
            return 0
        else
            echo "Failed to repair permissions for: $file"
            return 1
        fi
    fi
}

# Validate all configuration permissions
validate_all_config_permissions() {
    local issues_found=0

    # Check global config
    if [[ -f "$GLOBAL_CONFIG" ]]; then
        if ! validate_file_permissions "$GLOBAL_CONFIG" "600"; then
            echo "Warning: Global config has incorrect permissions: $GLOBAL_CONFIG"
            ((issues_found++))
        fi
    fi

    # Check module configs
    if [[ -d "$MODULE_CONFIG_DIR" ]]; then
        while IFS= read -r -d '' file; do
            if ! validate_file_permissions "$file" "600"; then
                echo "Warning: Module config has incorrect permissions: $file"
                ((issues_found++))
            fi
        done < <(find "$MODULE_CONFIG_DIR" -name "*.yaml" -type f -print0 2>/dev/null)
    fi

    # Check config directory permissions
    if [[ -d "$HOME/.upkep" ]]; then
        local dir_permissions
        dir_permissions=$(stat -c "%a" "$HOME/.upkep" 2>/dev/null || stat -f "%Lp" "$HOME/.upkep" 2>/dev/null)
        if [[ "$dir_permissions" != "700" ]]; then
            echo "Warning: Config directory has incorrect permissions: $HOME/.upkep"
            ((issues_found++))
        fi
    fi

    if [[ $issues_found -eq 0 ]]; then
        echo "All configuration permissions are correct"
        return 0
    else
        echo "Module configuration validation found $issues_found issue(s)"
        return 1
    fi
}

# Secure initialization
secure_init_config() {
    # Create .upkep directory with secure permissions
    mkdir -p "$HOME/.upkep"
    chmod 700 "$HOME/.upkep"

    # Create subdirectories
    mkdir -p "$HOME/.upkep/modules"
    mkdir -p "$HOME/.upkep/logs"
    mkdir -p "$HOME/.upkep/cache"
    mkdir -p "$HOME/.upkep/backups"

    # Set secure permissions on subdirectories
    chmod 700 "$HOME/.upkep/modules"
    chmod 700 "$HOME/.upkep/logs"
    chmod 700 "$HOME/.upkep/cache"
    chmod 700 "$HOME/.upkep/backups"

    # Create global config if it doesn't exist
    if [[ ! -f "$GLOBAL_CONFIG" ]]; then
        secure_file_create "$GLOBAL_CONFIG" "$DEFAULT_CONFIG" "600"
        echo "Global configuration initialized: $GLOBAL_CONFIG"
    fi

    # Validate permissions
    validate_all_config_permissions
}