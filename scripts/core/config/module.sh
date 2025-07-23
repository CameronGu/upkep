#!/bin/bash
# module.sh - Module configuration management for upKep

# Module configuration directory
MODULE_CONFIG_DIR="${MODULE_CONFIG_DIR:-$HOME/.upkep/modules}"

# Centralized YAML parsing utility functions
# Only removes quotes that wrap the entire string, preserves internal quotes
smart_quote_removal() {
    local value="$1"

    # Remove surrounding double quotes
    if [[ "$value" =~ ^\".*\"$ ]]; then
        value=$(echo "$value" | sed 's/^"//;s/"$//')
    # Remove surrounding single quotes only if there aren't internal single quotes
    elif [[ "$value" =~ ^\'.*\'$ ]] && [[ ! "$value" =~ ^\'.*\'.*\'$ ]]; then
        value=$(echo "$value" | sed 's/^.//;s/.$//')
    fi

    echo "$value"
}

# Extract value from simple YAML line (key: value)
extract_simple_yaml_value() {
    local line="$1"
    echo "$line" | sed 's/^[^:]*:[[:space:]]*//'
}

# Extract value from indented YAML line (  key: value)
extract_indented_yaml_value() {
    local line="$1"
    echo "$line" | sed 's/^[[:space:]]*[^:]*:[[:space:]]*//'
}

# Handle boolean and special YAML values with whitespace trimming
format_yaml_value() {
    local value="$1"
    case "$value" in
        "true"|"false"|"null") echo "$value" ;;
        *) echo "$value" | sed 's/[[:space:]]*$//' ;;  # Trim trailing whitespace
    esac
}

# Skip YAML comments and empty lines
should_skip_yaml_line() {
    local line="$1"
    [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "${line// }" ]]
}

# Enhanced module configuration value getter
# Consistent with global config approach - yq optional, robust fallback
get_module_config() {
    local module="$1"
    local key="$2"
    local default="$3"

    local module_config="$MODULE_CONFIG_DIR/${module}.yaml"

    if [[ -f "$module_config" ]]; then
        # Try yq first if available (optional enhancement)
        if command -v yq >/dev/null 2>&1; then
            local value
            value=$(yq eval ".$key" "$module_config" 2>/dev/null)
            if [[ "$value" != "null" && -n "$value" ]]; then
                echo "$value"
                return 0
            fi
        fi

        # Enhanced fallback method
        local value
        value=$(get_module_config_enhanced_fallback "$module_config" "$key")
        if [[ -n "$value" ]]; then
            echo "$value"
            return 0
        fi
    fi

    echo "$default"
}

# Enhanced fallback method for module config parsing
get_module_config_enhanced_fallback() {
    local module_config="$1"
    local key="$2"

    # Use the same enhanced parsing logic as global config
    local path_parts
    IFS='.' read -r -a path_parts <<< "$key" 2>/dev/null || {
        # Fallback for shells that don't support read -a
        path_parts=($(echo "$key" | tr '.' ' '))
    }
    local depth=${#path_parts[@]}

    case $depth in
        1)
            # Simple key (no dots)
            get_module_yaml_simple_key "$module_config" "${path_parts[0]}"
            ;;
        2)
            # Two-level nesting
            get_module_yaml_nested_key "$module_config" "${path_parts[0]}" "${path_parts[1]}"
            ;;
        *)
            # For deeper nesting or complex cases
            get_module_yaml_generic "$module_config" "$key"
            ;;
    esac
}

# Parse simple YAML key for modules
get_module_yaml_simple_key() {
    local module_config="$1"
    local key="$2"
    local value

    # Match key at start of line followed by colon
    local raw_line
    raw_line=$(grep "^${key}:[[:space:]]*" "$module_config" 2>/dev/null | head -n1)

    # Extract and process value through centralized functions
    value=$(extract_simple_yaml_value "$raw_line")
    value=$(smart_quote_removal "$value")
    format_yaml_value "$value"
}

