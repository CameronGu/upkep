#!/bin/bash
# global.sh - Global configuration management for upKep

# Configuration paths
GLOBAL_CONFIG="${GLOBAL_CONFIG:-$HOME/.upkep/config.yaml}"

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

# Enhanced YAML parsing - primary function
# This function provides robust YAML parsing with yq as optional enhancement
get_global_config() {
    local key="$1"
    local default="$2"

    if [[ -f "$GLOBAL_CONFIG" ]]; then
        # Try yq first if available (optional enhancement)
        if command -v yq >/dev/null 2>&1; then
            local value
            value=$(yq eval ".$key" "$GLOBAL_CONFIG" 2>/dev/null)
            if [[ "$value" != "null" && -n "$value" && "$value" != "null" ]]; then
                echo "$value"
                return 0
            fi
        fi

        # Enhanced fallback method - more robust than before
        local value found
        value=$(get_config_value_enhanced_fallback "$key")
        found=$?
        if [[ $found -eq 0 ]]; then
            echo "$value"
            return 0
        fi
    fi

    echo "$default"
}

# Get configuration value with simple environment variable overrides
# This is the recommended function for modules to use
get_config() {
    local key="$1"
    local default="$2"

    # Check for environment variable override first
    local env_var_name
    env_var_name="UPKEP_$(echo "$key" | tr '[:lower:].' '[:upper:]_')"

    if [[ -n "${!env_var_name}" ]]; then
        echo "${!env_var_name}"
        return 0
    fi

    # Fall back to regular config lookup
    get_global_config "$key" "$default"
}

# Enhanced fallback YAML parsing method
# More robust than the previous version, handles deeper nesting and edge cases
get_config_value_enhanced_fallback() {
    local key="$1"
    local path_parts
    IFS='.' read -ra path_parts <<< "$key"
    local depth=${#path_parts[@]}

    # Handle different depths of nesting
    case $depth in
        1)
            # Simple key (no dots)
            get_yaml_simple_key "${path_parts[0]}"
            ;;
        2)
            # Two-level nesting (e.g., defaults.update_interval)
            get_yaml_nested_key "${path_parts[0]}" "${path_parts[1]}"
            ;;
        3)
            # Three-level nesting (e.g., modules.apt_update.enabled)
            get_yaml_deep_nested_key "${path_parts[0]}" "${path_parts[1]}" "${path_parts[2]}"
            ;;
        *)
            # For deeper nesting, fall back to a more generic approach
            get_yaml_generic_path "$key"
            ;;
    esac
}

# Parse simple YAML key (no nesting)
get_yaml_simple_key() {
    local key="$1"
    local value

    # Check if key exists first
    if ! grep -q "^${key}:[[:space:]]*" "$GLOBAL_CONFIG" 2>/dev/null; then
        return 1  # Key not found
    fi

    # Match key at start of line followed by colon
    local raw_line
    raw_line=$(grep "^${key}:[[:space:]]*" "$GLOBAL_CONFIG" 2>/dev/null | head -n1)

    # Extract and process value through centralized functions
    value=$(extract_simple_yaml_value "$raw_line")
    value=$(smart_quote_removal "$value")
    format_yaml_value "$value"

    return 0  # Key found (even if empty)
}

# Parse two-level nested YAML key (e.g., parent.child)
get_yaml_nested_key() {
    local parent_key="$1"
    local child_key="$2"
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
    done < "$GLOBAL_CONFIG"

    # Format and return the value
    format_yaml_value "$value"

    # Return appropriate exit code
    if [[ -n "$value" ]] || grep -A20 "^${parent_key}:" "$GLOBAL_CONFIG" 2>/dev/null | grep -q "^[[:space:]]*${child_key}:[[:space:]]*"; then
        return 0  # Key found
    else
        return 1  # Key not found
    fi
}

