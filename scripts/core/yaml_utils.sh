#!/bin/bash
# yaml_utils.sh - Enhanced YAML parsing utilities for upKep

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

# Enhanced YAML parsing - primary function
# This function provides robust YAML parsing with yq as optional enhancement
get_yaml_config() {
    local file="$1"
    local key="$2"
    local default="$3"

    if [[ -f "$file" ]]; then
        # Try yq first if available (optional enhancement)
        if command -v yq >/dev/null 2>&1; then
            local value
            value=$(yq eval ".$key" "$file" 2>/dev/null)
            if [[ "$value" != "null" && -n "$value" && "$value" != "null" ]]; then
                echo "$value"
                return 0
            fi
        fi

        # Enhanced fallback method - more robust than before
        local value found
        value=$(get_config_value_enhanced_fallback "$file" "$key")
        found=$?
        if [[ $found -eq 0 ]]; then
            echo "$value"
            return 0
        fi
    fi

    echo "$default"
}

# Enhanced fallback YAML parsing method
# More robust than the previous version, handles deeper nesting and edge cases
get_config_value_enhanced_fallback() {
    local file="$1"
    local key="$2"
    local path_parts
    IFS='.' read -r -a path_parts <<< "$key" 2>/dev/null || {
        # Fallback for shells that don't support read -a
        path_parts=($(echo "$key" | tr '.' ' '))
    }
    local depth=${#path_parts[@]}

    # Handle different depths of nesting
    case $depth in
        1)
            # Simple key (no dots)
            get_yaml_simple_key "$file" "${path_parts[0]}"
            ;;
        2)
            # Two-level nesting (e.g., defaults.update_interval)
            get_yaml_nested_key "$file" "${path_parts[0]}" "${path_parts[1]}"
            ;;
        3)
            # Three-level nesting (e.g., modules.apt_update.enabled)
            get_yaml_deep_nested_key "$file" "${path_parts[0]}" "${path_parts[1]}" "${path_parts[2]}"
            ;;
        *)
            # For deeper nesting, fall back to a more generic approach
            get_yaml_generic_path "$file" "$key"
            ;;
    esac
}

# Parse simple YAML key (no nesting)
get_yaml_simple_key() {
    local file="$1"
    local key="$2"
    local value

    # Check if key exists first
    if ! grep -q "^${key}:[[:space:]]*" "$file" 2>/dev/null; then
        return 1  # Key not found
    fi

    # Match key at start of line followed by colon
    local raw_line
    raw_line=$(grep "^${key}:[[:space:]]*" "$file" 2>/dev/null | head -n1)

    # Extract and process value through centralized functions
    value=$(extract_simple_yaml_value "$raw_line")
    value=$(smart_quote_removal "$value")
    format_yaml_value "$value"

    return 0  # Key found (even if empty)
}

# Parse two-level nested YAML key (e.g., parent.child)
get_yaml_nested_key() {
    local file="$1"
    local parent_key="$2"
    local child_key="$3"
    local in_section=false
    local value

    while IFS= read -r line; do
        # Skip comments and empty lines
        if should_skip_yaml_line "$line"; then
            continue
        fi

        # Check if we've entered the parent section
        if [[ "$line" =~ ^${parent_key}:[[:space:]]*$ ]]; then
            in_section=true
            continue
        fi

        # If we're in the section, look for the child key
        if [[ "$in_section" == true ]]; then
            # Check if we've left the parent section (new top-level key)
            if [[ "$line" =~ ^[^[:space:]] ]] && [[ ! "$line" =~ ^[[:space:]]*${child_key}: ]]; then
                break  # Left the parent section
            fi

            # Look for the child key with proper indentation
            if [[ "$line" =~ ^[[:space:]]+${child_key}:[[:space:]]* ]]; then
                value=$(extract_indented_yaml_value "$line")
                value=$(smart_quote_removal "$value")
                format_yaml_value "$value"
                return 0
            fi
        fi
    done < "$file"

    return 1  # Key not found
}

# Parse three-level nested YAML key (e.g., grandparent.parent.child)
get_yaml_deep_nested_key() {
    local file="$1"
    local grandparent_key="$2"
    local parent_key="$3"
    local child_key="$4"
    local in_grandparent=false
    local in_parent=false
    local value

    while IFS= read -r line; do
        # Skip comments and empty lines
        if should_skip_yaml_line "$line"; then
            continue
        fi

        # Check if we've entered the grandparent section
        if [[ "$line" =~ ^${grandparent_key}:[[:space:]]*$ ]]; then
            in_grandparent=true
            in_parent=false
            continue
        fi

        # If we're in the grandparent section
        if [[ "$in_grandparent" == true ]]; then
            # Check if we've left the grandparent section (new top-level key)
            if [[ "$line" =~ ^[^[:space:]] ]]; then
                break  # Left the grandparent section
            fi

            # Look for the parent key with proper indentation
            if [[ "$line" =~ ^[[:space:]]+${parent_key}:[[:space:]]*$ ]]; then
                in_parent=true
                continue
            fi

            # If we're in the parent section, look for the child key
            if [[ "$in_parent" == true ]]; then
                # Check if we've left the parent section (new second-level key at same indent as parent)
                # This should only trigger for keys at the same level as the parent (e.g., other modules)
                if [[ "$line" =~ ^[[:space:]]+[^[:space:]] ]] && [[ ! "$line" =~ ^[[:space:]]+[[:space:]]+ ]]; then
                    # This is a sibling of the parent key, so we've left the parent section
                    in_parent=false
                    continue
                fi

                # Look for the child key with proper indentation (third level)
                if [[ "$line" =~ ^[[:space:]]+[[:space:]]+${child_key}:[[:space:]]* ]]; then
                    value=$(extract_indented_yaml_value "$line")
                    value=$(smart_quote_removal "$value")
                    format_yaml_value "$value"
                    return 0
                fi
            fi
        fi
    done < "$file"

    return 1  # Key not found
}

