#!/bin/bash
# module.sh - Module configuration management for upKep

# Module configuration directory
MODULE_CONFIG_DIR="$HOME/.upkep/modules"

# Get module configuration value
get_module_config() {
    local module="$1"
    local key="$2"
    local default="$3"

    local module_config="$MODULE_CONFIG_DIR/${module}.yaml"

    if [[ -f "$module_config" ]]; then
        if command -v yq >/dev/null 2>&1; then
            local value
            value=$(yq eval ".$key" "$module_config" 2>/dev/null)
            if [[ "$value" != "null" && -n "$value" ]]; then
                echo "$value"
                return 0
            fi
        else
            # Fallback to grep if yq is not available
            local value
            value=$(grep "^[[:space:]]*${key}:[[:space:]]*" "$module_config" | sed 's/.*:[[:space:]]*//')
            if [[ -n "$value" ]]; then
                echo "$value"
                return 0
            fi
        fi
    fi

    echo "$default"
}

# Set module configuration value
set_module_config() {
    local module="$1"
    local key="$2"
    local value="$3"

    local module_config="$MODULE_CONFIG_DIR/${module}.yaml"

    # Create module config directory if it doesn't exist
    mkdir -p "$MODULE_CONFIG_DIR"
    chmod 700 "$MODULE_CONFIG_DIR"

    # Create module config file if it doesn't exist
    if [[ ! -f "$module_config" ]]; then
        local default_content="enabled: true
interval_days: 7
description: \"\""
        secure_file_create "$module_config" "$default_content" "600"
    fi

    if command -v yq >/dev/null 2>&1; then
        yq eval ".$key = \"$value\"" -i "$module_config"
    else
        # Fallback to sed if yq is not available
        local temp_file
        temp_file=$(mktemp)
        cp "$module_config" "$temp_file"

        # Check if the key exists
        if grep -q "^[[:space:]]*${key}:" "$temp_file"; then
            # Update existing key
            sed -i "s/^[[:space:]]*${key}:[[:space:]]*.*/${key}: $value/" "$temp_file"
        else
            # Add new key
            echo "${key}: $value" >> "$temp_file"
        fi

        mv "$temp_file" "$module_config"
    fi
}

# Validate module configuration
validate_module_config() {
    local module="$1"
    local module_config="$MODULE_CONFIG_DIR/${module}.yaml"
    local issues_found=0

    if [[ ! -f "$module_config" ]]; then
        echo "Module configuration file not found: $module_config"
        return 1
    fi

    # Validate YAML syntax if yamllint is available
    if command -v yamllint >/dev/null 2>&1; then
        if ! yamllint "$module_config" >/dev/null 2>&1; then
            echo "Invalid YAML syntax in module config: $module_config"
            ((issues_found++))
        fi
    fi

    # Validate required fields
    local enabled
    enabled=$(get_module_config "$module" "enabled" "")
    if [[ -z "$enabled" ]]; then
        echo "Missing 'enabled' field in module config: $module"
        ((issues_found++))
    elif [[ "$enabled" != "true" && "$enabled" != "false" ]]; then
        echo "Invalid 'enabled' value in module config: $module (must be true/false)"
        ((issues_found++))
    fi

    local interval
    interval=$(get_module_config "$module" "interval_days" "")
    if [[ -z "$interval" ]]; then
        echo "Missing 'interval_days' field in module config: $module"
        ((issues_found++))
    elif ! [[ "$interval" =~ ^[0-9]+$ ]] || [[ $interval -lt 1 ]] || [[ $interval -gt 365 ]]; then
        echo "Invalid 'interval_days' value in module config: $module (must be 1-365)"
        ((issues_found++))
    fi

    # Validate file permissions
    if ! validate_file_permissions "$module_config" "600"; then
        echo "Incorrect permissions on module config: $module_config"
        ((issues_found++))
    fi

    if [[ $issues_found -eq 0 ]]; then
        echo "Module configuration validation passed: $module"
        return 0
    else
        echo "Module configuration validation found $issues_found issue(s) in: $module"
        return 1
    fi
}

