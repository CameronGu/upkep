#!/bin/bash
# mock_apt.sh - Mock APT commands for testing

# Mock APT update function
apt() {
    case "$1" in
        update)
            echo "Reading package lists..."
            echo "All packages lists are up to date."
            return 0
            ;;
        upgrade)
            echo "Reading package lists..."
            echo "Building dependency tree..."
            echo "0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded."
            return 0
            ;;
        list)
            case "$2" in
                --upgradable)
                    # Mock upgradable packages (empty)
                    return 0
                    ;;
                *)
                    echo "Listing..."
                    return 0
                    ;;
            esac
            ;;
        *)
            echo "Mock APT command: $*"
            return 0
            ;;
    esac
}

# Mock APT-GET for compatibility
apt-get() {
    apt "$@"
}

# Export functions
export -f apt
export -f apt-get