# Parse three-level nested YAML key (e.g., modules.apt_update.enabled)
get_yaml_deep_nested_key() {
    local level1="$1"
    local level2="$2"
    local level3="$3"
    local in_level1=false
    local in_level2=false
    local value=""
    local indent1="^[[:space:]]+"
    local indent2="^[[:space:]]{2,}"

    while IFS= read -r line; do
        # Skip comments and empty lines
        should_skip_yaml_line "$line" && continue

        # Check for level 1 section
        if [[ "$line" =~ ^${level1}:[[:space:]]*$ ]]; then
            in_level1=true
            in_level2=false
            continue
        fi

        # If we hit another top-level key, exit
        if [[ $in_level1 == true ]] && [[ "$line" =~ ^[a-zA-Z_][a-zA-Z0-9_]*:[[:space:]]* ]] && [[ ! "$line" =~ $indent1 ]]; then
            break
        fi

        # Check for level 2 section within level 1
        if [[ $in_level1 == true ]] && [[ "$line" =~ $indent1${level2}:[[:space:]]*$ ]]; then
            in_level2=true
            continue
        fi

        # If we hit another level 1 child, exit level 2
        if [[ $in_level1 == true ]] && [[ $in_level2 == true ]] && [[ "$line" =~ ${indent1}[a-zA-Z_][a-zA-Z0-9_]*:[[:space:]]* ]] && [[ ! "$line" =~ ${indent2} ]]; then
            in_level2=false
            continue
        fi

        # Look for level 3 key within level 2
        if [[ $in_level1 == true ]] && [[ $in_level2 == true ]] && [[ "$line" =~ $indent2${level3}:[[:space:]]* ]]; then
            value=$(extract_indented_yaml_value "$line")
            value=$(smart_quote_removal "$value")
            break
        fi
    done < "$GLOBAL_CONFIG"

    # Format and return the value
    format_yaml_value "$value"

    # Return appropriate exit code based on whether we found the value
    if [[ -n "$value" ]]; then
        return 0  # Key found
    else
        return 1  # Key not found
    fi
}

# Generic path parser for deeper nesting (4+ levels)
get_yaml_generic_path() {
    local key="$1"
    local path_parts
    IFS='.' read -ra path_parts <<< "$key"
    local current_level=0
    local in_path=true
    local value=""

    # This is a simplified approach for very deep nesting
    # For production use, this would need more sophisticated handling
    local search_pattern
    search_pattern=$(printf "[[:space:]]*%s:[[:space:]]*" "${path_parts[-1]}")

    local raw_line
    raw_line=$(grep "$search_pattern" "$GLOBAL_CONFIG" 2>/dev/null | tail -n1)

    # Extract and process value through centralized functions
    value=$(extract_indented_yaml_value "$raw_line")
    value=$(smart_quote_removal "$value")
    format_yaml_value "$value"

    # Return appropriate exit code
    if grep -q "$search_pattern" "$GLOBAL_CONFIG" 2>/dev/null; then
        return 0  # Key found
    else
        return 1  # Key not found
    fi
}

# Enhanced set_global_config with better error handling and validation
set_global_config() {
    local key="$1"
    local value="$2"

    if [[ ! -f "$GLOBAL_CONFIG" ]]; then
        init_config
    fi

    # Validate input
    if [[ -z "$key" ]]; then
        echo "Error: Configuration key cannot be empty" >&2
        return 1
    fi

    # Try yq first if available (optional enhancement)
    if command -v yq >/dev/null 2>&1; then
        # Escape special characters and handle different value types
        local yq_value="$value"
        case "$value" in
            "true"|"false")
                yq_value="$value"
                ;;
            *[0-9]*)
                # Check if it's a pure number
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

        if yq eval ".$key = $yq_value" -i "$GLOBAL_CONFIG" 2>/dev/null; then
            return 0
        else
            echo "Warning: yq failed for key '$key', using fallback method" >&2
        fi
    fi

    # Enhanced fallback method
    set_global_config_enhanced_fallback "$key" "$value"
}

# Enhanced fallback method for setting configuration
set_global_config_enhanced_fallback() {
    local key="$1"
    local value="$2"

    local temp_file
    temp_file=$(mktemp) || {
        echo "Error: Cannot create temporary file" >&2
        return 1
    }

    # Create backup
    if ! cp "$GLOBAL_CONFIG" "$temp_file"; then
        echo "Error: Cannot backup configuration file" >&2
        rm -f "$temp_file"
        return 1
    fi

    # Handle different nesting levels
    local path_parts
    IFS='.' read -ra path_parts <<< "$key"
    local depth=${#path_parts[@]}

    case $depth in
        1)
            set_yaml_simple_key "$temp_file" "${path_parts[0]}" "$value"
            ;;
        2)
            set_yaml_nested_key "$temp_file" "${path_parts[0]}" "${path_parts[1]}" "$value"
            ;;
        3)
            set_yaml_deep_nested_key "$temp_file" "${path_parts[0]}" "${path_parts[1]}" "${path_parts[2]}" "$value"
            ;;
        *)
            echo "Warning: Deep nesting (${depth} levels) may not be fully supported in fallback mode" >&2
            set_yaml_nested_key "$temp_file" "${path_parts[0]}" "${path_parts[1]}" "$value"
            ;;
    esac

    # Replace original file atomically
    if mv "$temp_file" "$GLOBAL_CONFIG"; then
        return 0
    else
        echo "Error: Cannot update configuration file" >&2
        rm -f "$temp_file"
        return 1
    fi
}

