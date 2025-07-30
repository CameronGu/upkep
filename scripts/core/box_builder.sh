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
    [major]="╭─╮│╰─╯"
    [minor]="┌─┐│└─┘"
    [emphasis]="███│███"
)
declare -Ag BORDER_STYLES_ASCII=(
    [major]="+--+|+--+"
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
            "emphasis") echo "${BORDER_STYLES[emphasis]:-███│███}" ;;
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

# Helper: get display width using width_helpers.py
get_display_width() {
    python3 "$SCRIPT_DIR/width_helpers.py" width "$1"
}

# Render a cell token (text/emoji only)
render_cell_token() {
    local token="$1"; local cell_width="$2"
    local token_type="${token%%;*}"; local token_value="${token#*;}"
    local content=""
    if [[ "$token_type" == "text" ]]; then
        content="$token_value"
    elif [[ "$token_type" == "emoji" ]]; then
        content=$(get_emoji "$token_value")
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
    
    # Calculate column widths from content
    for row in "${ROWS[@]}"; do
        IFS='|' read -ra CELLS <<< "$row"
        for ((col=0; col<${#CELLS[@]}; col++)); do
            local token="${CELLS[$col]}"
            local token_type="${token%%;*}"; local token_value="${token#*;}"
            local content=""
            if [[ "$token_type" == "text" ]]; then 
                content="$token_value"
            elif [[ "$token_type" == "emoji" ]]; then 
                content=$(get_emoji "$token_value")
            else 
                content="$token_value"
            fi
            local w=$(get_display_width "$content")
            (( w > COL_WIDTHS[$col] )) && COL_WIDTHS[$col]=$w
        done
    done
    
    # Calculate total content width
    local gap=1; local total_content_width=0
    for ((col=0; col<max_cols; col++)); do 
        total_content_width=$((total_content_width + COL_WIDTHS[$col]))
    done
    total_content_width=$((total_content_width + gap * (max_cols - 1)))
    
    # Ensure box width accommodates title if it's longer than content
    local title_width=$(get_display_width "$title")
    if (( title_width > total_content_width )); then
        total_content_width=$title_width
    fi
    
    # Top border with centered title
    echo -n "$tl"
    if [[ -n "$title" ]]; then
        local left_fill=$(( (total_content_width - title_width) / 2 ))
        local right_fill=$(( total_content_width - title_width - left_fill ))
        for ((i=0; i<left_fill; i++)); do echo -n "$h"; done
        echo -n "$title"
        for ((i=0; i<right_fill; i++)); do echo -n "$h"; done
    else
        for ((i=0; i<total_content_width; i++)); do echo -n "$h"; done
    fi
    echo "$tr"
    
    # Render each row
    for row in "${ROWS[@]}"; do
        IFS='|' read -ra CELLS <<< "$row"
        echo -n "$v"
        for ((col=0; col<max_cols; col++)); do
            (( col > 0 )) && printf "%*s" "$gap" ""
            if (( col < ${#CELLS[@]} )); then
                render_cell_token "${CELLS[$col]}" "${COL_WIDTHS[$col]}"
            else
                printf "%*s" "${COL_WIDTHS[$col]}" ""
            fi
        done
        echo "$v"
    done
    
    # Bottom border
    echo -n "$bl"
    for ((i=0; i<total_content_width; i++)); do echo -n "$b"; done
    echo "$br"
    echo -e "\033[0m"
} 