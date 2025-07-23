#!/bin/bash

# upKep Core Utilities
# Enhanced utility functions for visual formatting, progress indicators, and common operations

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Box drawing characters
BOX_TOP_LEFT="╭"
BOX_TOP_RIGHT="╮"
BOX_BOTTOM_LEFT="╰"
BOX_BOTTOM_RIGHT="╯"
BOX_HORIZONTAL="─"
BOX_VERTICAL="│"

# Progress indicator characters
SPINNER_CHARS=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

# Current spinner index
SPINNER_INDEX=0

# Print colored text
print_color() {
    local color="$1"
    local text="$2"
    echo -e "${color}${text}${NC}"
}

# Print success message
print_success() {
    print_color "$GREEN" "✓ $1"
}

# Print error message
print_error() {
    print_color "$RED" "✗ $1"
}

# Print warning message
print_warning() {
    print_color "$YELLOW" "⚠ $1"
}

# Print info message
print_info() {
    print_color "$BLUE" "ℹ $1"
}

# Print header
print_header() {
    local text="$1"
    local width="${2:-60}"
    local padding=$(( (width - ${#text} - 2) / 2 ))

    printf "%${padding}s" ""
    print_color "$MAGENTA" "$text"
}

# Create a box around text
create_box() {
    local text="$1"
    local width="${2:-60}"
    local padding=$(( width - ${#text} - 2 ))

    echo "$BOX_TOP_LEFT$(printf "%${width}s" | tr ' ' "$BOX_HORIZONTAL")$BOX_TOP_RIGHT"
    echo "$BOX_VERTICAL $text$(printf "%${padding}s") $BOX_VERTICAL"
    echo "$BOX_BOTTOM_LEFT$(printf "%${width}s" | tr ' ' "$BOX_HORIZONTAL")$BOX_BOTTOM_RIGHT"
}

# Create a summary box
create_summary_box() {
    local title="$1"
    local status="$2"
    local message="$3"
    local width="${4:-60}"

    local status_color
    case "$status" in
        "success") status_color="$GREEN" ;;
        "failed") status_color="$RED" ;;
        "skipped") status_color="$YELLOW" ;;
        *) status_color="$WHITE" ;;
    esac

    echo "$BOX_TOP_LEFT$(printf "%${width}s" | tr ' ' "$BOX_HORIZONTAL")$BOX_TOP_RIGHT"
    echo "$BOX_VERTICAL $(printf "%-${width}s" "$title") $BOX_VERTICAL"
    echo "$BOX_VERTICAL $(printf "%-${width}s" "Status: ${status_color}${status}${NC}") $BOX_VERTICAL"
    if [[ -n "$message" ]]; then
        echo "$BOX_VERTICAL $(printf "%-${width}s" "$message") $BOX_VERTICAL"
    fi
    echo "$BOX_BOTTOM_LEFT$(printf "%${width}s" | tr ' ' "$BOX_HORIZONTAL")$BOX_BOTTOM_RIGHT"
}

# Simple spinner function
spinner() {
    local pid="$1"
    local message="${2:-Processing...}"
    local delay=0.1

    # Hide cursor
    echo -en "\033[?25l"

    while kill -0 "$pid" 2>/dev/null; do
        local char="${SPINNER_CHARS[$SPINNER_INDEX]}"
        echo -ne "\r${CYAN}${char}${NC} $message"
        SPINNER_INDEX=$(( (SPINNER_INDEX + 1) % ${#SPINNER_CHARS[@]} ))
        sleep "$delay"
    done

    # Show cursor
    echo -en "\033[?25h"
    echo -ne "\r"
    printf "%$((${#message} + 2))s" ""
    echo -ne "\r"
}

# Progress bar
progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    local message="${4:-Progress}"

    local percentage=$(( current * 100 / total ))
    local filled=$(( current * width / total ))
    local empty=$(( width - filled ))

    printf "\r${CYAN}${message}:${NC} ["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %d%%" "$percentage"

    if [[ "$current" -eq "$total" ]]; then
        echo
    fi
}

# Log message with timestamp and level filtering
log_message() {
    local level="$1"
    local message="$2"
    local context="${3:-}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Get configured log level (default to INFO)
    local configured_level="${UPKEP_LOGGING_LEVEL:-INFO}"

    # Define log level priorities (lower number = higher priority)
    local -A log_priorities=(
        ["DEBUG"]=0
        ["INFO"]=1
        ["WARN"]=2
        ["ERROR"]=3
        ["SUCCESS"]=1  # Same as INFO
    )

    # Get numeric priorities for comparison
    local current_priority=${log_priorities[$level]:-1}
    local threshold_priority=${log_priorities[$configured_level]:-1}

    # Filter out log messages below the configured threshold
    if [[ $current_priority -lt $threshold_priority ]]; then
        return 0  # Skip this message
    fi

    case "$level" in
        "INFO") color="$BLUE" ;;
        "WARN") color="$YELLOW" ;;
        "ERROR") color="$RED" ;;
        "SUCCESS") color="$GREEN" ;;
        "DEBUG") color="$MAGENTA" ;;
        *) color="$WHITE" ;;
    esac

    # Format message with optional context
    local formatted_message="$message"
    if [[ -n "$context" ]]; then
        formatted_message="[$context] $message"
    fi

    # Always show on console (current behavior unchanged)
    echo -e "[$timestamp] ${color}[$level]${NC} $formatted_message"

    # Optional file logging
    if [[ "${UPKEP_LOG_TO_FILE:-false}" == "true" ]]; then
        local log_file="${UPKEP_LOG_FILE:-$HOME/.upkep/upkep.log}"
        local log_dir=$(dirname "$log_file")

        # Ensure log directory exists
        if [[ ! -d "$log_dir" ]]; then
            mkdir -p "$log_dir" 2>/dev/null || true
        fi

        # Append to log file (without color codes)
        echo "[$timestamp] [$level] $formatted_message" >> "$log_file" 2>/dev/null || true
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running as root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Check if running with sudo
has_sudo() {
    sudo -n true 2>/dev/null
}