# Parse two-level nested YAML key for modules
get_module_yaml_nested_key() {
    local module_config="$1"
    local parent_key="$2"
    local child_key="$3"
    local in_section=false
    local value=""
    local indentation_pattern="^[[:space:]]+"

    while IFS= read -r line; do
        # Skip comments and empty lines
        should_skip_yaml_line "$line" && continue

        # Check if we're entering the parent section
        if [[ "$line" =~ ^${parent_key}:[[:space:]]*$ ]]; then
            in_section=true
            continue
        fi

        # If we're in the section and hit another top-level key, exit section
        if [[ $in_section == true ]] && [[ "$line" =~ ^[a-zA-Z_][a-zA-Z0-9_]*:[[:space:]]* ]] && [[ ! "$line" =~ $indentation_pattern ]]; then
            break
        fi

        # If we're in the section, look for our child key
        if [[ $in_section == true ]] && [[ "$line" =~ $indentation_pattern${child_key}:[[:space:]]* ]]; then
            value=$(extract_indented_yaml_value "$line")
            value=$(smart_quote_removal "$value")
            break
        fi
    done < "$module_config"

    # Format and return the value
    format_yaml_value "$value"
}

# Generic fallback for module config
get_module_yaml_generic() {
    local module_config="$1"
    local key="$2"
    local path_parts
    IFS='.' read -r -a path_parts <<< "$key" 2>/dev/null || {
        # Fallback for shells that don't support read -a
        path_parts=($(echo "$key" | tr '.' ' '))
    }
    local search_pattern

    # Simple approach: look for the final key in the path
    search_pattern=$(printf "[[:space:]]*%s:[[:space:]]*" "${path_parts[-1]}")

    local value raw_line
    raw_line=$(grep "$search_pattern" "$module_config" 2>/dev/null | tail -n1)

    # Extract and process value through centralized functions
    value=$(extract_indented_yaml_value "$raw_line")
    value=$(smart_quote_removal "$value")
    format_yaml_value "$value"
}

# Enhanced set_module_config with better error handling
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

    # Validate input
    if [[ -z "$key" ]]; then
        echo "Error: Module configuration key cannot be empty" >&2
        return 1
    fi

    # Try yq first if available (optional enhancement)
    if command -v yq >/dev/null 2>&1; then
        # Handle different value types like global config
        local yq_value="$value"
        case "$value" in
            "true"|"false")
                yq_value="$value"
                ;;
            *[0-9]*)
                if [[ "$value" =~ ^[0-9]+$ ]]; then
                    yq_value="$value"
                else
                    yq_value="\"$value\""
                fi
                ;;
            *)
                yq_value="\"$(echo "$value" | sed 's/"/\\"/g')\""
                ;;
        esac

        if yq eval ".$key = $yq_value" -i "$module_config" 2>/dev/null; then
            return 0
        else
            echo "Warning: yq failed for module '$module' key '$key', using fallback method" >&2
        fi
    fi

    # Enhanced fallback method
    set_module_config_enhanced_fallback "$module_config" "$key" "$value"
}

# Enhanced fallback method for setting module configuration
set_module_config_enhanced_fallback() {
    local module_config="$1"
    local key="$2"
    local value="$3"

    local temp_file
    temp_file=$(mktemp) || {
        echo "Error: Cannot create temporary file for module config" >&2
        return 1
    }

    # Create backup
    if ! cp "$module_config" "$temp_file"; then
        echo "Error: Cannot backup module configuration file" >&2
        rm -f "$temp_file"
        return 1
    fi

    # Handle different nesting levels (most module configs are simple)
    local path_parts
    IFS='.' read -r -a path_parts <<< "$key" 2>/dev/null || {
        # Fallback for shells that don't support read -a
        path_parts=($(echo "$key" | tr '.' ' '))
    }
    local depth=${#path_parts[@]}

    case $depth in
        1)
            set_module_yaml_simple_key "$temp_file" "${path_parts[0]}" "$value"
            ;;
        2)
            set_module_yaml_nested_key "$temp_file" "${path_parts[0]}" "${path_parts[1]}" "$value"
            ;;
        *)
            echo "Warning: Complex nesting in module config may not be fully supported" >&2
            set_module_yaml_simple_key "$temp_file" "$key" "$value"
            ;;
    esac

    # Replace original file atomically
    if mv "$temp_file" "$module_config"; then
        return 0
    else
        echo "Error: Cannot update module configuration file" >&2
        rm -f "$temp_file"
        return 1
    fi
}

