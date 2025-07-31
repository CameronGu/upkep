#!/bin/bash
# upKep Layout Builder - DSL v2 with Explicit Parameters
# Provides unambiguous attribute declaration using explicit parameter names

source "${SCRIPT_DIR}/box_builder.sh"

# Parse command line arguments with explicit parameter names
parse_dsl_args() {
    local -A args
    local content=""
    local current_arg=""
    
    for arg in "$@"; do
        case "$arg" in
            --title=*)
                args[title]="${arg#--title=}"
                ;;
            --content=*)
                args[content]="${arg#--content=}"
                ;;
            --style=*)
                args[style]="${arg#--style=}"
                ;;
            --width=*)
                args[width]="${arg#--width=}"
                ;;
            --color=*)
                args[color]="${arg#--color=}"
                ;;
            --emoji=*)
                args[emoji]="${arg#--emoji=}"
                ;;
            --message=*)
                args[message]="${arg#--message=}"
                ;;
            --progress=*)
                args[progress]="${arg#--progress=}"
                ;;
            *)
                # If no explicit parameter, treat as content
                if [[ -z "${args[content]}" ]]; then
                    args[content]="$arg"
                else
                    args[content]="${args[content]} $arg"
                fi
                ;;
        esac
    done
    
    echo "${args[@]}"
}

# Create a box with explicit parameters
create_box() {
    local title=""
    local content=""
    local style="info"
    local width="50"
    local color=""
    local emoji=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --title=*)
                title="${1#--title=}"
                shift
                ;;
            --content=*)
                content="${1#--content=}"
                shift
                ;;
            --style=*)
                style="${1#--style=}"
                shift
                ;;
            --width=*)
                width="${1#--width=}"
                shift
                ;;
            --color=*)
                color="${1#--color=}"
                shift
                ;;
            --emoji=*)
                emoji="${1#--emoji=}"
                shift
                ;;
            *)
                # If no explicit parameter, treat as content
                if [[ -z "$content" ]]; then
                    content="$1"
                else
                    content="$content $1"
                fi
                shift
                ;;
        esac
    done
    
    local box_data=$(box_new "$width" "$title" "$style")
    local row_data=$(row_new)
    
    # Build cell content
    local cell_content=""
    if [[ -n "$emoji" ]]; then
        cell_content="$emoji "
    fi
    
    if [[ -n "$color" ]]; then
        cell_content="${cell_content}$(make_html "<color=$color>$content</color>")"
    else
        cell_content="${cell_content}$(make_text "$content")"
    fi
    
    row_data=$(row_add_cell "$row_data" "$cell_content")
    box_data=$(box_add_row "$box_data" "$row_data")
    box_render "$box_data"
}

# Convenience functions with explicit parameters
create_success_box() {
    create_box --style="success" --color="success" --emoji="✅" "$@"
}

create_warning_box() {
    create_box --style="warning" --color="warning" --emoji="⚠️" "$@"
}

create_error_box() {
    create_box --style="error" --color="error" --emoji="❌" "$@"
}

create_info_box() {
    create_box --style="info" --color="info" --emoji="ℹ️" "$@"
}

# Create a table with explicit parameters
create_table() {
    local title=""
    local width="60"
    local style="info"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --title=*)
                title="${1#--title=}"
                shift
                ;;
            --width=*)
                width="${1#--width=}"
                shift
                ;;
            --style=*)
                style="${1#--style=}"
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    local box_data=$(box_new "$width" "$title" "$style")
    
    # Add header row
    local row_data=$(row_new)
    for header in "$@"; do
        row_data=$(row_add_cell "$row_data" "$(make_text "$header")")
    done
    box_data=$(box_add_row "$box_data" "$row_data")
    
    box_render "$box_data"
}

# Create a dashboard with explicit parameters
create_dashboard() {
    local title=""
    local width="70"
    local style="major"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --title=*)
                title="${1#--title=}"
                shift
                ;;
            --width=*)
                width="${1#--width=}"
                shift
                ;;
            --style=*)
                style="${1#--style=}"
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    local box_data=$(box_new "$width" "$title" "$style")
    
    # Add info rows
    for info in "$@"; do
        local row_data=$(row_new)
        row_data=$(row_add_cell "$row_data" "$(make_text "$info")")
        box_data=$(box_add_row "$box_data" "$row_data")
    done
    
    box_render "$box_data"
}