# Get system information
get_system_info() {
    echo "System Information:"
    echo "  OS: $(lsb_release -d | cut -f2 2>/dev/null || echo "Unknown")"
    echo "  Kernel: $(uname -r)"
    echo "  Architecture: $(uname -m)"
    echo "  User: $(whoami)"
    echo "  Home: $HOME"
}

# Validate file exists and is readable
validate_file() {
    local file="$1"
    local description="${2:-File}"

    if [[ ! -f "$file" ]]; then
        print_error "$description not found: $file"
        return 1
    fi

    if [[ ! -r "$file" ]]; then
        print_error "$description not readable: $file"
        return 1
    fi

    return 0
}

# Validate directory exists and is writable
validate_directory() {
    local dir="$1"
    local description="${2:-Directory}"

    if [[ ! -d "$dir" ]]; then
        print_error "$description not found: $dir"
        return 1
    fi

    if [[ ! -w "$dir" ]]; then
        print_error "$description not writable: $dir"
        return 1
    fi

    return 0
}

# Create directory if it doesn't exist
ensure_directory() {
    local dir="$1"
    local description="${2:-Directory}"

    if [[ ! -d "$dir" ]]; then
        if mkdir -p "$dir" 2>/dev/null; then
            print_success "Created $description: $dir"
        else
            print_error "Failed to create $description: $dir"
            return 1
        fi
    fi

    return 0
}

# Backup file with timestamp
backup_file() {
    local file="$1"
    local backup_dir="${2:-./backups}"

    if [[ ! -f "$file" ]]; then
        print_error "File not found: $file"
        return 1
    fi

    ensure_directory "$backup_dir" "Backup directory"

    local timestamp=$(date +%Y%m%d_%H%M%S)
    local filename=$(basename "$file")
    local backup_file="$backup_dir/${filename}.backup.$timestamp"

    if cp "$file" "$backup_file" 2>/dev/null; then
        print_success "Backed up: $backup_file"
        return 0
    else
        print_error "Failed to backup: $file"
        return 1
    fi
}

