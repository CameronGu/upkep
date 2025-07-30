#!/bin/bash
# upKep Layout Builder - Robust Box Builder (stateless, string-based)
# Refactored for proper column alignment and border rendering

if [[ -n "${BASH_SOURCE[0]}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    SCRIPT_DIR="$(pwd)/scripts/core"
fi
source "${SCRIPT_DIR}/palette.sh"

# Border style definitions (7 characters: TL-H-TR-V-BL-B-BR)
declare -Ag BORDER_STYLES=(
    [major]="╭═╮│╰═╯"
    [minor]="┌─┐│└─┘"
    [emphasis]="███████"
)
declare -Ag BORDER_STYLES_ASCII=(
    [major]="+==+|+==+"
    [minor]="+--+|+--+"
    [emphasis]="###|###"
)
declare -g BOX_COUNTER=0
choose_palette

get_border_chars() {
    local style="$1"
    if [[ "${UPKEP_ASCII:-0}" == "1" ]]; then
        case "$style" in
            "major") echo "${BORDER_STYLES_ASCII[major]:-+--+|+--+}" ;;
            "minor") echo "${BORDER_STYLES_ASCII[minor]:-+--+|+--+}" ;;
            "emphasis") echo "${BORDER_STYLES_ASCII[emphasis]:-###|###}" ;;
            *) echo "${BORDER_STYLES_ASCII[minor]:-+--+|+--+}" ;;
        esac; return
    fi
    local utf8_supported=false
    if [[ "$LC_ALL" == *"UTF-8"* ]] || [[ "$LANG" == *"UTF-8"* ]] || [[ "$LC_CTYPE" == *"UTF-8"* ]]; then utf8_supported=true; fi
    if [[ "$utf8_supported" == "true" ]]; then
        if printf '\u2500' >/dev/null 2>&1; then utf8_supported=true; else utf8_supported=false; fi
    fi
    if [[ "$utf8_supported" == "true" ]]; then
        case "$style" in
            "major") echo "${BORDER_STYLES[major]:-╭─╮│╰─╯}" ;;
            "minor") echo "${BORDER_STYLES[minor]:-┌─┐│└─┘}" ;;
            "emphasis") echo "${BORDER_STYLES[emphasis]:-███████}" ;;
            *) echo "${BORDER_STYLES[minor]:-┌─┐│└─┘}" ;;
        esac
    else
        case "$style" in
            "major") echo "${BORDER_STYLES_ASCII[major]:-+--+|+--+}" ;;
            "minor") echo "${BORDER_STYLES_ASCII[minor]:-+--+|+--+}" ;;
            "emphasis") echo "${BORDER_STYLES_ASCII[emphasis]:-###|###}" ;;
            *) echo "${BORDER_STYLES_ASCII[minor]:-+--+|+--+}" ;;
        esac
    fi
}
parse_border() {
    local border_string="$1"; local position="$2"
    case "$position" in
        0) echo "${border_string:0:1}" ;; 1) echo "${border_string:1:1}" ;;
        2) echo "${border_string:2:1}" ;; 3) echo "${border_string:3:1}" ;;
        4) echo "${border_string:4:1}" ;; 5) echo "${border_string:5:1}" ;;
        6) echo "${border_string:6:1}" ;; *) echo " " ;;
    esac
}
make_text() { local text="$1"; echo "text;${text}"; }
make_emoji() { local emoji_key="$1"; echo "emoji;${emoji_key}"; }
make_color() { local color_key="$1"; echo "color;${color_key}"; }

# Helper: get display width using width_helpers.py
get_display_width() {
    python3 "$SCRIPT_DIR/width_helpers.py" width "$1"
}

