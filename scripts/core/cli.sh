#!/bin/bash

# upKep CLI Interface
# Provides subcommands and interactive mode for upKep operations

# CLI version
CLI_VERSION="2.0.0"

# Show help information
show_help() {
    local command="${1:-}"

    case "$command" in
        "run")
            echo "Usage: upkep run [options]"
            echo ""
            echo "Execute maintenance operations"
            echo ""
            echo "Options:"
            echo "  --category=<category>    Execute modules in specific category"
            echo "  --module=<module>        Execute specific module only"
            echo "  --parallel              Run modules in parallel"
            echo "  --dry-run               Show what would be done without executing"
            echo "  --force                 Force execution regardless of intervals"
            echo "  --verbose               Show detailed output"
            echo ""
            echo "Examples:"
            echo "  upkep run                    # Run all enabled modules"
            echo "  upkep run --category=package_managers"
            echo "  upkep run --module=apt_update"
            echo "  upkep run --dry-run --verbose"
            ;;
        "status")
            echo "Usage: upkep status [options]"
            echo ""
            echo "Display current status and state information"
            echo ""
            echo "Options:"
            echo "  --module=<module>        Show status for specific module"
            echo "  --category=<category>    Show status for modules in category"
            echo "  --format=<format>        Output format (table, json, yaml)"
            echo "  --verbose               Show detailed information"
            echo ""
            echo "Examples:"
            echo "  upkep status                    # Show overall status"
            echo "  upkep status --module=apt_update"
            echo "  upkep status --format=json"
            ;;
        "config")
            echo "Usage: upkep config [options]"
            echo ""
            echo "Manage configuration settings"
            echo ""
            echo "Options:"
            echo "  --show                  Show current configuration"
            echo "  --set <key>=<value>     Set configuration value"
            echo "  --get <key>             Get configuration value (supports env var overrides)"
            echo "  --init                  Initialize configuration"
            echo "  --validate              Validate configuration"
            echo "  --export <format>       Export configuration"
            echo ""
            echo "Environment Variable Overrides:"
            echo "  UPKEP_DRY_RUN=true      Enable dry run mode"
            echo "  UPKEP_PARALLEL_EXECUTION=false  Disable parallel execution"
            echo "  UPKEP_LOGGING_LEVEL=debug       Set log level"
            echo ""
            echo "Examples:"
            echo "  upkep config --show"
            echo "  upkep config --set logging.level=debug"
            echo "  upkep config --get logging.level"
            echo "  UPKEP_LOGGING_LEVEL=debug upkep run     # Override log level"
            echo "  UPKEP_DRY_RUN=true upkep run            # Test mode"
            ;;
        "list-modules")
            echo "Usage: upkep list-modules [options]"
            echo ""
            echo "List available modules"
            echo ""
            echo "Options:"
            echo "  --category=<category>    Show modules in specific category"
            echo "  --type=<type>           Show modules by type (core, user)"
            echo "  --verbose               Show detailed module information"
            echo ""
            echo "Examples:"
            echo "  upkep list-modules"
            echo "  upkep list-modules --category=package_managers"
            echo "  upkep list-modules --type=user"
            ;;
        "create-module")
            echo "Usage: upkep create-module <name> [options]"
            echo ""
            echo "Create a new module"
            echo ""
            echo "Options:"
            echo "  --interactive           Interactive module creation"
            echo "  --ai-prompt             Generate AI prompt for module creation"
            echo "  --template=<template>   Use specific template (basic, advanced)"
            echo "  --category=<category>   Set module category"
            echo "  --description=<desc>    Set module description"
            echo ""
            echo "Examples:"
            echo "  upkep create-module docker-cleanup --interactive"
            echo "  upkep create-module security-audit --ai-prompt"
            echo "  upkep create-module backup-scripts --template=advanced"
            ;;
        "validate-module")
            echo "Usage: upkep validate-module <name>"
            echo ""
            echo "Validate a module's structure and interface"
            echo ""
            echo "Examples:"
            echo "  upkep validate-module apt_update"
            echo "  upkep validate-module docker-cleanup"
            ;;
        "test-module")
            echo "Usage: upkep test-module <name> [options]"
            echo ""
            echo "Test a module's functionality"
            echo ""
            echo "Options:"
            echo "  --dry-run               Test without making changes"
            echo "  --verbose               Show detailed test output"
            echo ""
            echo "Examples:"
            echo "  upkep test-module apt_update"
            echo "  upkep test-module cleanup --dry-run"
            ;;
        *)
            echo "upKep - Linux System Maintenance Tool"
            echo "Version: $CLI_VERSION"
            echo ""
            echo "Usage: upkep <command> [options]"
            echo ""
            echo "Commands:"
            echo "  run              Execute maintenance operations"
            echo "  status           Display current status"
            echo "  config           Manage configuration"
            echo "  list-modules     List available modules"
            echo "  create-module    Create a new module"
            echo "  validate-module  Validate a module"
            echo "  test-module      Test a module"
            echo "  help             Show this help message"
            echo ""
            echo "For detailed help on a command, use: upkep help <command>"
            echo ""
            echo "Examples:"
            echo "  upkep run                    # Run all maintenance operations"
            echo "  upkep status                 # Show current status"
            echo "  upkep list-modules           # List available modules"
            echo "  upkep create-module my-module --interactive"
            ;;
    esac
}

