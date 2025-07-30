#!/bin/bash
# upKep Layout Builder - Layout Loader
# Provides JSON → tokens → builder pipeline with responsive layout algorithms
# Based on layout_builder_spec.md v1.2

# Source required components
if [[ -n "${BASH_SOURCE[0]}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    SCRIPT_DIR="$(pwd)/scripts/core"
fi
source "${SCRIPT_DIR}/palette.sh"
source "${SCRIPT_DIR}/box_builder.sh"

# Terminal width cache
declare -g COLUMNS=0

# Get terminal columns with caching
_term_cols() {
    COLUMNS=$(tput cols 2>/dev/null || echo 80)
    # Enforce minimum width
    if (( COLUMNS < 80 )); then
        COLUMNS=80
    fi
}

# Trap SIGWINCH for terminal resize
trap _term_cols SIGWINCH

# Initialize terminal width
_term_cols

# Parse JSON descriptor and create box
render_layout_from_json() {
    local json_data="$1"
    
    # Parse JSON using jq if available, otherwise use simple parsing
    if command -v jq >/dev/null 2>&1; then
        render_layout_from_json_jq "$json_data"
    else
        render_layout_from_json_simple "$json_data"
    fi
}

# Parse JSON using jq (preferred method)
render_layout_from_json_jq() {
    local json_data="$1"
    
    # Extract box properties
    local width=$(echo "$json_data" | jq -r '.width // 0')
    local title=$(echo "$json_data" | jq -r '.title // ""')
    local style=$(echo "$json_data" | jq -r '.style // "info"')
    local gap=$(echo "$json_data" | jq -r '.gap // 1')
    local overflow=$(echo "$json_data" | jq -r '.overflow // "ellipsis"')
    
    # Use terminal width if not specified
    if [[ "$width" == "0" ]]; then
        width=$((COLUMNS - 2))
    fi
    
    # Create box
    local box_id
    box_id=$(box_new "$width" "$title" "$style")
    
    # Parse rows
    local rows_json
    rows_json=$(echo "$json_data" | jq -r '.rows // []')
    
    if [[ "$rows_json" != "[]" ]]; then
        local row_count
        row_count=$(echo "$rows_json" | jq length)
        
        for ((i=0; i<row_count; i++)); do
            local row_json
            row_json=$(echo "$rows_json" | jq -r ".[$i]")
            
            # Create row
            local row_id
            row_id=$(row_new)
            
            # Parse cells
            local cells_json
            cells_json=$(echo "$row_json" | jq -r '.cells // []')
            
            if [[ "$cells_json" != "[]" ]]; then
                local cell_count
                cell_count=$(echo "$cells_json" | jq length)
                
                for ((j=0; j<cell_count; j++)); do
                    local cell_json
                    cell_json=$(echo "$cells_json" | jq -r ".[$j]")
                    
                    # Parse cell content
                    local cell_token
                    cell_token=$(parse_cell_json "$cell_json" "$overflow")
                    
                    if [[ -n "$cell_token" ]]; then
                        row_add_cell "$row_id" "$cell_token"
                    fi
                done
            fi
            
            # Add row to box
            box_add_row "$box_id" "$row_id"
        done
    fi
    
    # Render the box
    box_render "$box_id"
}

# Parse JSON using simple bash parsing (fallback)
render_layout_from_json_simple() {
    local json_data="$1"
    
    # Simple JSON parsing - extract basic properties
    local width=$(echo "$json_data" | grep -o '"width"[[:space:]]*:[[:space:]]*[0-9]*' | grep -o '[0-9]*' | head -1)
    local title=$(echo "$json_data" | grep -o '"title"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"title"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    local style=$(echo "$json_data" | grep -o '"style"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"style"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    
    # Use defaults if not found
    width="${width:-0}"
    title="${title:-}"
    style="${style:-info}"
    
    # Use terminal width if not specified
    if [[ "$width" == "0" ]]; then
        width=$((COLUMNS - 2))
    fi
    
    # Create simple box
    local box_id
    box_id=$(box_new "$width" "$title" "$style")
    
    # For simple parsing, we'll create a basic box without rows
    # This is a fallback when jq is not available
    box_render "$box_id"
}

# Parse cell JSON and return token
parse_cell_json() {
    local cell_json="$1"
    local overflow="$2"
    
    # Check for emoji cell
    if echo "$cell_json" | grep -q '"emoji"'; then
        local emoji_key=$(echo "$cell_json" | grep -o '"emoji"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"emoji"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        if [[ -n "$emoji_key" ]]; then
            make_emoji "$emoji_key"
            return
        fi
    fi
    
    # Check for text cell
    if echo "$cell_json" | grep -q '"text"'; then
        local text=$(echo "$cell_json" | grep -o '"text"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"text"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        if [[ -n "$text" ]]; then
            make_text "$text"
            return
        fi
    fi
    
    # Check for color cell
    if echo "$cell_json" | grep -q '"color"'; then
        local color_key=$(echo "$cell_json" | grep -o '"color"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"color"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        if [[ -n "$color_key" ]]; then
            make_color "$color_key"
            return
        fi
    fi
    
    # Check for composite cell (simplified parsing)
    if echo "$cell_json" | grep -q '"composite"'; then
        # For simple parsing, we'll just return the first text element
        local text=$(echo "$cell_json" | grep -o '"text"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"text"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | head -1)
        if [[ -n "$text" ]]; then
            make_text "$text"
            return
        fi
    fi
    
    # Default fallback
    echo ""
}

# Render layout from stdin (for pipe usage)
render_layout_from_stdin() {
    local json_data=""
    while IFS= read -r line; do
        json_data="${json_data}${line}"
    done
    
    render_layout_from_json "$json_data"
}

# Validate JSON descriptor
validate_json_descriptor() {
    local json_data="$1"
    
    # Basic validation using jq if available
    if command -v jq >/dev/null 2>&1; then
        if echo "$json_data" | jq empty 2>/dev/null; then
            return 0
        else
            echo "Error: Invalid JSON format" >&2
            return 1
        fi
    else
        # Simple validation - check for basic JSON structure
        if echo "$json_data" | grep -q '^[[:space:]]*{.*}[[:space:]]*$'; then
            return 0
        else
            echo "Error: Invalid JSON format" >&2
            return 1
        fi
    fi
}

# Create a simple box from command line arguments
create_simple_box() {
    local title="${1:-}"
    local style="${2:-info}"
    local width="${3:-0}"
    
    # Use terminal width if not specified
    if [[ "$width" == "0" ]]; then
        width=$((COLUMNS - 2))
    fi
    
    # Create and render box
    local box_id
    box_id=$(box_new "$width" "$title" "$style")
    box_render "$box_id"
}

# Create a table from arrays
create_table_from_arrays() {
    local title="${1:-}"
    local style="${2:-info}"
    local width="${3:-0}"
    shift 3
    
    # Use terminal width if not specified
    if [[ "$width" == "0" ]]; then
        width=$((COLUMNS - 2))
    fi
    
    # Create box
    local box_id
    box_id=$(box_new "$width" "$title" "$style")
    
    # Add rows from arrays
    for row_data in "$@"; do
        local row_id
        row_id=$(row_new)
        
        # Split row data by | and add cells
        IFS='|' read -ra CELLS <<< "$row_data"
        for cell in "${CELLS[@]}"; do
            local cell_token
            cell_token=$(make_text "$cell")
            row_add_cell "$row_id" "$cell_token"
        done
        
        box_add_row "$box_id" "$row_id"
    done
    
    # Render the box
    box_render "$box_id"
}

# Functions are available when script is sourced
# No export needed for sourced scripts 