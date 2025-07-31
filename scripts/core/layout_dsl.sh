#!/bin/bash
# upKep Layout Builder - Simple DSL Parser
# Provides easy-to-use functions for creating rich layouts

source "${SCRIPT_DIR}/box_builder.sh"

# Simple DSL functions for creating layouts
# This provides a clean, easy-to-use API without complex parsing

# Create a simple box with content
create_quick_box() {
    local title="$1"
    local content="$2"
    local style="${3:-info}"
    local width="${4:-50}"
    
    local box_data=$(box_new "$width" "$title" "$style")
    local row_data=$(row_new)
    row_data=$(row_add_cell "$row_data" "$(make_text "$content")")
    box_data=$(box_add_row "$box_data" "$row_data")
    box_render "$box_data"
}

# Create a box with colored content
create_colored_box() {
    local title="$1"
    local content="$2"
    local color="$3"
    local style="${4:-info}"
    local width="${5:-50}"
    
    local box_data=$(box_new "$width" "$title" "$style")
    local row_data=$(row_new)
    row_data=$(row_add_cell "$row_data" "$(make_html "<color=$color>$content</color>")")
    box_data=$(box_add_row "$box_data" "$row_data")
    box_render "$box_data"
}

# Create a simple table with headers
create_quick_table() {
    local title="$1"
    local width="${2:-60}"
    shift 2
    
    local box_data=$(box_new "$width" "$title" "info")
    
    # Add header row
    local row_data=$(row_new)
    for header in "$@"; do
        row_data=$(row_add_cell "$row_data" "$(make_text "$header")")
    done
    box_data=$(box_add_row "$box_data" "$row_data")
    
    box_render "$box_data"
}

# Create a status box with emoji and colored text
create_status_box() {
    local title="$1"
    local emoji="$2"
    local message="$3"
    local color="${4:-info}"
    local style="${5:-info}"
    local width="${6:-60}"
    
    local box_data=$(box_new "$width" "$title" "$style")
    local row_data=$(row_new)
    row_data=$(row_add_cell "$row_data" "$(make_html "$emoji <color=$color>$message</color>")")
    box_data=$(box_add_row "$box_data" "$row_data")
    box_render "$box_data"
}

# Create a progress box
create_progress_box() {
    local title="$1"
    local emoji="$2"
    local message="$3"
    local progress="$4"
    local width="${5:-60}"
    
    local box_data=$(box_new "$width" "$title" "info")
    local row_data=$(row_new)
    row_data=$(row_add_cell "$row_data" "$(make_html "$emoji $message: $progress")")
    box_data=$(box_add_row "$box_data" "$row_data")
    box_render "$box_data"
}

# Create a dashboard box with multiple info items
create_dashboard_box() {
    local title="$1"
    local width="${2:-70}"
    shift 2
    
    local box_data=$(box_new "$width" "$title" "major")
    
    # Add info rows
    for info in "$@"; do
        local row_data=$(row_new)
        row_data=$(row_add_cell "$row_data" "$(make_text "$info")")
        box_data=$(box_add_row "$box_data" "$row_data")
    done
    
    box_render "$box_data"
}

# Create a comparison table
create_comparison_table() {
    local title="$1"
    local width="${2:-80}"
    shift 2
    
    local box_data=$(box_new "$width" "$title" "info")
    
    # Add rows
    while (( $# >= 2 )); do
        local label="$1"
        local value="$2"
        shift 2
        
        local row_data=$(row_new)
        row_data=$(row_add_cell "$row_data" "$(make_text "$label")")
        row_data=$(row_add_cell "$row_data" "$(make_text "$value")")
        box_data=$(box_add_row "$box_data" "$row_data")
    done
    
    box_render "$box_data"
}

# Create a warning box
create_warning_box() {
    local title="$1"
    local message="$2"
    local width="${3:-55}"
    
    create_colored_box "$title" "⚠️ $message" "warning" "warning" "$width"
}

# Create an error box
create_error_box() {
    local title="$1"
    local message="$2"
    local width="${3:-55}"
    
    create_colored_box "$title" "❌ $message" "error" "error" "$width"
}

# Create a success box
create_success_box() {
    local title="$1"
    local message="$2"
    local width="${3:-55}"
    
    create_colored_box "$title" "✅ $message" "success" "success" "$width"
}

# Create an info box
create_info_box() {
    local title="$1"
    local message="$2"
    local width="${3:-55}"
    
    create_colored_box "$title" "ℹ️ $message" "info" "info" "$width"
}

# Legacy function for backward compatibility
render_dsl() {
    local template="$1"
    # For now, just create a simple info box
    create_quick_box "DSL Template" "Template rendering not yet implemented" "info" 50
} 