# Get file size in human readable format
human_readable_size() {
    local bytes="$1"
    local units=("B" "KB" "MB" "GB" "TB")
    local unit_index=0

    while [[ $bytes -ge 1024 && $unit_index -lt ${#units[@]}-1 ]]; do
        bytes=$((bytes / 1024))
        unit_index=$((unit_index + 1))
    done

    echo "${bytes}${units[$unit_index]}"
}

# Get disk usage for directory
get_disk_usage() {
    local dir="$1"

    if [[ ! -d "$dir" ]]; then
        print_error "Directory not found: $dir"
        return 1
    fi

    local usage=$(du -sh "$dir" 2>/dev/null | cut -f1)
    echo "$usage"
}

# Check if string is empty or whitespace
is_empty() {
    local string="$1"
    [[ -z "${string// }" ]]
}

# Trim whitespace from string
trim() {
    local string="$1"
    echo "$string" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Convert string to lowercase
to_lower() {
    local string="$1"
    echo "$string" | tr '[:upper:]' '[:lower:]'
}

# Convert string to uppercase
to_upper() {
    local string="$1"
    echo "$string" | tr '[:lower:]' '[:upper:]'
}

# Check if string contains substring
contains() {
    local string="$1"
    local substring="$2"
    [[ "$string" == *"$substring"* ]]
}

# Get current timestamp
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Get current timestamp in ISO format
get_iso_timestamp() {
    date -u '+%Y-%m-%dT%H:%M:%SZ'
}

# Calculate time difference in seconds
time_diff() {
    local start="$1"
    local end="$2"
    echo $((end - start))
}

# Format duration in human readable format
format_duration() {
    local seconds="$1"
    local hours=$((seconds / 3600))
    local minutes=$(( (seconds % 3600) / 60 ))
    local secs=$((seconds % 60))

    if [[ $hours -gt 0 ]]; then
        printf "%dh %dm %ds" "$hours" "$minutes" "$secs"
    elif [[ $minutes -gt 0 ]]; then
        printf "%dm %ds" "$minutes" "$secs"
    else
        printf "%ds" "$secs"
    fi
}

# Wait for a condition with timeout
wait_for() {
    local condition="$1"
    local timeout="${2:-30}"
    local interval="${3:-1}"
    local elapsed=0

    while [[ $elapsed -lt $timeout ]]; do
        if eval "$condition"; then
            return 0
        fi
        sleep "$interval"
        elapsed=$((elapsed + interval))
    done

    return 1
}

# Retry command with exponential backoff
retry_command() {
    local command="$1"
    local max_attempts="${2:-3}"
    local base_delay="${3:-1}"
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        if eval "$command"; then
            return 0
        fi

        if [[ $attempt -lt $max_attempts ]]; then
            local delay=$((base_delay * (2 ** (attempt - 1))))
            print_warning "Attempt $attempt failed, retrying in ${delay}s..."
            sleep "$delay"
        fi

        attempt=$((attempt + 1))
    done

    print_error "Command failed after $max_attempts attempts: $command"
    return 1
}

# Check if port is open
is_port_open() {
    local host="$1"
    local port="$2"
    local timeout="${3:-5}"

    if command_exists nc; then
        nc -z -w "$timeout" "$host" "$port" >/dev/null 2>&1
    elif command_exists telnet; then
        timeout "$timeout" telnet "$host" "$port" >/dev/null 2>&1
    else
        print_warning "Neither nc nor telnet available, cannot check port"
        return 1
    fi
}

# Get IP address
get_ip_address() {
    local interface="${1:-}"

    if [[ -n "$interface" ]]; then
        ip addr show "$interface" 2>/dev/null | grep -oP 'inet \K\S+' | head -1
    else
        ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+' | head -1
    fi
}

# Check internet connectivity
check_internet() {
    local timeout="${1:-5}"

    if command_exists curl; then
        curl -s --connect-timeout "$timeout" --max-time "$timeout" http://www.google.com >/dev/null 2>&1
    elif command_exists wget; then
        wget -q --timeout="$timeout" --tries=1 http://www.google.com >/dev/null 2>&1
    else
        print_warning "Neither curl nor wget available, cannot check internet"
        return 1
    fi
}

# Generate random string
random_string() {
    local length="${1:-8}"
    local charset="${2:-a-zA-Z0-9}"

    tr -dc "$charset" < /dev/urandom | head -c "$length"
}

# Generate UUID (simple version)
generate_uuid() {
    if command_exists uuidgen; then
        uuidgen
    else
        # Simple UUID v4 generation
        printf "%04x%04x-%04x-%04x-%04x-%04x%04x%04x\n" \
            $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM
    fi
}

# Check if running in a container
is_container() {
    [[ -f /.dockerenv ]] || grep -q 'docker\|lxc' /proc/1/cgroup 2>/dev/null
}

# Check if running in WSL
is_wsl() {
    grep -qi microsoft /proc/version 2>/dev/null
}

# Get CPU usage percentage
get_cpu_usage() {
    if command_exists top; then
        top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1
    else
        echo "0"
    fi
}

# Get memory usage percentage
get_memory_usage() {
    if command_exists free; then
        free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}'
    else
        echo "0"
    fi
}

# Get disk usage percentage
get_disk_usage_percent() {
    local path="${1:-/}"
    df "$path" | tail -1 | awk '{print $5}' | cut -d'%' -f1
}

# Print system resource usage
print_system_resources() {
    echo "System Resources:"
    echo "  CPU Usage: $(get_cpu_usage)%"
    echo "  Memory Usage: $(get_memory_usage)%"
    echo "  Disk Usage: $(get_disk_usage_percent)%"
}

# Check if script is being sourced
is_sourced() {
    [[ "${BASH_SOURCE[0]}" != "${0}" ]]
}

# Exit with error message
exit_with_error() {
    local message="$1"
    local code="${2:-1}"
    print_error "$message"
    exit "$code"
}

# Print usage information
print_usage() {
    local script_name="$1"
    local description="$2"
    local usage="$3"

    echo "Usage: $script_name $usage"
    echo ""
    echo "$description"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --version  Show version information"
}

# Print version information
print_version() {
    local script_name="$1"
    local version="$2"

    echo "$script_name version $version"
}

# Parse command line arguments (simple version)
parse_args() {
    local args=("$@")

    for arg in "${args[@]}"; do
        case "$arg" in
            -h|--help)
                print_usage "$0" "Description" "usage"
                exit 0
                ;;
            -v|--version)
                print_version "$0" "1.0.0"
                exit 0
                ;;
            *)
                # Handle other arguments
                ;;
        esac
    done
}