# Parse command line arguments
parse_args() {
    local args=("$@")
    local command=""
    local options=()

    # Extract command
    if [[ ${#args[@]} -gt 0 ]]; then
        command="${args[0]}"
        options=("${args[@]:1}")
    fi

    # Handle help command
    if [[ "$command" == "help" ]]; then
        show_help "${options[0]:-}"
        return 0
    fi

    # Handle version
    if [[ "$command" == "version" || "$command" == "--version" || "$command" == "-v" ]]; then
        echo "upKep version $CLI_VERSION"
        return 0
    fi

    # Execute command
    case "$command" in
        "run")
            execute_run_command "${options[@]}"
            ;;
        "status")
            execute_status_command "${options[@]}"
            ;;
        "config")
            execute_config_command "${options[@]}"
            ;;
        "list-modules")
            execute_list_modules_command "${options[@]}"
            ;;
        "create-module")
            execute_create_module_command "${options[@]}"
            ;;
        "validate-module")
            execute_validate_module_command "${options[@]}"
            ;;
        "test-module")
            execute_test_module_command "${options[@]}"
            ;;
        "")
            show_help
            ;;
        *)
            echo "Unknown command: $command"
            echo "Use 'upkep help' for available commands"
            return 1
            ;;
    esac
}

# Execute run command
execute_run_command() {
    local category=""
    local module=""
    local parallel=false
    local dry_run=false
    local force=false
    local verbose=false

    # Parse options
    for arg in "$@"; do
        case "$arg" in
            --category=*)
                category="${arg#*=}"
                ;;
            --module=*)
                module="${arg#*=}"
                ;;
            --parallel)
                parallel=true
                ;;
            --dry-run)
                dry_run=true
                ;;
            --force)
                force=true
                ;;
            --verbose)
                verbose=true
                ;;
            *)
                echo "Unknown option: $arg"
                return 1
                ;;
        esac
    done

    # Execute maintenance operations
    echo "Executing upKep maintenance operations..."

    if [[ "$dry_run" == "true" ]]; then
        echo "DRY RUN MODE - No changes will be made"
    fi

    if [[ "$parallel" == "true" ]]; then
        echo "Parallel execution enabled"
    fi

    if [[ -n "$module" ]]; then
        echo "Executing module: $module"
        # TODO: Execute specific module
    elif [[ -n "$category" ]]; then
        echo "Executing modules in category: $category"
        # TODO: Execute modules in category
    else
        echo "Executing all enabled modules"
        # TODO: Execute all modules
    fi
}

# Execute status command
execute_status_command() {
    local module=""
    local category=""
    local format="table"
    local verbose=false

    # Parse options
    for arg in "$@"; do
        case "$arg" in
            --module=*)
                module="${arg#*=}"
                ;;
            --category=*)
                category="${arg#*=}"
                ;;
            --format=*)
                format="${arg#*=}"
                ;;
            --verbose)
                verbose=true
                ;;
            *)
                echo "Unknown option: $arg"
                return 1
                ;;
        esac
    done

    # Show status information
    echo "upKep Status Information"
    echo "========================"

    if [[ -n "$module" ]]; then
        echo "Module: $module"
        # TODO: Show module-specific status
    elif [[ -n "$category" ]]; then
        echo "Category: $category"
        # TODO: Show category status
    else
        # Show overall status
        show_current_status
    fi
}

