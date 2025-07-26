#!/bin/bash
# state.sh - State management functions
STATE_FILE="$HOME/.upkep_state"

load_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        echo -e "UPDATE_LAST_RUN=0\nCLEANUP_LAST_RUN=0\nSCRIPT_LAST_RUN=0" > "$STATE_FILE"
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

update_apt_state() {
    load_state
    UPDATE_LAST_RUN=$(date +%s)
    save_state
}

update_cleanup_state() {
    load_state
    CLEANUP_LAST_RUN=$(date +%s)
    save_state
}

show_current_status() {
    load_state
    NOW=$(date +%s)
    DAYS_SINCE_UPDATE=$(( (NOW - UPDATE_LAST_RUN) / 86400 ))
    DAYS_SINCE_CLEANUP=$(( (NOW - CLEANUP_LAST_RUN) / 86400 ))
    DAYS_SINCE_SCRIPT=$(( (NOW - SCRIPT_LAST_RUN) / 86400 ))
    draw_box "Last update : $DAYS_SINCE_UPDATE day(s) ago" "CURRENT STATUS" "$BLUE"
    draw_box "Last cleanup: $DAYS_SINCE_CLEANUP day(s) ago" "" "$BLUE"
    draw_box "Last script run: $DAYS_SINCE_SCRIPT day(s) ago" "" "$BLUE"
}
