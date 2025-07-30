#!/bin/bash
# upKep Layout Builder - Box Builder DSL
# Provides DSL primitives for box construction and rendering
# Based on layout_builder_spec.md v1.2

# Source palette system
if [[ -n "${BASH_SOURCE[0]}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    SCRIPT_DIR="$(pwd)/scripts/core"
fi
source "${SCRIPT_DIR}/palette.sh"

# Border style definitions
declare -Ag BORDER_STYLES=(
    [major]="╭─╮│╰─╯"
    [minor]="┌─┐│└─┘"
    [emphasis]="███│███"
)

# ASCII fallback border styles
declare -Ag BORDER_STYLES_ASCII=(
    [major]="+--+|+--+"
    [minor]="+--+|+--+"
    [emphasis]="###|###"
)

# Global variables for box state
declare -g BOX_COUNTER=0
declare -g ROW_COUNTER=0

# Box and row storage (associative arrays)
declare -Ag BOXES
declare -Ag ROWS
declare -Ag BOX_ROWS

# Initialize palette
choose_palette

# Create a new box
box_new() {
    local width="${1:-0}"
    local title="${2:-}"
    local style="${3:-info}"
    
    # Generate unique box ID
    local box_id="box_$((++BOX_COUNTER))"
    
    # Store box properties
    BOXES["${box_id}_width"]="$width"
    BOXES["${box_id}_title"]="$title"
    BOXES["${box_id}_style"]="$style"
    BOXES["${box_id}_rows"]=""
    
    echo "$box_id"
}

# Create a new row
row_new() {
    local row_id="row_$((++ROW_COUNTER))"
    ROWS["${row_id}_cells"]=""
    echo "$row_id"
}

# Add a cell to a row
row_add_cell() {
    local row_id="$1"
    local cell_token="$2"
    
    local current_cells="${ROWS["${row_id}_cells"]}"
    if [[ -n "$current_cells" ]]; then
        ROWS["${row_id}_cells"]="${current_cells}|${cell_token}"
    else
        ROWS["${row_id}_cells"]="$cell_token"
    fi
}

# Add a row to a box
box_add_row() {
    local box_id="$1"
    local row_id="$2"
    
    local current_rows="${BOXES["${box_id}_rows"]}"
    if [[ -n "$current_rows" ]]; then
        BOXES["${box_id}_rows"]="${current_rows}|${row_id}"
    else
        BOXES["${box_id}_rows"]="$row_id"
    fi
}

# Token creation helpers
make_text() {
    local text="$1"
    echo "text;${text}"
}

make_emoji() {
    local emoji_key="$1"
    echo "emoji;${emoji_key}"
}

make_color() {
    local color_key="$1"
    echo "color;${color_key}"
}

# Cell fitting helper
fit_cell() {
    local text="$1"
    local width="$2"
    local mode="${3:-ellipsis}"
    
    # Use Python helper for accurate width calculation
    local result
    result=$(python3 "${SCRIPT_DIR}/width_helpers.py" "fit" "$text" "$width" "$mode")
    echo "$result"
}

# Get border characters for a style
get_border_chars() {
    local style="$1"
    
    if [[ "${UPKEP_ASCII:-0}" == "1" ]] || [[ "$LC_ALL" != *"UTF-8"* ]]; then
        case "$style" in
            "major")
                echo "${BORDER_STYLES_ASCII[major]:-+--+|+--+}"
                ;;
            "minor")
                echo "${BORDER_STYLES_ASCII[minor]:-+--+|+--+}"
                ;;
            "emphasis")
                echo "${BORDER_STYLES_ASCII[emphasis]:-###|###}"
                ;;
            *)
                echo "${BORDER_STYLES_ASCII[minor]:-+--+|+--+}"
                ;;
        esac
    else
        case "$style" in
            "major")
                echo "${BORDER_STYLES[major]:-╭─╮│╰─╯}"
                ;;
            "minor")
                echo "${BORDER_STYLES[minor]:-┌─┐│└─┘}"
                ;;
            "emphasis")
                echo "${BORDER_STYLES[emphasis]:-███│███}"
                ;;
            *)
                echo "${BORDER_STYLES[minor]:-┌─┐│└─┘}"
                ;;
        esac
    fi
}

# Parse border string into individual characters
parse_border() {
    local border_string="$1"
    local position="$2"  # 0=TL, 1=H, 2=TR, 3=V, 4=BL, 5=B, 6=BR
    
    case "$position" in
        0) echo "${border_string:0:1}" ;;  # Top-left
        1) echo "${border_string:1:1}" ;;  # Horizontal
        2) echo "${border_string:2:1}" ;;  # Top-right
        3) echo "${border_string:3:1}" ;;  # Vertical
        4) echo "${border_string:4:1}" ;;  # Bottom-left
        5) echo "${border_string:5:1}" ;;  # Bottom-right
        6) echo "${border_string:6:1}" ;;  # Bottom-right (same as 5)
        *) echo " " ;;
    esac
}