# Execute config command
execute_config_command() {
    local action=""
    local key=""
    local value=""
    local format=""

    # Parse options
    for arg in "$@"; do
        case "$arg" in
            --show)
                action="show"
                ;;
            --set)
                action="set"
                ;;
            --get)
                action="get"
                ;;
            --init)
                action="init"
                ;;
            --validate)
                action="validate"
                ;;
            --export)
                action="export"
                ;;
            --format=*)
                format="${arg#*=}"
                ;;
            *)
                if [[ "$action" == "set" && -z "$key" ]]; then
                    key="${arg%%=*}"
                    value="${arg#*=}"
                elif [[ "$action" == "get" && -z "$key" ]]; then
                    key="$arg"
                else
                    echo "Unknown option: $arg"
                    return 1
                fi
                ;;
        esac
    done

    # Execute config action
    case "$action" in
        "show")
            show_config
            ;;
        "set")
            if [[ -n "$key" && -n "$value" ]]; then
                set_global_config "$key" "$value"
                echo "Set $key = $value"
            else
                echo "Usage: upkep config --set <key>=<value>"
                return 1
            fi
            ;;
        "get")
            if [[ -n "$key" ]]; then
                local val=$(get_config "$key")
                echo "$key = $val"
            else
                echo "Usage: upkep config --get <key>"
                return 1
            fi
            ;;
        "init")
            init_config
            ;;
        "validate")
            validate_config "$GLOBAL_CONFIG"
            ;;
        "export")
            export_config "${format:-json}"
            ;;
        "")
            echo "Usage: upkep config [options]"
            echo "Use 'upkep help config' for detailed help"
            return 1
            ;;
    esac
}

# Execute list-modules command
execute_list_modules_command() {
    local category=""
    local type=""
    local verbose=false

    # Parse options
    for arg in "$@"; do
        case "$arg" in
            --category=*)
                category="${arg#*=}"
                ;;
            --type=*)
                type="${arg#*=}"
                ;;
            --verbose)
                verbose=true
                ;;
            *)
                echo "Unknown option: $arg"
                return 1
                ;;
        esac
    done

    # List modules
    if [[ -n "$category" ]]; then
        list_modules_by_category "$category"
    elif [[ -n "$type" ]]; then
        echo "Modules of type '$type':"
        get_modules_by_type "$type"
    else
        list_all_modules
    fi
}

# Execute create-module command
execute_create_module_command() {
    local module_name=""
    local interactive=false
    local ai_prompt=false
    local template="basic"
    local category=""
    local description=""

    # Parse options
    for arg in "$@"; do
        case "$arg" in
            --interactive)
                interactive=true
                ;;
            --ai-prompt)
                ai_prompt=true
                ;;
            --template=*)
                template="${arg#*=}"
                ;;
            --category=*)
                category="${arg#*=}"
                ;;
            --description=*)
                description="${arg#*=}"
                ;;
            *)
                if [[ -z "$module_name" ]]; then
                    module_name="$arg"
                else
                    echo "Unknown option: $arg"
                    return 1
                fi
                ;;
        esac
    done

    if [[ -z "$module_name" ]]; then
        echo "Usage: upkep create-module <name> [options]"
        return 1
    fi

    echo "Creating module: $module_name"

    if [[ "$interactive" == "true" ]]; then
        create_module_interactive "$module_name"
    elif [[ "$ai_prompt" == "true" ]]; then
        generate_ai_prompt "$module_name" "$description" "$category"
    else
        create_module_from_template "$module_name" "$template" "$category" "$description"
    fi
}

# Execute validate-module command
execute_validate_module_command() {
    local module_name="$1"

    if [[ -z "$module_name" ]]; then
        echo "Usage: upkep validate-module <name>"
        return 1
    fi

    echo "Validating module: $module_name"

    if module_exists "$module_name"; then
        local module_file=$(get_module_file "$module_name")
        if validate_module_structure "$module_file"; then
            echo "✓ Module $module_name is valid"
            return 0
        else
            echo "✗ Module $module_name has validation errors"
            return 1
        fi
    else
        echo "Module not found: $module_name"
        return 1
    fi
}

# Execute test-module command
execute_test_module_command() {
    local module_name="$1"
    local dry_run=false
    local verbose=false

    # Parse options
    shift
    for arg in "$@"; do
        case "$arg" in
            --dry-run)
                dry_run=true
                ;;
            --verbose)
                verbose=true
                ;;
            *)
                echo "Unknown option: $arg"
                return 1
                ;;
        esac
    done

    if [[ -z "$module_name" ]]; then
        echo "Usage: upkep test-module <name> [options]"
        return 1
    fi

    echo "Testing module: $module_name"

    if [[ "$dry_run" == "true" ]]; then
        echo "DRY RUN MODE - No actual execution"
    fi

    if module_exists "$module_name"; then
        # TODO: Implement module testing
        echo "Module test functionality not yet implemented"
    else
        echo "Module not found: $module_name"
        return 1
    fi
}