# Create a progress box with explicit parameters
create_progress() {
    local title=""
    local message=""
    local progress=""
    local emoji="🔄"
    local width="60"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --title=*)
                title="${1#--title=}"
                shift
                ;;
            --message=*)
                message="${1#--message=}"
                shift
                ;;
            --progress=*)
                progress="${1#--progress=}"
                shift
                ;;
            --emoji=*)
                emoji="${1#--emoji=}"
                shift
                ;;
            --width=*)
                width="${1#--width=}"
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    local box_data=$(box_new "$width" "$title" "info")
    local row_data=$(row_new)
    row_data=$(row_add_cell "$row_data" "$(make_html "$emoji $message: $progress")")
    box_data=$(box_add_row "$box_data" "$row_data")
    box_render "$box_data"
}

# Legacy compatibility functions
create_quick_box() {
    create_box "$@"
}

create_colored_box() {
    local title="$1"
    local content="$2"
    local color="$3"
    local style="${4:-info}"
    local width="${5:-50}"
    
    create_box --title="$title" --content="$content" --color="$color" --style="$style" --width="$width"
}

create_status_box() {
    local title="$1"
    local emoji="$2"
    local message="$3"
    local color="${4:-info}"
    local style="${5:-info}"
    local width="${6:-60}"
    
    create_box --title="$title" --content="$message" --emoji="$emoji" --color="$color" --style="$style" --width="$width"
}

create_progress_box() {
    local title="$1"
    local emoji="$2"
    local message="$3"
    local progress="$4"
    local width="${5:-60}"
    
    create_progress --title="$title" --message="$message" --progress="$progress" --emoji="$emoji" --width="$width"
}

create_dashboard_box() {
    local title="$1"
    local width="${2:-70}"
    shift 2
    
    create_dashboard --title="$title" --width="$width" "$@"
}

create_quick_table() {
    local title="$1"
    local width="${2:-60}"
    shift 2
    
    create_table --title="$title" --width="$width" "$@"
}

# Advanced Layout Functions

# Create a multi-line box with explicit parameters
create_multiline_box() {
    local title=""
    local style="info"
    local width="60"
    local lines=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --title=*)
                title="${1#--title=}"
                shift
                ;;
            --style=*)
                style="${1#--style=}"
                shift
                ;;
            --width=*)
                width="${1#--width=}"
                shift
                ;;
            *)
                # Treat as content lines
                lines+=("$1")
                shift
                ;;
        esac
    done
    
    local box_data=$(box_new "$width" "$title" "$style")
    
    # Add each line as a separate row
    for line in "${lines[@]}"; do
        local row_data=$(row_new)
        row_data=$(row_add_cell "$row_data" "$(make_text "$line")")
        box_data=$(box_add_row "$box_data" "$row_data")
    done
    
    box_render "$box_data"
}