# Set simple YAML key
set_yaml_simple_key() {
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

# Set nested YAML key (2 levels)
set_yaml_nested_key() {
    local temp_file="$1"
    local parent_key="$2"
    local child_key="$3"
    local value="$4"

    if grep -q "^${parent_key}:" "$temp_file"; then
        # Parent section exists
        if grep -A20 "^${parent_key}:" "$temp_file" | grep -q "^[[:space:]]\+${child_key}:"; then
            # Child key exists, update it - preserve indentation
            sed -i "/^${parent_key}:/,/^[a-zA-Z]/ s/^[[:space:]]*${child_key}:[[:space:]]*.*$/  ${child_key}: $value/" "$temp_file"
        else
            # Child key doesn't exist, add it under the parent section
            sed -i "/^${parent_key}:/a\\  ${child_key}: $value" "$temp_file"
        fi
    else
        # Parent section doesn't exist, create both parent and child
        {
            echo ""
            echo "${parent_key}:"
            echo "  ${child_key}: $value"
        } >> "$temp_file"
    fi
}

# Set deep nested YAML key (3 levels)
set_yaml_deep_nested_key() {
    local temp_file="$1"
    local level1="$2"
    local level2="$3"
    local level3="$4"
    local value="$5"

    # This is a simplified implementation for 3-level nesting
    # For production, this would need more sophisticated handling
    if ! grep -q "^${level1}:" "$temp_file"; then
        # Create all levels
        {
            echo ""
            echo "${level1}:"
            echo "  ${level2}:"
            echo "    ${level3}: $value"
        } >> "$temp_file"
    elif ! grep -A50 "^${level1}:" "$temp_file" | grep -q "^[[:space:]]\+${level2}:"; then
        # Level1 exists, add level2 and level3
        sed -i "/^${level1}:/a\\  ${level2}:\\n    ${level3}: $value" "$temp_file"
    else
        # Both level1 and level2 exist, update or add level3
        local start_line
        start_line=$(grep -n "^${level1}:" "$temp_file" | head -n1 | cut -d: -f1)
        local level2_line
        level2_line=$(sed -n "${start_line},\$p" "$temp_file" | grep -n "^[[:space:]]\+${level2}:" | head -n1 | cut -d: -f1)

        if [[ -n "$level2_line" ]]; then
            local actual_line=$((start_line + level2_line - 1))
            if sed -n "${actual_line},\$p" "$temp_file" | grep -q "^[[:space:]]\{4,\}${level3}:"; then
                # Level3 exists, update it
                sed -i "${actual_line},\$s/^[[:space:]]*${level3}:[[:space:]]*.*$/    ${level3}: $value/" "$temp_file"
            else
                # Level3 doesn't exist, add it
                sed -i "${actual_line}a\\    ${level3}: $value" "$temp_file"
            fi
        fi
    fi
}

# Validate YAML file structure
validate_yaml_structure() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "Configuration file not found: $file" >&2
        return 1
    fi

    # Basic YAML structure validation
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

        # Check for inconsistent indentation (basic check)
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
        echo "Found $errors potential YAML structure issues" >&2
        return 1
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
                    yq eval '.' "$GLOBAL_CONFIG" 2>/dev/null || {
                        echo "Warning: yq failed, showing raw file" >&2
                        cat "$GLOBAL_CONFIG"
                    }
                else
                    cat "$GLOBAL_CONFIG"
                fi

                # Show validation status
                echo ""
                echo "=== Configuration Validation ==="
                if validate_yaml_structure "$GLOBAL_CONFIG"; then
                    echo "✓ YAML structure appears valid"
                else
                    echo "⚠ YAML structure has potential issues"
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
                    yq eval '.' "$module_config" 2>/dev/null || cat "$module_config"
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