# Create module interactively
create_module_interactive() {
    local module_name="$1"

    echo "Interactive module creation for: $module_name"
    echo "============================================="

    # Get module details
    read -p "Description: " description
    read -p "Category [system_maintenance]: " category
    category="${category:-system_maintenance}"
    read -p "Template [basic]: " template
    template="${template:-basic}"

    create_module_from_template "$module_name" "$template" "$category" "$description"
}

# Create module from template
create_module_from_template() {
    local module_name="$1"
    local template="$2"
    local category="$3"
    local description="$4"

    local user_modules_dir="$HOME/.upkep/modules"
    local module_file="$user_modules_dir/${module_name}.sh"

    mkdir -p "$user_modules_dir"

    case "$template" in
        "basic")
            create_basic_module_template "$module_file" "$module_name" "$category" "$description"
            ;;
        "advanced")
            create_advanced_module_template "$module_file" "$module_name" "$category" "$description"
            ;;
        *)
            echo "Unknown template: $template"
            return 1
            ;;
    esac

    echo "Created module: $module_file"
    echo "You can now edit the module and test it with: upkep test-module $module_name"
}

# Create basic module template
create_basic_module_template() {
    local module_file="$1"
    local module_name="$2"
    local category="$3"
    local description="$4"

    cat > "$module_file" << EOF
#!/bin/bash

# upKep Module: $module_name
# Description: $description
# Category: $category

# Required status variables
${module_name^^}_STATUS="skipped"
${module_name^^}_MESSAGE=""
${module_name^^}_ERROR=""

# Main execution function
run_${module_name}() {
    echo "Executing $module_name..."

    # TODO: Implement your module logic here

    # Example implementation:
    # if your_command; then
    #     ${module_name^^}_STATUS="success"
    #     ${module_name^^}_MESSAGE="Operation completed successfully"
    #     update_${module_name}_state
    # else
    #     ${module_name^^}_STATUS="failed"
    #     ${module_name^^}_ERROR="Operation failed"
    # fi

    # Placeholder - always succeeds
    ${module_name^^}_STATUS="success"
    ${module_name^^}_MESSAGE="Module executed successfully"
    update_${module_name}_state
}

# State update function
update_${module_name}_state() {
    update_module_state "$module_name" "\${${module_name^^}_STATUS}" "\${${module_name^^}_MESSAGE}"
}

# Optional: Status function
get_${module_name}_status() {
    echo "Status: \${${module_name^^}_STATUS}"
    echo "Message: \${${module_name^^}_MESSAGE}"
    if [[ -n "\${${module_name^^}_ERROR}" ]]; then
        echo "Error: \${${module_name^^}_ERROR}"
    fi
}

# Optional: Environment validation
validate_${module_name}_environment() {
    # TODO: Add validation logic
    # Example: Check if required commands exist
    # if ! command -v your_command >/dev/null 2>&1; then
    #     echo "Required command 'your_command' not found"
    #     return 1
    # fi
    return 0
}
EOF

    chmod +x "$module_file"
}

