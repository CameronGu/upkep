#!/usr/bin/env bash
# Test: Verify skip note logic
UPDATE_INTERVAL_DAYS=7
DAYS_SINCE_UPDATE=3
SKIP_NOTE=""

if [[ $DAYS_SINCE_UPDATE -lt $UPDATE_INTERVAL_DAYS ]]; then
    SKIP_NOTE="Updates within interval – skipped"
fi

if [[ "$SKIP_NOTE" == "Updates within interval – skipped" ]]; then
    echo "PASS: Skip note assigned correctly"
else
    echo "FAIL: Skip note logic incorrect"
    exit 1
fi