# Validate all module configurations
validate_module_configs() {
    local issues_found=0
    local modules_checked=0

    if [[ ! -d "$MODULE_CONFIG_DIR" ]]; then
        echo "Module configuration directory not found: $MODULE_CONFIG_DIR"
        return 1
    fi

    while IFS= read -r -d '' file; do
        local module
        module=$(basename "$file" .yaml)
        if ! validate_module_config "$module"; then
            ((issues_found++))
        fi
        ((modules_checked++))
    done < <(find "$MODULE_CONFIG_DIR" -name "*.yaml" -type f -print0 2>/dev/null)

    if [[ $modules_checked -eq 0 ]]; then
        echo "No module configuration files found"
        return 0
    fi

    if [[ $issues_found -eq 0 ]]; then
        echo "All module configurations are valid ($modules_checked modules checked)"
        return 0
    else
        echo "Module configuration validation found $issues_found issue(s) in $modules_checked module(s)"
        return 1
    fi
}

# List all module configurations
list_module_configs() {
    if [[ ! -d "$MODULE_CONFIG_DIR" ]]; then
        echo "Module configuration directory not found: $MODULE_CONFIG_DIR"
        return 1
    fi

    local found_modules=0
    while IFS= read -r -d '' file; do
        local module
        module=$(basename "$file" .yaml)
        local enabled
        enabled=$(get_module_config "$module" "enabled" "unknown")
        local interval
        interval=$(get_module_config "$module" "interval_days" "unknown")
        local description
        description=$(get_module_config "$module" "description" "No description")

        printf "%-20s | %-8s | %-8s | %s\n" "$module" "$enabled" "$interval" "$description"
        ((found_modules++))
    done < <(find "$MODULE_CONFIG_DIR" -name "*.yaml" -type f -print0 2>/dev/null | sort -z)

    if [[ $found_modules -eq 0 ]]; then
        echo "No module configuration files found"
    else
        echo ""
        echo "Total modules: $found_modules"
    fi
}

# Create default module configuration
create_default_module_config() {
    local module="$1"
    local description="${2:-}"

    local module_config="$MODULE_CONFIG_DIR/${module}.yaml"
    local default_content="enabled: true
interval_days: 7
description: \"$description\""

    if [[ -f "$module_config" ]]; then
        echo "Module configuration already exists: $module_config"
        return 1
    fi

    secure_file_create "$module_config" "$default_content" "600"
    echo "Created default module configuration: $module_config"
}

# Delete module configuration
delete_module_config() {
    local module="$1"
    local module_config="$MODULE_CONFIG_DIR/${module}.yaml"

    if [[ ! -f "$module_config" ]]; then
        echo "Module configuration not found: $module_config"
        return 1
    fi

    rm "$module_config"
    echo "Deleted module configuration: $module_config"
}

# Backup module configuration
backup_module_config() {
    local module="$1"
    local backup_dir="$HOME/.upkep/backups"
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$backup_dir/${module}_${timestamp}.yaml"

    local module_config="$MODULE_CONFIG_DIR/${module}.yaml"

    if [[ ! -f "$module_config" ]]; then
        echo "Module configuration not found: $module_config"
        return 1
    fi

    mkdir -p "$backup_dir"
    cp "$module_config" "$backup_file"
    chmod 600 "$backup_file"

    echo "Backed up module configuration: $backup_file"
}

# Restore module configuration
restore_module_config() {
    local module="$1"
    local backup_file="$2"

    if [[ ! -f "$backup_file" ]]; then
        echo "Backup file not found: $backup_file"
        return 1
    fi

    local module_config="$MODULE_CONFIG_DIR/${module}.yaml"
    cp "$backup_file" "$module_config"
    chmod 600 "$module_config"

    echo "Restored module configuration: $module_config"
}