# Create advanced module template
create_advanced_module_template() {
    local module_file="$1"
    local module_name="$2"
    local category="$3"
    local description="$4"

    cat > "$module_file" << EOF
#!/bin/bash

# upKep Module: $module_name
# Description: $description
# Category: $category
# Version: 1.0.0

# Required status variables
${module_name^^}_STATUS="skipped"
${module_name^^}_MESSAGE=""
${module_name^^}_ERROR=""
${module_name^^}_DURATION=0

# Configuration
${module_name^^}_CONFIG_FILE=""
${module_name^^}_LOG_FILE=""

# Initialize module
init_${module_name}() {
    ${module_name^^}_CONFIG_FILE="\$(get_module_config "$module_name" "config_file" "")"
    ${module_name^^}_LOG_FILE="\$(get_module_config "$module_name" "log_file" "")"

    # Create log directory if needed
    if [[ -n "\${${module_name^^}_LOG_FILE}" ]]; then
        mkdir -p "\$(dirname "\${${module_name^^}_LOG_FILE}")"
    fi
}

# Main execution function
run_${module_name}() {
    local start_time=\$(date +%s)

    echo "Executing $module_name..."

    # Initialize module
    init_${module_name}

    # Validate environment
    if ! validate_${module_name}_environment; then
        ${module_name^^}_STATUS="failed"
        ${module_name^^}_ERROR="Environment validation failed"
        ${module_name^^}_DURATION=\$(( \$(date +%s) - start_time ))
        update_${module_name}_state
        return 1
    fi

    # TODO: Implement your module logic here

    # Example implementation with error handling:
    # if your_command; then
    #     ${module_name^^}_STATUS="success"
    #     ${module_name^^}_MESSAGE="Operation completed successfully"
    # else
    #     ${module_name^^}_STATUS="failed"
    #     ${module_name^^}_ERROR="Operation failed: \$?"
    # fi

    # Placeholder - always succeeds
    ${module_name^^}_STATUS="success"
    ${module_name^^}_MESSAGE="Module executed successfully"
    ${module_name^^}_DURATION=\$(( \$(date +%s) - start_time ))
    update_${module_name}_state
}

# State update function
update_${module_name}_state() {
    update_module_state "$module_name" "\${${module_name^^}_STATUS}" "\${${module_name^^}_MESSAGE}" "\${${module_name^^}_DURATION}"
}

# Status function
get_${module_name}_status() {
    echo "Module: $module_name"
    echo "Status: \${${module_name^^}_STATUS}"
    echo "Message: \${${module_name^^}_MESSAGE}"
    echo "Duration: \${${module_name^^}_DURATION}s"
    if [[ -n "\${${module_name^^}_ERROR}" ]]; then
        echo "Error: \${${module_name^^}_ERROR}"
    fi
}

# Environment validation
validate_${module_name}_environment() {
    # TODO: Add comprehensive validation logic
    # Example validations:
    # - Check required commands
    # - Check required permissions
    # - Check required files/directories
    # - Check system requirements

    # if ! command -v your_command >/dev/null 2>&1; then
    #     echo "Required command 'your_command' not found"
    #     return 1
    # fi

    return 0
}

# Configuration management
get_${module_name}_config() {
    local key="\$1"
    local default_value="\$2"
    get_module_config "$module_name" "\$key" "\$default_value"
}

# Logging function
log_${module_name}() {
    local level="\$1"
    local message="\$2"
    local timestamp="\$(date '+%Y-%m-%d %H:%M:%S')"

    if [[ -n "\${${module_name^^}_LOG_FILE}" ]]; then
        echo "[\$timestamp] [\$level] \$message" >> "\${${module_name^^}_LOG_FILE}"
    fi
}
EOF

    chmod +x "$module_file"
}

# Generate AI prompt for module creation
generate_ai_prompt() {
    local module_name="$1"
    local description="$2"
    local category="$3"

    echo "Generating AI prompt for module: $module_name"
    echo "============================================="

    # TODO: Implement AI prompt generation based on state reflection
    # This would use the state reflection system to generate contextual prompts

    local prompt_file="prompt_for_${module_name}.txt"

    cat > "$prompt_file" << EOF
# upKep Module Creation Prompt
# Generated: \$(date)
# Module: $module_name
# Category: ${category:-system_maintenance}

## Project Context
This upKep project manages Linux system maintenance with modular architecture.

## Module Requirements
Create a new upKep module named "$module_name" that:
- Description: ${description:-"Module for $module_name operations"}
- Category: ${category:-system_maintenance}
- Follows the established patterns and conventions
- Integrates seamlessly with existing modules

## Required Functions
The module must implement these functions:
1. run_${module_name}() - Main execution function
2. get_${module_name}_status() - Status reporting (optional)
3. validate_${module_name}_environment() - Environment validation (optional)

## Required Variables
The module must set these status variables:
- ${module_name^^}_STATUS="success" or "failed" or "skipped"
- ${module_name^^}_MESSAGE="Human readable status message"
- ${module_name^^}_ERROR="Error details if failed" (optional)

## State Management
If the module updates system state, call:
- update_${module_name}_state() (create this function)

## Error Handling
Follow the established pattern:
if [[ \$? -eq 0 ]]; then
    ${module_name^^}_STATUS="success"
    update_${module_name}_state
else
    ${module_name^^}_STATUS="failed"
    ${module_name^^}_ERROR="Error description"
fi

## Output Format
Please provide:
1. Complete module script (${module_name}.sh)
2. Module metadata (module.json)
3. Brief usage examples
4. Any dependencies or requirements

## Integration Notes
- The module will be loaded dynamically at runtime
- It should work with existing flags (--dry-run, --force, --verbose)
- Follow the same visual formatting patterns as other modules
- Include appropriate error handling and logging
EOF

    echo "AI prompt generated: $prompt_file"
    echo "You can copy this prompt to your preferred AI tool for module generation."
}