# Render a cell token
render_cell_token() {
    local token="$1"
    local cell_width="$2"
    local overflow_mode="${3:-ellipsis}"
    
    local token_type="${token%%;*}"
    local token_value="${token#*;}"
    
    case "$token_type" in
        "text")
            local fitted_text
            fitted_text=$(fit_cell "$token_value" "$cell_width" "$overflow_mode")
            echo -n "$fitted_text"
            ;;
        "emoji")
            local emoji
            emoji=$(get_emoji "$token_value")
            local fitted_emoji
            fitted_emoji=$(fit_cell "$emoji" "$cell_width" "$overflow_mode")
            echo -n "$fitted_emoji"
            ;;
        "color")
            local color_code
            color_code=$(get_color "$token_value")
            echo -n "\033[${color_code}m"
            ;;
        *)
            echo -n "$token_value"
            ;;
    esac
}

# Calculate column widths for a box
calculate_column_widths() {
    local box_id="$1"
    local box_width="${BOXES["${box_id}_width"]}"
    local gap="${2:-1}"
    
    # Get all rows for this box
    local rows_string="${BOXES["${box_id}_rows"]}"
    if [[ -z "$rows_string" ]]; then
        return
    fi
    
    # Parse rows
    IFS='|' read -ra ROW_IDS <<< "$rows_string"
    
    # Find maximum number of cells in any row
    local max_cells=0
    for row_id in "${ROW_IDS[@]}"; do
        local cells_string="${ROWS["${row_id}_cells"]}"
        if [[ -n "$cells_string" ]]; then
            IFS='|' read -ra CELLS <<< "$cells_string"
            local cell_count="${#CELLS[@]}"
            if (( cell_count > max_cells )); then
                max_cells=$cell_count
            fi
        fi
    done
    
    if (( max_cells == 0 )); then
        return
    fi
    
    # Calculate natural widths for each column
    local -a natural_widths
    for ((col=0; col<max_cells; col++)); do
        local max_width=5  # Minimum width
        for row_id in "${ROW_IDS[@]}"; do
            local cells_string="${ROWS["${row_id}_cells"]}"
            if [[ -n "$cells_string" ]]; then
                IFS='|' read -ra CELLS <<< "$cells_string"
                if (( col < ${#CELLS[@]} )); then
                    local cell_token="${CELLS[$col]}"
                    local token_type="${cell_token%%;*}"
                    local token_value="${cell_token#*;}"
                    
                    local cell_width
                    case "$token_type" in
                        "text")
                            cell_width=$(python3 "${SCRIPT_DIR}/width_helpers.py" "width" "$token_value")
                            ;;
                        "emoji")
                            local emoji
                            emoji=$(get_emoji "$token_value")
                            cell_width=$(python3 "${SCRIPT_DIR}/width_helpers.py" "width" "$emoji")
                            ;;
                        *)
                            cell_width=1
                            ;;
                    esac
                    
                    if (( cell_width > max_width )); then
                        max_width=$cell_width
                    fi
                fi
            fi
        done
        natural_widths[$col]=$max_width
    done
    
    # Calculate total minimum width
    local total_min=0
    for width in "${natural_widths[@]}"; do
        total_min=$((total_min + width))
    done
    total_min=$((total_min + gap * (max_cells - 1)))
    
    # Distribute extra space or shrink proportionally
    local available_width=$((box_width - 2))  # Account for borders
    local -a final_widths
    
    if (( total_min <= available_width )); then
        # Distribute extra space round-robin
        local extra=$((available_width - total_min))
        for ((col=0; col<max_cells; col++)); do
            local extra_for_col=$((extra / max_cells))
            if (( col < extra % max_cells )); then
                extra_for_col=$((extra_for_col + 1))
            fi
            final_widths[$col]=$((natural_widths[col] + extra_for_col))
        done
    else
        # Shrink proportionally, maintaining minimum width
        local min_width=5
        for ((col=0; col<max_cells; col++)); do
            local ratio=$(echo "scale=2; $available_width / $total_min" | bc -l 2>/dev/null || echo "1")
            local new_width=$(echo "scale=0; ${natural_widths[col]} * $ratio / 1" | bc -l 2>/dev/null || echo "${natural_widths[col]}")
            if (( new_width < min_width )); then
                new_width=$min_width
            fi
            final_widths[$col]=$new_width
        done
    fi
    
    # Store column widths for this box
    local widths_string=""
    for ((col=0; col<max_cells; col++)); do
        if [[ -n "$widths_string" ]]; then
            widths_string="${widths_string}|${final_widths[col]}"
        else
            widths_string="${final_widths[col]}"
        fi
    done
    BOXES["${box_id}_column_widths"]="$widths_string"
    BOXES["${box_id}_gap"]="$gap"
}

