#!/bin/bash
# utils.sh - Utility functions for box drawing and spinners

RESET="\e[0m"
BOLD="\e[1m"
WHITE="\e[97m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
GRAY="\e[90m"

BOX_W=70

repeat_char() {
    local char="$1" count="$2"
    local i
    for ((i=0; i<count; i++)); do
        printf "%s" "$char"
    done
}

box_top() {
    local c="$1" title=" $2 "
    local title_len=${#title}
    local left=$(( (BOX_W - title_len) / 2 ))
    local right=$(( BOX_W - left - title_len ))
    printf "${c}╭%s%s%s╮${RESET}\n" "$(repeat_char '─' "$left")" "$title" "$(repeat_char '─' "$right")"
}

box_bottom() { local c="$1"; printf "${c}╰%s╯${RESET}\n" "$(repeat_char '─' "$BOX_W")"; }

box_text_line() { local c="$1" text="$2"; printf "${c}│ ${WHITE}%-*s${RESET}${c} │${RESET}\n" $((BOX_W-2)) "$text"; }

box_line() {
    local c="$1" left="$2" right="$3"
    local inner=$((BOX_W - 2))
    local pad=$(( inner - ${#left} - ${#right} ))
    (( pad < 0 )) && pad=0
    printf "${c}│ ${WHITE}%s%*s%s${RESET}${c} │${RESET}\n" "$left" "$pad" "" "$right"
}

draw_box() { local c="$1" title="$2"; shift 2; box_top "$c" "$title"; for l in "$@"; do box_text_line "$c" "$l"; done; box_bottom "$c"; }

spinner() {
    local pid=$1
    local msg="$2"
    local spin='|/-\'
    local i=0
    tput civis
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r${MAGENTA}%s ${msg}${RESET}" "${spin:$i:1}"
        sleep 0.2
    done
    wait $pid
    printf "\r${GREEN}✔ ${msg}                          ${RESET}\n"
    tput cnorm
}

draw_summary() {
    local c="$MAGENTA"
    box_top "$c" "SUMMARY"
    if [[ -n $SKIP_NOTE ]]; then
        printf "${c}│ ${YELLOW}%-*s${RESET}${c} │${RESET}\n" $((BOX_W-2)) "$SKIP_NOTE"
        printf "${c}├%s┤${RESET}\n" "$(repeat_char '─' "$BOX_W")"
    fi
    box_line "$c" "APT"      "$APT_STATUS"
    box_line "$c" "Snap"     "$SNAP_STATUS"
    box_line "$c" "Flatpak"  "$FLATPAK_STATUS"
    box_line "$c" "Cleanup"  "$CLEANUP_STATUS"
    box_bottom "$c"
}
