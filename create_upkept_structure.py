import os

# Base directory for project
base_dir = "./"

# Define directories
dirs = [
    "scripts/modules",
    "logs/modules",
    "tests/mocks",
    "tests/test_cases",
    "docs",
    "examples",
]

# Create directories
for d in dirs:
    os.makedirs(os.path.join(base_dir, d), exist_ok=True)

# Define files with their content
files = {
    "scripts/main.sh": """#!/bin/bash
# main.sh - Main entry point for Auto-Maintainer

BASE_DIR="$(dirname "$0")"
source "$BASE_DIR/modules/utils.sh"
source "$BASE_DIR/modules/ascii_art.sh"
source "$BASE_DIR/modules/state.sh"
source "$BASE_DIR/modules/apt_update.sh"
source "$BASE_DIR/modules/snap_update.sh"
source "$BASE_DIR/modules/flatpak_update.sh"
source "$BASE_DIR/modules/cleanup.sh"

main() {
    ascii_title
    show_current_status
    run_apt_updates
    run_snap_updates
    run_flatpak_updates
    run_cleanup
    save_state
    draw_summary
}

main "$@"
""",

    "scripts/modules/utils.sh": """#!/bin/bash
# utils.sh - Utility functions for box drawing and spinners

RESET="\\e[0m"
BOLD="\\e[1m"
WHITE="\\e[97m"
RED="\\e[31m"
GREEN="\\e[32m"
YELLOW="\\e[33m"
BLUE="\\e[34m"
MAGENTA="\\e[35m"
CYAN="\\e[36m"
GRAY="\\e[90m"

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
    printf "${c}╭%s%s%s╮${RESET}\\n" "$(repeat_char '─' "$left")" "$title" "$(repeat_char '─' "$right")"
}

box_bottom() { local c="$1"; printf "${c}╰%s╯${RESET}\\n" "$(repeat_char '─' "$BOX_W")"; }

box_text_line() { local c="$1" text="$2"; printf "${c}│ ${WHITE}%-*s${RESET}${c} │${RESET}\\n" $((BOX_W-2)) "$text"; }

draw_box() { local c="$1" title="$2"; shift 2; box_top "$c" "$title"; for l in "$@"; do box_text_line "$c" "$l"; done; box_bottom "$c"; }

spinner() {
    local pid=$1
    local msg="$2"
    local spin='|/-\\'
    local i=0
    tput civis
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\\r${MAGENTA}%s ${msg}${RESET}" "${spin:$i:1}"
        sleep 0.2
    done
    wait $pid
    printf "\\r${GREEN}✔ ${msg}                          ${RESET}\\n"
    tput cnorm
}
""",

    "scripts/modules/ascii_art.sh": """#!/bin/bash
# ascii_art.sh - ASCII title
ascii_title() {
    echo -e "${CYAN}"
    echo "   █████╗ ██╗   ██╗████████╗ ██████╗      ███╗   ███╗ █████╗ ██╗███╗   ██╗"
    echo "  ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗     ████╗ ████║██╔══██╗██║████╗  ██║"
    echo "  ███████║██║   ██║   ██║   ██║   ██║     ██╔████╔██║███████║██║██╔██╗ ██║"
    echo "  ██╔══██║██║   ██║   ██║   ██║   ██║     ██║╚██╔╝██║██╔══██║██║██║╚██╗██║"
    echo "  ██║  ██║╚██████╔╝   ██║   ╚██████╔╝     ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║"
    echo "  ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝      ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝"
    echo -e "                               ${WHITE}- Auto-Maintainer${RESET}"
    echo
}
""",

    "scripts/modules/state.sh": """#!/bin/bash
# state.sh - State management functions
STATE_FILE="$HOME/.auto_maintainer_state"

load_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        echo -e "UPDATE_LAST_RUN=0\\nCLEANUP_LAST_RUN=0\\nSCRIPT_LAST_RUN=0" > "$STATE_FILE"
    fi
    source "$STATE_FILE"
}

save_state() {
    cat <<EOF > "$STATE_FILE"
UPDATE_LAST_RUN=$UPDATE_LAST_RUN
CLEANUP_LAST_RUN=$CLEANUP_LAST_RUN
SCRIPT_LAST_RUN=$(date +%s)
EOF
}

show_current_status() {
    load_state
    NOW=$(date +%s)
    DAYS_SINCE_UPDATE=$(( (NOW - UPDATE_LAST_RUN) / 86400 ))
    DAYS_SINCE_CLEANUP=$(( (NOW - CLEANUP_LAST_RUN) / 86400 ))
    draw_box "$BLUE" "CURRENT STATUS" \\
        "Last update : $DAYS_SINCE_UPDATE day(s) ago" \\
        "Last cleanup: $DAYS_SINCE_CLEANUP day(s) ago"
}
""",

    "scripts/modules/apt_update.sh": """#!/bin/bash
# apt_update.sh - APT updates
run_apt_updates() {
    draw_box "$GREEN" "APT UPDATES"
    (sudo apt update && sudo apt upgrade -y) & spinner $! "Updating APT packages"
    [[ $? -eq 0 ]] && APT_STATUS="success" || APT_STATUS="failed"
}
""",

    "scripts/modules/snap_update.sh": """#!/bin/bash
# snap_update.sh - Snap updates
run_snap_updates() {
    draw_box "$GREEN" "SNAP UPDATES"
    (sudo snap refresh) & spinner $! "Refreshing Snap packages"
    [[ $? -eq 0 ]] && SNAP_STATUS="success" || SNAP_STATUS="failed"
}
""",

    "scripts/modules/flatpak_update.sh": """#!/bin/bash
# flatpak_update.sh - Flatpak updates
run_flatpak_updates() {
    draw_box "$GREEN" "FLATPAK UPDATES"
    (flatpak update -y) & spinner $! "Updating Flatpak packages"
    [[ $? -eq 0 ]] && FLATPAK_STATUS="success" || FLATPAK_STATUS="failed"
}
""",

    "scripts/modules/cleanup.sh": """#!/bin/bash
# cleanup.sh - System cleanup
run_cleanup() {
    draw_box "$GREEN" "SYSTEM CLEANUP"
    (sudo apt autoremove -y && sudo apt clean) & spinner $! "Running cleanup tasks"
    [[ $? -eq 0 ]] && CLEANUP_STATUS="success" || CLEANUP_STATUS="failed"
}
""",

    "Makefile": """# Makefile for Auto-Maintainer project

run:
\tbash scripts/main.sh

build:
\tcat scripts/modules/*.sh scripts/main.sh > scripts/update_all.sh
\tchmod +x scripts/update_all.sh

test:
\tbash tests/test_runner.sh

clean:
\trm -rf logs/*
""",
}

# Write files
for filepath, content in files.items():
    with open(os.path.join(base_dir, filepath), "w") as f:
        f.write(content)

# Create placeholder files
placeholder_files = [
    "logs/run.log",
    "logs/modules/apt.log",
    "logs/modules/snap.log",
    "logs/modules/flatpak.log",
    "tests/test_runner.sh",
    "tests/mocks/mock_apt.sh",
    "tests/mocks/mock_snap.sh",
    "tests/test_cases/test_interval_logic.sh",
    "tests/test_cases/test_flags.sh",
    "tests/test_cases/test_formatting.sh",
    "tests/test_cases/test_summary_box.sh",
    "state/auto_maintainer_state",
    "docs/README.md",
    "docs/CHANGELOG.md",
    "docs/DESIGN.md",
    "examples/taskmaster_example.log",
]

for pf in placeholder_files:
    with open(os.path.join(base_dir, pf), "w") as f:
        f.write("")

print("Project structure and files have been created under 'upKept/'.")