# Helper: calculate width of composite cell content (excluding formatting)
calculate_composite_width() {
    local composite_data="$1"
    local total_width=0
    
    # Parse composite structure (JSON-like format)
    # Example: {"composite": [{"text":"Hello"}, {"color":"red"}, {"text":"World"}]}
    # We need to extract only the content elements and sum their widths
    
    # For now, implement a simple parser that looks for text and emoji elements
    # This is a simplified version - in a full implementation, you'd want proper JSON parsing
    
    # Extract text elements from composite
    local text_content=""
    if [[ "$composite_data" =~ text.*\"([^\"]+)\" ]]; then
        text_content="${BASH_REMATCH[1]}"
    fi
    
    # Extract emoji elements from composite
    local emoji_content=""
    if [[ "$composite_data" =~ emoji.*\"([^\"]+)\" ]]; then
        emoji_content=$(get_emoji "${BASH_REMATCH[1]}")
    fi
    
    # Calculate total width of content elements
    if [[ -n "$text_content" ]]; then
        total_width=$((total_width + $(get_display_width "$text_content")))
    fi
    
    if [[ -n "$emoji_content" ]]; then
        total_width=$((total_width + $(get_display_width "$emoji_content")))
    fi
    
    echo "$total_width"
}

# Helper: strip ANSI color codes from string for width calculation
strip_color_codes() {
    local text="$1"
    # Remove ANSI escape sequences (color codes, cursor movement, etc.)
    echo "$text" | sed 's/\x1b\[[0-9;]*m//g'
}

# Render a cell token (text/emoji/color)
render_cell_token() {
    local token="$1"; local cell_width="$2"; local box_color="$3"
    local token_type="${token%%;*}"; local token_value="${token#*;}"
    local content=""
    
    if [[ "$token_type" == "text" ]]; then
        content="$token_value"
    elif [[ "$token_type" == "emoji" ]]; then
        content=$(get_emoji "$token_value")
    elif [[ "$token_type" == "color" ]]; then
        # Apply color and return empty content (color is applied to next token)
        local color_code=$(get_color "$token_value")
        if [[ -n "$color_code" ]]; then
            printf "\033[%sm" "$color_code"
        fi
        return 0
    else
        content="$token_value"
    fi
    
    # Truncate/pad to cell_width
    local actual_width=$(get_display_width "$content")
    if (( actual_width > cell_width )); then
        # Truncate (naive, could use width_helpers.py for ellipsis)
        content="${content:0:$cell_width}"
        actual_width=$(get_display_width "$content")
    fi
    printf "%s" "$content"
    local pad=$((cell_width - actual_width))
    if (( pad > 0 )); then printf '%*s' "$pad" ""; fi
    
    # Reapply box color after rendering content
    if [[ -n "$box_color" ]]; then
        printf "\033[%sm" "$box_color"
    fi
}

# Create a new box (stateless)
box_new() {
    local width="${1:-0}"; local title="${2:-}"; local style="${3:-info}"
    local box_id="box_$((++BOX_COUNTER))"
    echo "${box_id}§${width}§${title}§${style}"
}
row_new() { echo ""; }
row_add_cell() {
    local row_data="$1"; local cell_token="$2"
    if [[ -n "$row_data" ]]; then echo "${row_data}|${cell_token}"; else echo "$cell_token"; fi
}
box_add_row() {
    local box_data="$1"; local row_data="$2"
    if [[ -n "$box_data" ]]; then echo "${box_data}§${row_data}"; else echo "$row_data"; fi
}



# Robust box_render
# Create section header with emphasis style
create_section_header() {
    local title="$1"
    local width="${2:-60}"
    local style="${3:-emphasis}"
    local box_data=$(box_new "$width" "$title" "$style")
    local row_data=$(row_new)
    row_data=$(row_add_cell "$row_data" "$(make_text '')")
    box_data=$(box_add_row "$box_data" "$row_data")
    box_render "$box_data"
}

# Create divider line
create_divider() {
    local text="$1"
    local width="${2:-60}"
    local char="${3:-═}"
    local padding=$(( (width - ${#text}) / 2 ))
    local left_pad=""
    local right_pad=""
    
    for ((i=0; i<padding; i++)); do
        left_pad="${left_pad}${char}"
    done
    
    local right_padding=$((width - ${#text} - padding))
    for ((i=0; i<right_padding; i++)); do
        right_pad="${right_pad}${char}"
    done
    
    echo "${left_pad} ${text} ${right_pad}"
}

box_render() {
    local box_data="$1"
    IFS='§' read -ra BOX_PARTS <<< "$box_data"
    local box_id="${BOX_PARTS[0]}"; local width="${BOX_PARTS[1]}"
    local title="${BOX_PARTS[2]}"; local style="${BOX_PARTS[3]}"
    local border_chars=$(get_border_chars "$style")
    local tl=$(parse_border "$border_chars" 0)
    local h=$(parse_border "$border_chars" 1)
    local tr=$(parse_border "$border_chars" 2)
    local v=$(parse_border "$border_chars" 3)
    local bl=$(parse_border "$border_chars" 4)
    local b=$(parse_border "$border_chars" 5)
    local br=$(parse_border "$border_chars" 6)
    
    # Get color code for style (but don't apply it yet)
    local color_code=$(get_color "$style")
    
    # Gather rows (from BOX_PARTS[4] onward)
    # The row data is stored after the § separator
    local -a ROWS
    if (( ${#BOX_PARTS[@]} > 4 )); then
        for ((i=4; i<${#BOX_PARTS[@]}; i++)); do
            ROWS+=("${BOX_PARTS[$i]}")
        done
    fi
    
    # Calculate column widths
    local -a COL_WIDTHS; local max_cols=0
    for row in "${ROWS[@]}"; do
        IFS='|' read -ra CELLS <<< "$row"
        (( ${#CELLS[@]} > max_cols )) && max_cols=${#CELLS[@]}
    done
    
    # Initialize column widths
    for ((col=0; col<max_cols; col++)); do COL_WIDTHS[$col]=3; done
    
    # Calculate column widths from content (only content elements, not formatting)
    for row in "${ROWS[@]}"; do
        IFS='|' read -ra CELLS <<< "$row"
        for ((col=0; col<${#CELLS[@]}; col++)); do
            local token="${CELLS[$col]}"
            local token_type="${token%%;*}"; local token_value="${token#*;}"
            local content=""
            
            # Only these token types contribute to width calculations
            case "$token_type" in
                "text")
                    content="$token_value"
                    ;;
                "emoji")
                    content=$(get_emoji "$token_value")
                    ;;
                "composite")
                    # For composite cells, calculate width of all content elements
                    # Parse the composite structure and sum only content widths
                    content=$(calculate_composite_width "$token_value")
                    ;;
                "color"|"format"|"reset")
                    # Formatting elements don't contribute to width
                    continue
                    ;;
                *)
                    # Unknown token type - treat as content for safety
                    content="$token_value"
                    ;;
            esac
            
            local w=$(get_display_width "$content")
            (( w > COL_WIDTHS[$col] )) && COL_WIDTHS[$col]=$w
        done
    done
    
    # Calculate total content width
    local gap=1; local total_content_width=0
    for ((col=0; col<max_cols; col++)); do 
        total_content_width=$((total_content_width + COL_WIDTHS[$col]))
    done
    if (( max_cols > 1 )); then
        total_content_width=$((total_content_width + gap * (max_cols - 1)))
    fi
    
    # Box width determination logic
    local box_width=$width  # Start with user-specified width
    
    # Calculate minimum required width for content
    local min_content_width=$total_content_width
    
    # Ensure box width accommodates title if it's longer than content
    local title_width=$(get_display_width "$title")
    if (( title_width > min_content_width )); then
        min_content_width=$title_width
    fi
    
    # Calculate minimum box width needed (content + borders)
    local min_box_width=$((min_content_width + 2))  # +2 for left and right borders
    
    # Decision logic:
    # 1. If user specified a width, use it (unless content is too wide)
    # 2. If user didn't specify width (width=0), calculate dynamically
    if (( width == 0 )); then
        # Dynamic sizing: use calculated minimum width
        box_width=$min_box_width
    else
        # User-specified width: only expand if content is absolutely too wide
        if (( min_box_width > box_width )); then
            box_width=$min_box_width
        fi
        # Otherwise, keep user's specified width
    fi
    

    
    # Top border with centered title
    # Apply color before rendering border content
    if [[ -n "$color_code" ]]; then
        printf "\033[%sm" "$color_code"
    fi
    echo -n "$tl"
    if [[ -n "$title" ]]; then
        # Title centering should use content width (box_width - 2), not full box width
        local content_width=$((box_width - 2))
        local left_fill=$(( (content_width - title_width) / 2 ))
        local right_fill=$(( content_width - title_width - left_fill ))
        for ((i=0; i<left_fill; i++)); do echo -n "$h"; done
        echo -n "$title"
        for ((i=0; i<right_fill; i++)); do echo -n "$h"; done
    else
        # Render horizontal border: box_width - 2 (for left and right corners)
        for ((i=0; i<box_width-2; i++)); do echo -n "$h"; done
    fi
    echo "$tr"
    
    # Render each row
    for row in "${ROWS[@]}"; do
        IFS='|' read -ra CELLS <<< "$row"
        
        # Check if this is a divider row first
        local is_divider=false
        if (( ${#CELLS[@]} > 0 )); then
            local first_cell="${CELLS[0]}"
            local first_type="${first_cell%%;*}"
            local first_value="${first_cell#*;}"
            
            # If it's a text cell with a single character that's a border character
            if [[ "$first_type" == "text" && "${#first_value}" == 1 && "$first_value" =~ [─═] ]]; then
                is_divider=true
                for cell in "${CELLS[@]}"; do
                    local cell_type="${cell%%;*}"
                    local cell_value="${cell#*;}"
                    if [[ "$cell_type" != "text" || "$cell_value" != "$first_value" ]]; then
                        is_divider=false
                        break
                    fi
                done
            fi
            
            # Also check for divider rows with multiple border characters
            if [[ "$first_type" == "text" && "$first_value" =~ ^[─═]+$ ]]; then
                is_divider=true
                for cell in "${CELLS[@]}"; do
                    local cell_type="${cell%%;*}"
                    local cell_value="${cell#*;}"
                    if [[ "$cell_type" != "text" || "$cell_value" != "$first_value" ]]; then
                        is_divider=false
                        break
                    fi
                done
            fi
        fi
        
        if [[ "$is_divider" == "true" ]]; then
            # Render divider row spanning full content width
            if [[ -n "$color_code" ]]; then
                printf "\033[%sm" "$color_code"
            fi
            echo -n "$v"
            
            # Calculate total width of all cells plus gaps (same as normal rows)
            local total_cell_width=0
            for ((col=0; col<max_cols; col++)); do
                if (( col > 0 )); then
                    total_cell_width=$((total_cell_width + gap))
                fi
                total_cell_width=$((total_cell_width + COL_WIDTHS[$col]))
            done
            
            # Calculate available content space
            local content_width=$((box_width - 2))
            
            # Distribute extra space to fill the entire content width
            local extra_space=0
            if (( total_cell_width < content_width )); then
                extra_space=$((content_width - total_cell_width))
            fi
            
            # Render divider with proper spacing
            for ((col=0; col<max_cols; col++)); do
                if (( col > 0 )); then
                    echo -n "$h"
                fi
                local cell_width="${COL_WIDTHS[$col]}"
                # Add extra space to the last cell if needed
                if (( col == max_cols - 1 && extra_space > 0 )); then
                    cell_width=$((cell_width + extra_space))
                fi
                for ((i=0; i<cell_width; i++)); do
                    echo -n "$h"
                done
            done
            echo "$v"
        else
            # Render normal row
            if [[ -n "$color_code" ]]; then
                printf "\033[%sm" "$color_code"
            fi
            echo -n "$v"
            
            # Calculate available content space (box width minus borders)
            local content_width=$((box_width - 2))  # -2 for left and right borders
            
            # Calculate total width of all cells plus gaps
            local total_cell_width=0
            for ((col=0; col<max_cols; col++)); do
                if (( col > 0 )); then
                    total_cell_width=$((total_cell_width + gap))
                fi
                if (( col < ${#CELLS[@]} )); then
                    total_cell_width=$((total_cell_width + COL_WIDTHS[$col]))
                else
                    total_cell_width=$((total_cell_width + COL_WIDTHS[$col]))
                fi
            done
            
            # Distribute extra space to fill the entire content width
            local extra_space=0
            if (( total_cell_width < content_width )); then
                extra_space=$((content_width - total_cell_width))
            fi
            
            # Render cells
            for ((col=0; col<max_cols; col++)); do
                (( col > 0 )) && printf "%*s" "$gap" ""
                if (( col < ${#CELLS[@]} )); then
                    local cell_width="${COL_WIDTHS[$col]}"
                    # Add extra space to the last cell if needed
                    if (( col == max_cols - 1 && extra_space > 0 )); then
                        cell_width=$((cell_width + extra_space))
                    fi
                    render_cell_token "${CELLS[$col]}" "$cell_width" "$color_code"
                else
                    local cell_width="${COL_WIDTHS[$col]}"
                    # Add extra space to the last cell if needed
                    if (( col == max_cols - 1 && extra_space > 0 )); then
                        cell_width=$((cell_width + extra_space))
                    fi
                    printf "%*s" "$cell_width" ""
                fi
            done
            echo "$v"
        fi
    done
    
    # Bottom border
    if [[ -n "$color_code" ]]; then
        printf "\033[%sm" "$color_code"
    fi
    echo -n "$bl"
    # Render horizontal border: box_width - 2 (for left and right corners)
    for ((i=0; i<box_width-2; i++)); do echo -n "$b"; done
    echo "$br"
    echo -e "\033[0m"
} 