# Generic path-based YAML parsing for deeper nesting
get_yaml_generic_path() {
    local file="$1"
    local key="$2"
    local path_parts
    IFS='.' read -r -a path_parts <<< "$key" 2>/dev/null || {
        # Fallback for shells that don't support read -a
        path_parts=($(echo "$key" | tr '.' ' '))
    }
    local depth=${#path_parts[@]}
    local current_level=0
    local in_sections=()
    local expected_indent=""
    local value

    # Initialize section tracking array
    for ((i=0; i<depth; i++)); do
        in_sections[i]=false
    done

    while IFS= read -r line; do
        # Skip comments and empty lines
        if should_skip_yaml_line "$line"; then
            continue
        fi

        # Calculate the indentation level of current line
        local line_indent=""
        if [[ "$line" =~ ^([[:space:]]*) ]]; then
            line_indent="${BASH_REMATCH[1]}"
        fi
        local indent_spaces=${#line_indent}

        # Check each level of nesting
        for ((level=0; level<depth; level++)); do
            local expected_spaces=$((level * 2))  # Assuming 2-space indentation
            local key_pattern="^[[:space:]]{$expected_spaces}${path_parts[level]}:[[:space:]]*"

            # If we're at the correct indentation level for this key
            if [[ $indent_spaces -eq $expected_spaces ]]; then
                if [[ "$line" =~ ^[[:space:]]*${path_parts[level]}:[[:space:]]* ]]; then
                    # Found the key at this level
                    in_sections[level]=true

                    # Reset deeper levels
                    for ((reset_level=$((level+1)); reset_level<depth; reset_level++)); do
                        in_sections[reset_level]=false
                    done

                    # If this is the final level, extract the value
                    if [[ $level -eq $((depth-1)) ]]; then
                        value=$(extract_indented_yaml_value "$line")
                        value=$(smart_quote_removal "$value")
                        format_yaml_value "$value"
                        return 0
                    fi
                    break
                else
                    # We've hit a sibling at this level, reset this and deeper levels
                    for ((reset_level=level; reset_level<depth; reset_level++)); do
                        in_sections[reset_level]=false
                    done
                fi
            fi
        done

        # Check if we're in all the required parent sections for the final key
        local all_parents_found=true
        for ((check_level=0; check_level<$((depth-1)); check_level++)); do
            if [[ "${in_sections[check_level]}" != "true" ]]; then
                all_parents_found=false
                break
            fi
        done
    done < "$file"

    return 1  # Key not found
}

# Set YAML configuration value
set_yaml_config() {
    local file="$1"
    local key="$2"
    local new_value="$3"

    # Try yq first if available
    if command -v yq >/dev/null 2>&1; then
        yq eval ".$key = \"$new_value\"" -i "$file" 2>/dev/null && return 0
    fi

    # Fallback bash implementation would go here
    # For now, just return error if yq is not available
    return 1
}

# Validate YAML file structure
validate_yaml_structure() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    # Try yq validation if available
    if command -v yq >/dev/null 2>&1; then
        yq eval . "$file" >/dev/null 2>&1
        return $?
    fi

    # Basic validation - check for balanced quotes and basic structure
    local line_num=0
    while IFS= read -r line; do
        ((line_num++))

        # Skip comments and empty lines
        if should_skip_yaml_line "$line"; then
            continue
        fi

        # Check for unbalanced quotes (basic check)
        local double_quotes=$(echo "$line" | grep -o '"' | wc -l)
        local single_quotes=$(echo "$line" | grep -o "'" | wc -l)

        if [[ $((double_quotes % 2)) -ne 0 ]] || [[ $((single_quotes % 2)) -ne 0 ]]; then
            echo "YAML validation error at line $line_num: unbalanced quotes"
            return 1
        fi
    done < "$file"

    return 0
}

# Export functions for use by other scripts
export -f smart_quote_removal extract_simple_yaml_value extract_indented_yaml_value
export -f format_yaml_value should_skip_yaml_line get_yaml_config
export -f get_config_value_enhanced_fallback get_yaml_simple_key get_yaml_nested_key
export -f get_yaml_deep_nested_key get_yaml_generic_path set_yaml_config validate_yaml_structure