#!/bin/bash
# mock_snap.sh - Mock Snap commands for testing

# Mock snap command
snap() {
    case "$1" in
        refresh)
            echo "All snaps up to date."
            return 0
            ;;
        list)
            case "$2" in
                --all)
                    echo "Name           Version       Rev    Tracking         Publisher   Notes"
                    echo "core20         20230126      1828   latest/stable    canonical*  base"
                    echo "snapd          2.58.3        18357  latest/stable    canonical*  snapd"
                    return 0
                    ;;
                *)
                    echo "Name           Version       Rev    Tracking         Publisher   Notes"
                    echo "core20         20230126      1828   latest/stable    canonical*  base"
                    return 0
                    ;;
            esac
            ;;
        changes)
            echo "ID   Status  Spawn               Summary"
            echo "1    Done    today at 10:00 UTC  Auto-refresh of \"core20\""
            return 0
            ;;
        *)
            echo "Mock snap command: $*"
            return 0
            ;;
    esac
}

# Export function
export -f snap