# Render a box
box_render() {
    local box_id="$1"
    
    # Get box properties
    local width="${BOXES["${box_id}_width"]}"
    local title="${BOXES["${box_id}_title"]}"
    local style="${BOXES["${box_id}_style"]}"
    local rows_string="${BOXES["${box_id}_rows"]}"
    
    # Choose palette for this render
    choose_palette
    
    # Get border characters
    local border_chars
    border_chars=$(get_border_chars "$style")
    local tl=$(parse_border "$border_chars" 0)
    local h=$(parse_border "$border_chars" 1)
    local tr=$(parse_border "$border_chars" 2)
    local v=$(parse_border "$border_chars" 3)
    local bl=$(parse_border "$border_chars" 4)
    local b=$(parse_border "$border_chars" 5)
    local br=$(parse_border "$border_chars" 6)
    
    # Calculate column widths
    calculate_column_widths "$box_id"
    
    # Get column widths
    local widths_string="${BOXES["${box_id}_column_widths"]}"
    local gap="${BOXES["${box_id}_gap"]:-1}"
    
    if [[ -z "$widths_string" ]]; then
        # Empty box - just render borders
        local inner_width=$((width - 2))
        local title_padding=$(( (inner_width - ${#title}) / 2 ))
        if (( title_padding < 0 )); then
            title_padding=0
        fi
        
        # Top border with title
        echo -n "$tl"
        if [[ -n "$title" ]]; then
            printf "%*s%s%*s" "$title_padding" "" "$title" "$((inner_width - title_padding - ${#title}))" ""
        else
            printf "%*s" "$inner_width" "" | tr ' ' "$h"
        fi
        echo "$tr"
        
        # Bottom border
        echo -n "$bl"
        printf "%*s" "$inner_width" "" | tr ' ' "$b"
        echo "$br"
        return
    fi
    
    # Parse column widths
    IFS='|' read -ra COLUMN_WIDTHS <<< "$widths_string"
    local num_columns="${#COLUMN_WIDTHS[@]}"
    
    # Calculate title padding
    local total_content_width=0
    for width in "${COLUMN_WIDTHS[@]}"; do
        total_content_width=$((total_content_width + width))
    done
    total_content_width=$((total_content_width + gap * (num_columns - 1)))
    
    local title_padding=$(( (total_content_width - ${#title}) / 2 ))
    if (( title_padding < 0 )); then
        title_padding=0
    fi
    
    # Top border with title
    echo -n "$tl"
    if [[ -n "$title" ]]; then
        printf "%*s%s%*s" "$title_padding" "" "$title" "$((total_content_width - title_padding - ${#title}))" ""
    else
        printf "%*s" "$total_content_width" "" | tr ' ' "$h"
    fi
    echo "$tr"
    
    # Render rows
    if [[ -n "$rows_string" ]]; then
        IFS='|' read -ra ROW_IDS <<< "$rows_string"
        for row_id in "${ROW_IDS[@]}"; do
            echo -n "$v"
            
            local cells_string="${ROWS["${row_id}_cells"]}"
            if [[ -n "$cells_string" ]]; then
                IFS='|' read -ra CELLS <<< "$cells_string"
                for ((col=0; col<num_columns; col++)); do
                    if (( col > 0 )); then
                        printf "%*s" "$gap" ""
                    fi
                    
                    if (( col < ${#CELLS[@]} )); then
                        local cell_token="${CELLS[$col]}"
                        local cell_width="${COLUMN_WIDTHS[$col]}"
                        render_cell_token "$cell_token" "$cell_width"
                    else
                        printf "%*s" "${COLUMN_WIDTHS[$col]}" ""
                    fi
                done
            else
                # Empty row
                for ((col=0; col<num_columns; col++)); do
                    if (( col > 0 )); then
                        printf "%*s" "$gap" ""
                    fi
                    printf "%*s" "${COLUMN_WIDTHS[$col]}" ""
                done
            fi
            
            echo "$v"
        done
    fi
    
    # Bottom border
    echo -n "$bl"
    printf "%*s" "$total_content_width" "" | tr ' ' "$b"
    echo "$br"
    
    # Always emit reset to prevent color bleed
    echo -e "\033[0m"
}

# Functions are available when script is sourced
# No export needed for sourced scripts 