# Create a table with headers and data rows
create_table() {
    local title=""
    local width="80"
    local style="info"
    local headers=()
    local data_rows=()
    local current_section="headers"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --title=*)
                title="${1#--title=}"
                shift
                ;;
            --width=*)
                width="${1#--width=}"
                shift
                ;;
            --style=*)
                style="${1#--style=}"
                shift
                ;;
            --headers)
                current_section="headers"
                shift
                ;;
            --data)
                current_section="data"
                shift
                ;;
            --divider)
                data_rows+=("divider")
                shift
                ;;
            *)
                if [[ "$current_section" == "headers" ]]; then
                    headers+=("$1")
                else
                    data_rows+=("$1")
                fi
                shift
                ;;
        esac
    done
    
    local box_data=$(box_new "$width" "$title" "$style")
    
    # Add header row
    if (( ${#headers[@]} > 0 )); then
        local row_data=$(row_new)
        for header in "${headers[@]}"; do
            row_data=$(row_add_cell "$row_data" "$(make_text "$header")")
        done
        box_data=$(box_add_row "$box_data" "$row_data")
    fi
    
    # Add data rows
    for row_data in "${data_rows[@]}"; do
        if [[ "$row_data" == "divider" ]]; then
            box_data=$(box_add_row "$box_data" "divider")
        else
            local row=$(row_new)
            # Split row data by | character
            IFS='|' read -ra cells <<< "$row_data"
            for cell in "${cells[@]}"; do
                # Check if cell contains HTML-like content
                if [[ "$cell" =~ \<.*\> ]]; then
                    row=$(row_add_cell "$row" "$(make_html "$cell")")
                else
                    row=$(row_add_cell "$row" "$(make_text "$cell")")
                fi
            done
            box_data=$(box_add_row "$box_data" "$row")
        fi
    done
    
    box_render "$box_data"
}

# Create a status report with sections
create_status_report() {
    local title=""
    local width="80"
    local style="major"
    local sections=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --title=*)
                title="${1#--title=}"
                shift
                ;;
            --width=*)
                width="${1#--width=}"
                shift
                ;;
            --style=*)
                style="${1#--style=}"
                shift
                ;;
            --section=*)
                sections+=("${1#--section=}")
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    local box_data=$(box_new "$width" "$title" "$style")
    
    # Add each section
    for section in "${sections[@]}"; do
        # Split section by | to get title and content
        IFS='|' read -ra section_parts <<< "$section"
        local section_title="${section_parts[0]}"
        local section_content="${section_parts[1]:-}"
        
        # Add section header
        local row_data=$(row_new)
        row_data=$(row_add_cell "$row_data" "$(make_html "<color=info>$section_title</color>")")
        box_data=$(box_add_row "$box_data" "$row_data")
        
        # Add section content if provided
        if [[ -n "$section_content" ]]; then
            row_data=$(row_new)
            row_data=$(row_add_cell "$row_data" "$(make_text "$section_content")")
            box_data=$(box_add_row "$box_data" "$row_data")
        fi
        
        # Add divider (except for last section)
        if [[ "$section" != "${sections[-1]}" ]]; then
            box_data=$(box_add_row "$box_data" "divider")
        fi
    done
    
    box_render "$box_data"
}

# Create a comparison table
create_comparison_table_advanced() {
    local title=""
    local width="70"
    local style="info"
    local comparisons=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --title=*)
                title="${1#--title=}"
                shift
                ;;
            --width=*)
                width="${1#--width=}"
                shift
                ;;
            --style=*)
                style="${1#--style=}"
                shift
                ;;
            *)
                comparisons+=("$1")
                shift
                ;;
        esac
    done
    
    local box_data=$(box_new "$width" "$title" "$style")
    
    # Add header
    local row_data=$(row_new)
    row_data=$(row_add_cell "$row_data" "$(make_text "Item")")
    row_data=$(row_add_cell "$row_data" "$(make_text "Value")")
    box_data=$(box_add_row "$box_data" "$row_data")
    
    # Add divider
    box_data=$(box_add_row "$box_data" "divider")
    
    # Add comparison rows
    for ((i=0; i<${#comparisons[@]}; i+=2)); do
        local label="${comparisons[$i]}"
        local value="${comparisons[$i+1]:-}"
        
        row_data=$(row_new)
        row_data=$(row_add_cell "$row_data" "$(make_text "$label")")
        row_data=$(row_add_cell "$row_data" "$(make_text "$value")")
        box_data=$(box_add_row "$box_data" "$row_data")
    done
    
    box_render "$box_data"
}

# Legacy compatibility functions
create_quick_table() {
    local title="$1"
    local width="${2:-60}"
    shift 2
    
    create_table --title="$title" --width="$width" --headers "$@"
}

create_dashboard_box() {
    local title="$1"
    local width="${2:-70}"
    shift 2
    
    local sections=()
    for info in "$@"; do
        sections+=("Info|$info")
    done
    
    create_status_report --title="$title" --width="$width" "${sections[@]}"
}

create_comparison_table() {
    local title="$1"
    local width="${2:-80}"
    shift 2
    
    local box_data=$(box_new "$width" "$title" "info")
    
    # Add header
    local row_data=$(row_new)
    row_data=$(row_add_cell "$row_data" "$(make_text "Item")")
    row_data=$(row_add_cell "$row_data" "$(make_text "Value")")
    box_data=$(box_add_row "$box_data" "$row_data")
    
    # Add divider
    box_data=$(box_add_row "$box_data" "divider")
    
    # Add comparison rows
    while (( $# >= 2 )); do
        local label="$1"
        local value="$2"
        shift 2
        
        row_data=$(row_new)
        row_data=$(row_add_cell "$row_data" "$(make_text "$label")")
        row_data=$(row_add_cell "$row_data" "$(make_text "$value")")
        box_data=$(box_add_row "$box_data" "$row_data")
    done
    
    box_render "$box_data"
} 