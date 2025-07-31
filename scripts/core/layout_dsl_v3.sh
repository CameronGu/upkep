#!/bin/bash
# upKep Layout Builder - DSL v3 with HTML-like Syntax
# Provides HTML-like syntax for defining entire layouts

source "${SCRIPT_DIR}/box_builder.sh"

# Parse HTML-like layout syntax
parse_html_layout() {
    local layout="$1"
    local box_width="${2:-60}"
    local box_title="${3:-}"
    local box_style="${4:-info}"
    
    # Create the box
    local box_data=$(box_new "$box_width" "$box_title" "$box_style")
    
    # Parse the layout line by line
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  # Trim whitespace
        
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Parse different row types
        if echo "$line" | grep -q "^[[:space:]]*<row[[:space:]]*>.*</row>[[:space:]]*$"; then
            # Simple row with content
            local content=$(echo "$line" | sed 's/^[[:space:]]*<row[[:space:]]*>\(.*\)<\/row>[[:space:]]*$/\1/')
            local row_data=$(row_new)
            row_data=$(row_add_cell "$row_data" "$(make_text "$content")")
            box_data=$(box_add_row "$box_data" "$row_data")
            
        elif echo "$line" | grep -q "^[[:space:]]*<row[[:space:]]*>"; then
            # Multi-line row
            local content=$(echo "$line" | sed 's/^[[:space:]]*<row[[:space:]]*>\(.*\)/\1/')
            local row_data=$(row_new)
            
            # Check if content contains HTML-like elements
            if echo "$content" | grep -q "<.*>"; then
                row_data=$(row_add_cell "$row_data" "$(make_html "$content")")
            else
                row_data=$(row_add_cell "$row_data" "$(make_text "$content")")
            fi
            box_data=$(box_add_row "$box_data" "$row_data")
            
        elif echo "$line" | grep -q "^[[:space:]]*<cells[[:space:]]*>.*</cells>[[:space:]]*$"; then
            # Row with multiple cells
            local cells_content=$(echo "$line" | sed 's/^[[:space:]]*<cells[[:space:]]*>\(.*\)<\/cells>[[:space:]]*$/\1/')
            local row_data=$(row_new)
            
            # Split cells by | character
            IFS='|' read -ra cells <<< "$cells_content"
            for cell in "${cells[@]}"; do
                cell=$(echo "$cell" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  # Trim
                
                # Check if cell contains HTML-like elements
                if echo "$cell" | grep -q "<.*>"; then
                    row_data=$(row_add_cell "$row_data" "$(make_html "$cell")")
                else
                    row_data=$(row_add_cell "$row_data" "$(make_text "$cell")")
                fi
            done
            box_data=$(box_add_row "$box_data" "$row_data")
            
        elif echo "$line" | grep -q "^[[:space:]]*<divider[[:space:]]*/>[[:space:]]*$"; then
            # Row divider
            box_data=$(box_add_row "$box_data" "divider")
            
        elif echo "$line" | grep -q "^[[:space:]]*<header[[:space:]]*>.*</header>[[:space:]]*$"; then
            # Header row
            local header_content=$(echo "$line" | sed 's/^[[:space:]]*<header[[:space:]]*>\(.*\)<\/header>[[:space:]]*$/\1/')
            local row_data=$(row_new)
            
            # Split header cells by | character
            IFS='|' read -ra headers <<< "$header_content"
            for header in "${headers[@]}"; do
                header=$(echo "$header" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  # Trim
                row_data=$(row_add_cell "$row_data" "$(make_text "$header")")
            done
            box_data=$(box_add_row "$box_data" "$row_data")
            
        elif echo "$line" | grep -q "^[[:space:]]*<data[[:space:]]*>.*</data>[[:space:]]*$"; then
            # Data row
            local data_content=$(echo "$line" | sed 's/^[[:space:]]*<data[[:space:]]*>\(.*\)<\/data>[[:space:]]*$/\1/')
            local row_data=$(row_new)
            
            # Split data cells by | character
            IFS='|' read -ra data_cells <<< "$data_content"
            for cell in "${data_cells[@]}"; do
                cell=$(echo "$cell" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  # Trim
                
                # Check if cell contains HTML-like elements
                if echo "$cell" | grep -q "<.*>"; then
                    row_data=$(row_add_cell "$row_data" "$(make_html "$cell")")
                else
                    row_data=$(row_add_cell "$row_data" "$(make_text "$cell")")
                fi
            done
            box_data=$(box_add_row "$box_data" "$row_data")
        fi
    done <<< "$layout"
    
    # Render the box
    box_render "$box_data"
}

# Convenience functions for common layouts

# Create a simple multi-line box
create_html_box() {
    local title="$1"
    local width="${2:-60}"
    local style="${3:-info}"
    shift 3
    
    local layout=""
    for line in "$@"; do
        layout+="<row>$line</row>"$'\n'
    done
    
    parse_html_layout "$layout" "$width" "$title" "$style"
}

# Create a table with headers and data
create_html_table() {
    local title="$1"
    local width="${2:-80}"
    local style="${3:-info}"
    shift 3
    
    local headers="$1"
    shift
    
    local layout="<header>$headers</header>"$'\n'
    layout+="<divider/>"$'\n'
    
    for data_row in "$@"; do
        layout+="<data>$data_row</data>"$'\n'
    done
    
    parse_html_layout "$layout" "$width" "$title" "$style"
}

# Create a status report with sections
create_html_report() {
    local title="$1"
    local width="${2:-80}"
    local style="${3:-major}"
    shift 3
    
    local layout=""
    for section in "$@"; do
        # Split section by | to get title and content
        IFS='|' read -ra section_parts <<< "$section"
        local section_title="${section_parts[0]}"
        local section_content="${section_parts[1]:-}"
        
        layout+="<row><color=info>$section_title</color></row>"$'\n'
        if [[ -n "$section_content" ]]; then
            layout+="<row>$section_content</row>"$'\n'
        fi
        layout+="<divider/>"$'\n'
    done
    
    # Remove the last divider
    layout=$(echo "$layout" | sed '$d')
    
    parse_html_layout "$layout" "$width" "$title" "$style"
}

# Create a comparison table
create_html_comparison() {
    local title="$1"
    local width="${2:-70}"
    local style="${3:-info}"
    shift 3
    
    local layout="<header>Item|Value</header>"$'\n'
    layout+="<divider/>"$'\n'
    
    while (( $# >= 2 )); do
        local label="$1"
        local value="$2"
        shift 2
        layout+="<data>$label|$value</data>"$'\n'
    done
    
    parse_html_layout "$layout" "$width" "$title" "$style"
}

# Legacy compatibility functions
create_quick_box() { create_html_box "$@"; }
create_quick_table() { create_html_table "$@"; }
create_status_box() { create_html_report "$@"; }
create_comparison_table() { create_html_comparison "$@"; } 