# Set simple YAML key for modules
set_module_yaml_simple_key() {
    local temp_file="$1"
    local key="$2"
    local value="$3"

    if grep -q "^${key}:" "$temp_file"; then
        # Key exists, update it
        sed -i "s/^${key}:[[:space:]]*.*/${key}: $value/" "$temp_file"
    else
        # Key doesn't exist, add it at the end
        echo "${key}: $value" >> "$temp_file"
    fi
}

# Set nested YAML key for modules
set_module_yaml_nested_key() {
    local temp_file="$1"
    local parent_key="$2"
    local child_key="$3"
    local value="$4"

    if grep -q "^${parent_key}:" "$temp_file"; then
        # Parent section exists
        if grep -A20 "^${parent_key}:" "$temp_file" | grep -q "^[[:space:]]\+${child_key}:"; then
            # Child key exists, update it
            sed -i "/^${parent_key}:/,/^[a-zA-Z]/ s/^[[:space:]]*${child_key}:[[:space:]]*.*$/  ${child_key}: $value/" "$temp_file"
        else
            # Child key doesn't exist, add it
            sed -i "/^${parent_key}:/a\\  ${child_key}: $value" "$temp_file"
        fi
    else
        # Parent section doesn't exist, create both
        {
            echo ""
            echo "${parent_key}:"
            echo "  ${child_key}: $value"
        } >> "$temp_file"
    fi
}

# Enhanced module configuration validation
validate_module_config() {
    local module="$1"
    local module_config="$MODULE_CONFIG_DIR/${module}.yaml"
    local issues_found=0

    if [[ ! -f "$module_config" ]]; then
        echo "Module configuration file not found: $module_config"
        return 1
    fi

    # Basic YAML structure validation
    if ! validate_module_yaml_structure "$module_config"; then
        ((issues_found++))
    fi

    # Validate YAML syntax if yamllint is available
    if command -v yamllint >/dev/null 2>&1; then
        if ! yamllint "$module_config" >/dev/null 2>&1; then
            echo "Invalid YAML syntax in module config: $module_config"
            ((issues_found++))
        fi
    fi

    # Validate required fields using enhanced parsing
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

# Validate module YAML structure
validate_module_yaml_structure() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "Module configuration file not found: $file" >&2
        return 1
    fi

    # Basic YAML structure validation (similar to global config)
    local line_num=0
    local errors=0

    while IFS= read -r line; do
        ((line_num++))

        # Skip empty lines and comments
        [[ -z "${line// }" ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue

        # Check for basic YAML syntax issues
        if [[ "$line" =~ ^[[:space:]]*[^:[:space:]]+[[:space:]]*$ ]] && [[ ! "$line" =~ : ]]; then
            echo "Warning: Line $line_num may be missing colon: $line" >&2
            ((errors++))
        fi

        # Check for basic indentation issues
        if [[ "$line" =~ ^[[:space:]]+ ]] && [[ ! "$line" =~ ^[[:space:]]{2}|^[[:space:]]{4} ]]; then
            local indent_count
            indent_count=$(echo "$line" | sed 's/[^[:space:]].*//' | wc -c)
            if [[ $((indent_count % 2)) -ne 1 ]]; then  # wc -c includes newline
                echo "Warning: Line $line_num has unusual indentation ($((indent_count - 1)) spaces): $line" >&2
            fi
        fi
    done < "$file"

    if [[ $errors -eq 0 ]]; then
        return 0
    else
        echo "Found $errors potential YAML structure issues in module config: $file" >&2
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