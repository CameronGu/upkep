# upKep UI Design Document
## Taskmaster-Inspired Visual Style & Interaction Model

**Version:** 2.0  
**Date:** 2024  
**Status:** Draft  

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Visual Identity & Aesthetic](#visual-identity--aesthetic)
3. [Core UI Components](#core-ui-components)
4. [Interaction Model](#interaction-model)
5. [UX Enhancement Principles](#ux-enhancement-principles)
6. [Visual Branding](#visual-branding)
7. [Output Modes & Formats](#output-modes--formats)
8. [Implementation Roadmap](#implementation-roadmap)
9. [Design System Specifications](#design-system-specifications)
10. [Component Library](#component-library)

---

## Executive Summary

This design document establishes upKep's visual language and interaction model inspired by Taskmaster's proven terminal-first approach. The design focuses on **actionable maintenance data**, **clear hierarchical information**, and **efficient task-oriented workflows** while maintaining upKep's modular architecture.

**Core Design Philosophy:**
- **Terminal-first:** Dark theme with high-contrast monospace presentation
- **Task-centric:** Every interaction centers around maintenance operations
- **Status-driven:** Color-coded visual feedback for immediate comprehension
- **Minimal chrome:** Focus on data, not decorative UI elements
- **Conversational:** Human-readable feedback with inline context

---

## Visual Identity & Aesthetic

### 2.1 Terminal-First Dark Theme

**Primary Color Palette:**
```bash
# Core Colors (following Taskmaster patterns)
PRIMARY_BG="#1a1a1a"      # Deep black background
PRIMARY_FG="#f8f8f2"      # High-contrast white text
ACCENT_CYAN="#8be9fd"     # Headers, section dividers
ACCENT_MAGENTA="#bd93f9"  # Progress, emphasis

# Semantic Status Colors
SUCCESS_GREEN="#50fa7b"   # Completed tasks, successful operations
WARNING_YELLOW="#f1fa8c"  # Skipped tasks, pending actions  
ERROR_RED="#ff5555"       # Failed operations, critical issues
INFO_BLUE="#6272a4"       # Informational content, metadata
```

**Typography:**
- **Primary Font:** Monospace (inherits terminal font)
- **Weight Hierarchy:** Bold for emphasis, regular for content
- **Line Height:** 1.4 for readability in dense information displays

### 2.2 Visual Hierarchy Principles

**Information Architecture:**
1. **Level 1:** ASCII header with system branding
2. **Level 2:** Module category headers (Package Updates, System Cleanup)
3. **Level 3:** Individual module status and results
4. **Level 4:** Detailed execution feedback and metrics

**Spacing System:**
- **Section breaks:** 2 empty lines between major sections
- **Module groups:** 1 empty line between related operations
- **Detail lines:** No spacing for tightly related information

---

## Core UI Components

### 3.1 Module Overview Table

The central interface component displaying all maintenance modules in a scannable format.

**Structure:**
```bash
╭─────────────── SYSTEM MAINTENANCE STATUS ────────────────╮
│ Module                │ Last Run    │ Status  │ Next Due │
├───────────────────────┼─────────────┼─────────┼──────────┤
│ Package Updates       │             │         │          │
│ ├─ APT                │ 2 days ago  │ ✅ Done │ 5 days   │
│ ├─ Snap               │ 2 days ago  │ ✅ Done │ 5 days   │
│ └─ Flatpak            │ 6 days ago  │ ⚠️  Due │ Now      │
│ System Cleanup        │             │         │          │
│ ├─ Package Cache      │ 1 day ago   │ ✅ Done │ 2 days   │
│ └─ Temp Files         │ 4 days ago  │ ⚠️  Due │ Now      │
│ Custom Modules        │             │         │          │
│ └─ Docker Cleanup     │ Never       │ 📋 New  │ Setup    │
╰───────────────────────┴─────────────┴─────────┴──────────╯
```

**Visual Features:**
- **Hierarchical indentation** for nested operations
- **Status icons** for immediate recognition
- **Color-coded status** (green=success, yellow=due, red=failed)
- **Time-relative formatting** ("2 days ago", "Now", "5 days")

### 3.2 Execution Summary Boxes

Taskmaster-style information boxes that appear after module execution.

**Success Box Example:**
```bash
╭─────────────────── APT UPDATE COMPLETE ───────────────────╮
│                                                           │
│ ✅ 12 packages updated successfully                       │
│ ⏱️  Execution time: 42 seconds                            │
│ 📦 Updates: firefox (91.0), git (2.34), python3 (3.9.7)   │
│ 🔄 3 packages held back due to dependencies               │
│                                                           │
│ Next update due: 5 days (based on 7-day interval)         │
╰───────────────────────────────────────────────────────────╯
```

**Warning/Skip Box Example:**
```bash
╭─────────────────── FLATPAK UPDATE SKIPPED ────────────────╮
│                                                           │
│ ⚠️  Skipped - Last update was 2 days ago                  │
│ 📅 Configured interval: 7 days                            │
│ ⏭️  Next update scheduled: 5 days from now                │
│                                                           │
│ Use --force to override interval checking                 │
╰───────────────────────────────────────────────────────────╯
```

**Error Box Example:**
```bash
╭──────────────────── SNAP UPDATE FAILED ───────────────────╮
│                                                           │
│ ❌ Failed to refresh snaps                                │
│ ⏱️  Execution time: 15 seconds                            │
│ 🔍 Error: network timeout during download                 │
│ 💡 Suggestion: Check internet connection and retry        │
│                                                           │
│ View detailed logs: ~/.upkep/logs/snap_update.log         │
╰───────────────────────────────────────────────────────────╯
```

### 3.3 Progress Indicators

**Real-time Execution Feedback:**
```bash
🔄 Updating APT repositories...
├─ Reading package lists... ✅ Done
├─ Building dependency tree... 🔄 In progress
└─ Reading state information... ⏳ Waiting

📦 Installing updates (12 packages)...
██████████▓▓▓▓▓▓▓▓▓▓ 52% (6/12) - Installing firefox...
```

**Step-by-Step Results:**
```bash
🔧 System Cleanup Operations:
├─ 🗑️  Removing unused packages... ✅ 23 packages removed
├─ 🧹 Cleaning package cache... ✅ 147MB freed  
├─ 📁 Emptying temp directories... ⚠️ 2 files skipped (in use)
└─ 🔄 Updating locate database... ✅ Complete

📊 Total space freed: 231MB
```

### 3.4 Dashboard Status Display

Main status screen combining multiple modules in a comprehensive view.

```bash
╭───────────────────── upKep System Status ─────────────────────╮
│                                                               │
│ 🖥️  System: Ubuntu 22.04 LTS │ 🖥️ Last run: 2 hours ago       │
│ 💾 Disk: 89.4GB free         │ 📊 Total modules: 7            │
│                                                               │
╰───────────────────────────────────────────────────────────────╯

⚡ Quick Actions:
├─ upkep run           # Run all due operations
├─ upkep run --force   # Force run all operations  
├─ upkep status        # Show detailed status
└─ upkep config        # Configure settings

🎯 Due Now (2):
├─ Flatpak Update      │ Last run: 8 days ago
└─ Docker Cleanup      │ Last run: Never

✅ Recent Success (3):
├─ APT Update          │ 12 packages updated (2 hours ago)
├─ Package Cleanup     │ 23 packages removed (2 hours ago)
└─ System Files        │ 147MB freed (2 hours ago)
```

---

## Interaction Model

### 4.1 Command-Driven Interface

**Primary Commands Following Taskmaster Patterns:**

```bash
# Core Operations
upkep run              # Execute all due maintenance 
upkep run --all        # Force run all modules regardless of intervals
upkep run cleanup      # Run only cleanup operations
upkep run updates      # Run only package updates

# Status & Information  
upkep status           # Show comprehensive dashboard
upkep list            # Show module overview table
upkep show <module>    # Detailed module information
upkep next            # Show next scheduled operations

# Configuration
upkep config          # Interactive configuration
upkep config show     # Display current settings
upkep config module <name>  # Configure specific module
```

**Response Patterns:**
- **Immediate acknowledgment:** "Starting system maintenance operations..."
- **Progress updates:** Real-time feedback during execution
- **Conversational results:** "12 packages updated successfully"
- **Contextual suggestions:** "Use --verbose for detailed output"

### 4.2 Interactive Dashboard Mode

**Enhanced Status Command:**
```bash
upkep status --interactive  # OR upkep dash
```

**Interactive Features:**
- **Real-time updates** during operation execution
- **Keyboard shortcuts** for common actions
- **Module filtering** by status or category
- **Drill-down capability** into module details

### 4.3 Contextual Help & Guidance

**Intelligent Suggestions:**
```bash
$ upkep run
⚠️  3 modules failed on last run. 
💡 Suggestion: Run 'upkep show failed' to see details
   Or try 'upkep run --fix' to attempt automatic recovery

$ upkep config
🎯 Quick setup detected. 
💡 Tip: Run 'upkep config --wizard' for guided configuration
```

---

## UX Enhancement Principles

### 5.1 Hierarchy & Grouping

**Category-Based Organization:**
```bash
📦 Package Management (3 modules)
├─ APT Updates         [✅ Current]
├─ Snap Updates        [⚠️ Due in 2 days] 
└─ Flatpak Updates     [🔴 Overdue]

🧹 System Cleanup (2 modules)  
├─ Package Cleanup     [✅ Current]
└─ Temp File Cleanup   [⚠️ Due now]

🔧 Custom Operations (1 module)
└─ Docker Maintenance  [📋 Not configured]
```

**Smart Indentation Rules:**
- Parent categories never show individual status
- Child operations show individual status and timing
- Related operations group visually under shared headers

### 5.2 Execution Feedback Enhancement

**Time-to-Complete Metrics:**
```bash
🔄 Starting APT update operations...
⏱️  Estimated time: ~2-3 minutes (based on previous runs)

├─ Updating repositories... ✅ Complete (8s)
├─ Calculating upgrades... ✅ Complete (12s)  
└─ Installing 12 packages... 🔄 In progress (~90s remaining)
```

**Performance Context:**
```bash
✅ APT Update Complete
📊 Performance: Faster than usual (+23s vs 65s average)
💾 Impact: 147MB downloaded, 12 packages updated
🔄 Next run: 7 days (configured interval)
```

### 5.3 State Timeline Visualization

**Upcoming Operations Preview:**
```bash
📅 Maintenance Schedule:
Today     ├─ Docker Cleanup (due now)
          └─ Temp Files (due now)
Tomorrow  └─ (no operations scheduled)
+3 days   └─ Log rotation
+5 days   ├─ APT Updates  
          ├─ Snap Updates
          └─ System cleanup
+7 days   └─ Full system maintenance
```

**Historical Context:**
```bash
📈 Recent Activity:
2 hours ago   ✅ Full maintenance run (4 modules, 2m 34s)
Yesterday     ⚠️ Flatpak update skipped (interval not met)  
2 days ago    ✅ Emergency cleanup (98% disk usage)
1 week ago    ✅ Scheduled maintenance (all modules)
```

---

## Visual Branding

### 6.1 ASCII Art Header

**Refined upKep Header:**
```bash
                                888 88P                  
            8888 8888 888 888e  888 8P   ,e e,  888 888e  
            8888 8888 888  888b 888 K   d88 88b 888  888b 
            Y888 888P 888  888P 888 8b  888   , 888  888P 
             "88 88"  888 888"  888 88b  "YeeP" 888 888"  
                      888                       888      
                      888                       888      
                        -upKep Linux Maintainer-
                              by CameronGu
```

**System Context Header:**
```bash
╭─────────────────── upKep v2.1.0 ───────────────────╮
│ 🖥️  Ubuntu 22.04.3 LTS │ 🕒 Session: 14:32:10      │  
│ 🔧 7 modules loaded    │ 📊 Last run: 2h ago       │
│ 💾 89.4GB free         │ ⚡ 2 operations due        │
╰────────────────────────────────────────────────────╯
```

### 6.2 Section Headers & Dividers

**Category Section Headers:**
```bash
═══════════════════ PACKAGE UPDATES ═══════════════════

─────────────────── System Cleanup ───────────────────

▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ EXECUTION RESULTS ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
```

**Visual Consistency Rules:**
- **Double-line borders** (═) for major sections
- **Single-line borders** (─) for sub-sections  
- **Block characters** (▓) for emphasis/results
- **Color coordination** with section content

### 6.3 Status Icons & Indicators

**Standard Icon Set:**
```bash
✅ Done/Success       🔄 In Progress       ⏸️ Paused
❌ Failed/Error       ⚠️ Warning/Due       📋 New/Unconfigured  
⏱️ Timing Info        📊 Statistics        💡 Suggestion
🔧 Configuration      📦 Package Info      🗑️ Cleanup
🔍 Details/Logs       ⏭️ Skip/Next         🎯 Action Required
```

**Context-Aware Usage:**
- Icons appear consistently across all interfaces
- Color matches semantic meaning (green success, red error)
- Size and spacing optimized for terminal readability

---

## Output Modes & Formats

### 7.1 Human-Readable Mode (Default)

**Optimized for Terminal Interaction:**
- Color-coded status indicators throughout
- Box-drawing characters for structure
- Conversational language in feedback
- Time-relative formats ("2 hours ago")
- Progressive disclosure of details

**Example Output:**
```bash
$ upkep run

🚀 Starting upKep maintenance operations...

╭─────────────── PACKAGE UPDATES ───────────────╮
│                                               │
│ 🔄 APT: Checking repositories...              │
│ ├─ Updated 3 repositories                     │ 
│ ├─ Found 12 package updates                   │
│ └─ Installing... ██████████░░░░ 67%           │
╰───────────────────────────────────────────────╯

✅ Operations complete! 3 modules run, 0 failures
⏱️ Total time: 2m 34s │ 📊 Next run: 5 days
```

### 7.2 Machine-Readable Mode

**JSON Output for Automation:**
```bash
upkep status --json
```

```json
{
  "timestamp": "2024-01-15T14:32:10Z",
  "system": {
    "os": "Ubuntu 22.04.3 LTS", 
    "disk_free": "89.4GB",
    "uptime": "4 days, 12:34"
  },
  "modules": {
    "apt_update": {
      "status": "success",
      "last_run": "2024-01-15T12:00:00Z", 
      "next_due": "2024-01-22T12:00:00Z",
      "interval_days": 7,
      "execution_time": 42,
      "packages_updated": 12
    }
  },
  "summary": {
    "total_modules": 7,
    "modules_due": 2,
    "last_full_run": "2024-01-15T12:00:00Z",
    "next_scheduled": "2024-01-17T09:00:00Z"
  }
}
```

**YAML Output for Configuration:**
```bash  
upkep config --export
```

```yaml
global:
  update_interval: 7
  cleanup_interval: 3
  log_level: info
  
modules:
  apt_update:
    enabled: true
    interval_days: 7
    auto_restart: false
  
  docker_cleanup: 
    enabled: true
    interval_days: 14
    remove_unused_images: true
    max_age_days: 30
```

### 7.3 Verbose Debug Mode

**Detailed Execution Tracing:**
```bash
upkep run --verbose

[14:32:10] 🔍 DEBUG: Loading configuration from ~/.upkep/config.yaml
[14:32:10] 🔍 DEBUG: Found 7 modules in core/, 2 modules in user/
[14:32:10] 🔍 DEBUG: Checking intervals for 9 total modules
[14:32:11] 🔍 INFO:  APT update due (last run: 8 days ago, interval: 7 days)
[14:32:11] 🔍 INFO:  Snap update skipped (last run: 2 days ago, interval: 7 days)
[14:32:11] 🔄 Starting APT update operations...
[14:32:11] 🔍 CMD:   sudo apt update
[14:32:18] 🔍 STDOUT: Hit:1 http://archive.ubuntu.com/ubuntu jammy InRelease
[14:32:19] ✅ APT repositories updated (8 seconds)
[14:32:19] 🔍 CMD:   sudo apt upgrade -y  
[14:32:45] ✅ APT packages upgraded (26 seconds, 12 packages)
[14:32:45] 🔍 DEBUG: Updating state file ~/.upkep/state.json
[14:32:45] 📊 APT update complete - 34 seconds total
```

---

## Implementation Roadmap

### 8.1 Phase 1: Visual Foundation (Week 1-2)

**Core Component Implementation:**
- [ ] Enhanced color scheme with semantic status colors
- [ ] Module overview table with hierarchical display
- [ ] Execution summary boxes (success/warning/error variants)
- [ ] Progress indicators with real-time updates
- [ ] Refined ASCII header and branding

**Technical Changes:**
- Extend `utils.sh` with new box drawing functions
- Add status icon definitions and color mappings  
- Implement table rendering functions
- Create progress indicator templates

### 8.2 Phase 2: Interactive Enhancements (Week 3-4)

**Enhanced Status Features:**
- [ ] Interactive dashboard mode (`upkep dash`)
- [ ] Module filtering and drill-down capabilities
- [ ] Real-time status updates during execution
- [ ] Contextual help and smart suggestions

**UX Improvements:**
- Time-to-complete estimation based on history
- Performance context and comparison
- State timeline visualization
- Upcoming operations preview

### 8.3 Phase 3: Output Modes (Week 5-6)

**Multi-Format Support:**
- [ ] JSON output for automation (`--json` flag)
- [ ] YAML configuration export (`--yaml` flag)  
- [ ] Verbose debug mode (`--verbose` flag)
- [ ] Quiet mode for scripts (`--quiet` flag)

**Integration Features:**
- Machine-readable status codes for CI/CD
- Structured logging with multiple levels
- Export capabilities for external monitoring
- API-like responses for tooling integration

### 8.4 Phase 4: Advanced Features (Week 7-8)

**Smart Features:**
- [ ] Predictive scheduling based on usage patterns
- [ ] Smart suggestions based on system state
- [ ] Historical trend analysis and reporting
- [ ] Automated recovery suggestions for failures

**Enterprise Features:**
- Multi-system status aggregation
- Centralized configuration management  
- Advanced reporting and analytics
- Integration with monitoring systems

---

## Design System Specifications

### 9.1 Layout Grid System

**Terminal Width Standards:**
- **Minimum width:** 80 characters (traditional terminal)
- **Optimal width:** 100-120 characters (modern terminals)
- **Maximum width:** 140 characters (wide displays)

**Responsive Behavior:**
```bash
# 80-char terminals: Compact table format
Module           │ Status │ Due
APT Updates      │ ✅ Done │ 5d
Cleanup          │ ⚠️  Due │ Now

# 100+ char terminals: Full detailed format  
Module              │ Last Run    │ Status    │ Next Due │ Details
APT Updates         │ 2 days ago  │ ✅ Done   │ 5 days   │ 12 packages updated
System Cleanup      │ 1 day ago   │ ✅ Done   │ 2 days   │ 147MB freed
```

### 9.2 Color Accessibility Standards

**High Contrast Requirements:**
- Background/text contrast ratio: minimum 7:1  
- Status colors distinguishable for colorblind users
- Fallback symbols when color is not available
- Support for high contrast terminal themes

**Color-Blind Friendly Palette:**
```bash
SUCCESS_GREEN="#00d700"    # Bright green, distinct from red
WARNING_YELLOW="#ffd700"   # Golden yellow, high contrast  
ERROR_RED="#ff0000"        # Pure red, maximum contrast
INFO_BLUE="#0087ff"        # Bright blue, distinct from other colors
```

### 9.3 Animation & Motion Standards

**Progress Indicators:**
- Spinner speed: 200ms per frame (5 FPS)
- Progress bar updates: 100ms intervals minimum
- No flashing or rapid color changes (accessibility)
- Smooth transitions between states

**Status Changes:**
- Color transitions: Immediate (no fade)
- Text updates: Immediate replacement
- Box redraws: Complete refresh for clarity

---

## Component Library

### 10.1 Box Drawing Components

**Enhanced Box Functions:**
```bash
# Status-aware boxes
draw_status_box() {
    local status="$1" title="$2" content="$3"
    local color
    case "$status" in
        "success") color="$GREEN" ;;
        "warning") color="$YELLOW" ;;
        "error")   color="$RED" ;;
        "info")    color="$BLUE" ;;
    esac
    draw_box "$color" "$title" "$content"
}

# Progress boxes with real-time updates
draw_progress_box() {
    local title="$1" current="$2" total="$3" message="$4"
    local percent=$(( current * 100 / total ))
    local bar_width=30
    local filled=$(( percent * bar_width / 100 ))
    local empty=$(( bar_width - filled ))
    
    local progress_bar
    progress_bar=$(printf "█%.0s" $(seq 1 "$filled"))
    progress_bar+=$(printf "░%.0s" $(seq 1 "$empty"))
    
    draw_box "$CYAN" "$title" \
        "Progress: [$progress_bar] $percent%" \
        "Status: $message" \
        "Completed: $current/$total"
}

# Table components with flexible columns
draw_table() {
    local -a headers=("$@")
    local -a widths
    # Calculate column widths based on terminal size
    # Render headers with separators
    # Support for row data with status colors
}
```

### 10.2 Status Indicator Components

**Comprehensive Status System:**
```bash
# Status icon mapping
declare -A STATUS_ICONS=(
    ["success"]="✅"
    ["failed"]="❌" 
    ["warning"]="⚠️"
    ["pending"]="⏳"
    ["running"]="🔄"
    ["skipped"]="⏭️"
    ["new"]="📋"
    ["due"]="🎯"
)

# Status color mapping  
declare -A STATUS_COLORS=(
    ["success"]="$GREEN"
    ["failed"]="$RED"
    ["warning"]="$YELLOW"
    ["pending"]="$BLUE"
    ["running"]="$MAGENTA"
    ["skipped"]="$CYAN"
    ["new"]="$WHITE"
    ["due"]="$YELLOW"
)

# Format status with icon and color
format_status() {
    local status="$1"
    local icon="${STATUS_ICONS[$status]}"
    local color="${STATUS_COLORS[$status]}"
    echo "${color}${icon} ${status^}${RESET}"
}
```

### 10.3 Time Display Components

**Human-Friendly Time Formatting:**
```bash
# Relative time formatting
format_relative_time() {
    local timestamp="$1" 
    local now=$(date +%s)
    local diff=$(( now - timestamp ))
    
    if (( diff < 60 )); then
        echo "Just now"
    elif (( diff < 3600 )); then
        echo "$(( diff / 60 )) minutes ago"
    elif (( diff < 86400 )); then
        echo "$(( diff / 3600 )) hours ago"  
    elif (( diff < 604800 )); then
        echo "$(( diff / 86400 )) days ago"
    else
        echo "$(date -d "@$timestamp" '+%b %d')"
    fi
}

# Duration formatting
format_duration() {
    local seconds="$1"
    if (( seconds < 60 )); then
        echo "${seconds}s"
    elif (( seconds < 3600 )); then
        echo "$(( seconds / 60 ))m $(( seconds % 60 ))s"  
    else
        echo "$(( seconds / 3600 ))h $(( (seconds % 3600) / 60 ))m"
    fi
}

# Next due calculation
format_next_due() {
    local last_run="$1" interval_days="$2"
    local next_due=$(( last_run + (interval_days * 86400) ))
    local now=$(date +%s)
    local diff=$(( next_due - now ))
    
    if (( diff <= 0 )); then
        echo "${ERROR_RED}Due now${RESET}"
    elif (( diff < 86400 )); then  
        echo "${WARNING_YELLOW}Due in $(( diff / 3600 )) hours${RESET}"
    else
        echo "${INFO_BLUE}Due in $(( diff / 86400 )) days${RESET}"
    fi
}
```

---

## Conclusion

This design document establishes upKep's evolution into a Taskmaster-inspired maintenance tool that prioritizes **clarity**, **efficiency**, and **actionable feedback**. The visual language emphasizes status-driven information architecture while maintaining terminal-native performance and accessibility.

**Key Success Metrics:**
- **Scan time:** Users can assess system status in <5 seconds
- **Action clarity:** Next steps are immediately obvious  
- **Status comprehension:** Color-coded feedback requires no interpretation
- **Terminal nativity:** Feels natural in command-line workflows
- **Information density:** Maximum useful data in minimum screen space

The implementation roadmap provides a clear path for adopting these design principles while maintaining backward compatibility and supporting the existing modular architecture.

**Next Steps:**
1. Review and approve design principles  
2. Begin Phase 1 implementation (visual foundation)
3. User testing with terminal-focused workflows
4. Iterative refinement based on usage patterns
5. Documentation of component library for contributors

---

*This document serves as the definitive visual and interaction specification for upKep v2.x. All UI development should align with these principles while supporting the tool's core mission of intelligent, automated Linux system maintenance.*
