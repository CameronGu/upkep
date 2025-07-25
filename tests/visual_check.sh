#!/bin/bash
# visual_check.sh - Manual visual verification of upKep Linux Maintainer UI elements
# Demonstrates all design elements from the enhanced styling system

BASE_DIR="$(dirname "$0")/../scripts/modules"
source "$BASE_DIR/core/utils.sh"
source "$BASE_DIR/core/ascii_art.sh"

echo "=== upKep Enhanced Visual Design Check ==="
echo

# =============================================================================
# 1. ENHANCED ASCII BRANDING
# =============================================================================
echo "1. Enhanced ASCII Branding:"
ascii_title
echo

# =============================================================================
# 2. TERMINAL-FIRST DARK THEME COLOR PALETTE
# =============================================================================
echo "2. Terminal-First Dark Theme Color Palette:"
echo "Primary Colors:"
echo -e "${PRIMARY_FG}Primary FG (High-contrast white text)${RESET}"
echo -e "${ACCENT_CYAN}Accent Cyan (Headers, section dividers)${RESET}"
echo -e "${ACCENT_MAGENTA}Accent Magenta (Progress, emphasis)${RESET}"
echo

echo "Semantic Status Colors:"
echo -e "$(get_color "success")Success Green (Completed tasks, successful operations)${RESET}"
echo -e "$(get_color "warning")Warning Yellow (Skipped tasks, pending actions)${RESET}"
echo -e "$(get_color "error")Error Red (Failed operations, critical issues)${RESET}"
echo -e "$(get_color "info")Info Blue (Informational content, metadata)${RESET}"
echo

# =============================================================================
# 3. ENHANCED BOX DRAWING SYSTEM
# =============================================================================
echo "3. Enhanced Box Drawing System:"
echo

echo "Success Box:"
draw_box "success" "APT UPDATE COMPLETE" \
    "✅ 12 packages updated successfully" \
    "⏰  Execution time: 42 seconds" \
    "📦 Updates: firefox (91.0), git (2.34), python3 (3.9.7)" \
    "🔄 3 packages held back due to dependencies" \
    "" \
    "Next update due: 5 days (based on 7-day interval)"
echo

echo "Warning/Skip Box:"
draw_box "warning" "FLATPAK UPDATE SKIPPED" \
    "⚠️  Skipped - Last update was 2 days ago" \
    "📅 Configured interval: 7 days" \
    "⏭️  Next update scheduled: 5 days from now" \
    "" \
    "Use --force to override interval checking"
echo

echo "Error Box:"
draw_box "error" "SNAP UPDATE FAILED" \
    "❌ Failed to refresh snaps" \
    "⏰  Execution time: 15 seconds" \
    "🔍 Error: network timeout during download" \
    "💡 Suggestion: Check internet connection and retry" \
    "" \
    "View detailed logs: ~/.upkep/logs/snap_update.log"
echo

echo "Info Box:"
draw_box "info" "SYSTEM STATUS" \
    "🖥️  System: Ubuntu 22.04 LTS" \
    "💾 Disk: 89.4GB free" \
    "📊 Total modules: 7" \
    "🕒 Last run: 2 hours ago"
echo

# =============================================================================
# 4. MODULE OVERVIEW TABLE
# =============================================================================
echo "4. Module Overview Table:"
echo

# Create a module overview table
box_top "accent_cyan" "SYSTEM MAINTENANCE STATUS"
box_line "accent_cyan" "Module" "Last Run" "Status" "Next Due"
box_line "accent_cyan" "─────" "────────" "──────" "────────"
box_line "accent_cyan" "Package Updates" "" "" ""
box_line "accent_cyan" "├─ APT" "2 days ago" "$(get_color "success")✅ Done${RESET}" "5 days"
box_line "accent_cyan" "├─ Snap" "2 days ago" "$(get_color "success")✅ Done${RESET}" "5 days"
box_line "accent_cyan" "└─ Flatpak" "6 days ago" "$(get_color "warning")⚠️  Due${RESET}" "Now"
box_line "accent_cyan" "System Cleanup" "" "" ""
box_line "accent_cyan" "├─ Package Cache" "1 day ago" "$(get_color "success")✅ Done${RESET}" "2 days"
box_line "accent_cyan" "└─ Temp Files" "4 days ago" "$(get_color "warning")⚠️  Due${RESET}" "Now"
box_line "accent_cyan" "Custom Modules" "" "" ""
box_line "accent_cyan" "└─ Docker Cleanup" "Never" "$(get_color "info")📋 New${RESET}" "Setup"
box_bottom "accent_cyan"
echo

# =============================================================================
# 5. PROGRESS INDICATORS
# =============================================================================
echo "5. Progress Indicators:"
echo

echo "Real-time Execution Feedback:"
echo -e "$(get_color "accent_magenta")🔄 Updating APT repositories...${RESET}"
echo -e "├─ Reading package lists... $(get_color "success")✅ Done${RESET}"
echo -e "├─ Building dependency tree... $(get_color "accent_magenta")🔄 In progress${RESET}"
echo -e "└─ Reading state information... $(get_color "info")⏳ Waiting${RESET}"
echo

echo "Progress Bar:"
echo -e "$(get_color "accent_magenta")📦 Installing updates (12 packages)...${RESET}"
echo -e "██████████▓▓▓▓▓▓▓▓▓▓ 52% (6/12) - Installing firefox..."
echo

echo "Step-by-Step Results:"
echo -e "$(get_color "accent_cyan")🔧 System Cleanup Operations:${RESET}"
echo -e "├─ $(get_color "cleanup")🗑️  Removing unused packages... $(get_color "success")✅ 23 packages removed${RESET}"
echo -e "├─ $(get_color "cleanup")🧹 Cleaning package cache... $(get_color "success")✅ 147MB freed${RESET}"
echo -e "├─ $(get_color "cleanup")📁 Emptying temp directories... $(get_color "warning")⚠️ 2 files skipped (in use)${RESET}"
echo -e "└─ $(get_color "cleanup")🔄 Updating locate database... $(get_color "success")✅ Complete${RESET}"
echo -e "$(get_color "info")📊 Total space freed: 231MB${RESET}"
echo

# =============================================================================
# 6. DASHBOARD STATUS DISPLAY
# =============================================================================
echo "6. Dashboard Status Display:"
echo

draw_box "accent_cyan" "upKep System Status" \
    "" \
    "🖥️  System: Ubuntu 22.04 LTS │ 🕒 Last run: 2 hours ago" \
    "💾 Disk: 89.4GB free         │ 📊 Total modules: 7" \
    ""

echo -e "$(get_color "accent_magenta")⚡ Quick Actions:${RESET}"
echo -e "├─ upkep run           # Run all due operations"
echo -e "├─ upkep run --force   # Force run all operations"
echo -e "├─ upkep status        # Show detailed status"
echo -e "└─ upkep config        # Configure settings"
echo

echo -e "$(get_color "warning")🎯 Due Now (2):${RESET}"
echo -e "├─ Flatpak Update      │ Last run: 8 days ago"
echo -e "└─ Docker Cleanup      │ Last run: Never"
echo

echo -e "$(get_color "success")✅ Recent Success (3):${RESET}"
echo -e "├─ APT Update          │ 12 packages updated (2 hours ago)"
echo -e "├─ Package Cleanup     │ 23 packages removed (2 hours ago)"
echo -e "└─ System Files        │ 147MB freed (2 hours ago)"
echo

# =============================================================================
# 7. SECTION HEADERS & DIVIDERS
# =============================================================================
echo "7. Section Headers & Dividers:"
echo

echo -e "$(get_color "accent_cyan")═══════════════════ PACKAGE UPDATES ═══════════════════${RESET}"
echo "Package update operations would go here..."
echo

echo -e "$(get_color "accent_cyan")─────────────────── System Cleanup ───────────────────${RESET}"
echo "System cleanup operations would go here..."
echo

echo -e "$(get_color "accent_magenta")▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ EXECUTION RESULTS ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
echo "Execution results would be displayed here..."
echo

# =============================================================================
# 8. STATUS ICONS & INDICATORS
# =============================================================================
echo "8. Status Icons & Indicators:"
echo

echo "Standard Icon Set:"
echo -e "$(get_color "success")✅ Done/Success${RESET}       $(get_color "accent_magenta")🔄 In Progress${RESET}       $(get_color "info")⏸️ Paused${RESET}"
echo -e "$(get_color "error")❌ Failed/Error${RESET}       $(get_color "warning")⚠️ Warning/Due${RESET}       $(get_color "info")📋 New/Unconfigured${RESET}"
echo -e "$(get_color "info")⏰ Timing Info${RESET}        $(get_color "info")📊 Statistics${RESET}        $(get_color "info")💡 Suggestion${RESET}"
echo -e "$(get_color "accent_magenta")🔧 Configuration${RESET}      $(get_color "info")📦 Package Info${RESET}      $(get_color "error")🗑️ Cleanup${RESET}"
echo -e "$(get_color "info")🔍 Details/Logs${RESET}       $(get_color "info")⏭️ Skip/Next${RESET}         $(get_color "warning")🎯 Action Required${RESET}"
echo

# =============================================================================
# 9. ENHANCED SPINNER DEMONSTRATION
# =============================================================================
echo "9. Enhanced Spinner Demonstration:"
echo

echo "Starting enhanced spinner test (will run for 2 seconds)..."
(
    sleep 2
    echo "Spinner test completed"
) &
spinner_pid=$!
spinner $spinner_pid "Enhanced spinner test"
echo

# =============================================================================
# 10. LEGACY COMPATIBILITY
# =============================================================================
echo "10. Legacy Compatibility:"
echo

# Set up legacy environment variables
export SKIP_NOTE="Test skip note for legacy compatibility"
export APT_STATUS="✅ Done"
export SNAP_STATUS="⚠️ Due"
export FLATPAK_STATUS="❌ Failed"
export CLEANUP_STATUS="📋 New"

echo "Legacy draw_summary function:"
draw_summary
echo

# =============================================================================
# 11. RESPONSIVE DESIGN TEST
# =============================================================================
echo "11. Responsive Design Test:"
echo

echo "Current terminal width: $(get_terminal_width) characters"
echo "Current box width: $(get_box_width) characters"
echo "Color support: $(detect_color_support)"
echo

# =============================================================================
# 12. CONTEXTUAL HELP & GUIDANCE
# =============================================================================
echo "12. Contextual Help & Guidance:"
echo

draw_box "warning" "SYSTEM NOTICE" \
    "!  3 modules failed on last run." \
    "💡 Suggestion: Run 'upkep show failed' to see details" \
    "   Or try 'upkep run --fix' to attempt automatic recovery"
echo

draw_box "info" "QUICK SETUP DETECTED" \
    "🎯 Quick setup detected." \
    "💡 Tip: Run 'upkep config --wizard' for guided configuration"
echo

# =============================================================================
# 13. TIME DISPLAY COMPONENTS
# =============================================================================
echo "13. Time Display Components:"
echo

echo "Relative time formatting examples:"
echo -e "$(get_color "info")⏰  Just now${RESET}"
echo -e "$(get_color "info")⏰  5 minutes ago${RESET}"
echo -e "$(get_color "info")⏰  2 hours ago${RESET}"
echo -e "$(get_color "info")⏰  3 days ago${RESET}"
echo -e "$(get_color "info")⏰  Jan 15${RESET}"
echo

echo "Duration formatting examples:"
echo -e "$(get_color "info")⏰  45s${RESET}"
echo -e "$(get_color "info")⏰  2m 30s${RESET}"
echo -e "$(get_color "info")⏰  1h 15m${RESET}"
echo

echo "Next due calculation examples:"
echo -e "$(get_color "error")Due now${RESET}"
echo -e "$(get_color "warning")Due in 3 hours${RESET}"
echo -e "$(get_color "info")Due in 5 days${RESET}"
echo

# =============================================================================
# 14. STATE TIMELINE VISUALIZATION
# =============================================================================
echo "14. State Timeline Visualization:"
echo

echo -e "$(get_color "accent_cyan")📅 Maintenance Schedule:${RESET}"
echo -e "Today     ├─ Docker Cleanup $(get_color "warning")(due now)${RESET}"
echo -e "          └─ Temp Files $(get_color "warning")(due now)${RESET}"
echo -e "Tomorrow  └─ (no operations scheduled)"
echo -e "+3 days   └─ Log rotation"
echo -e "+5 days   ├─ APT Updates"
echo -e "          ├─ Snap Updates"
echo -e "          └─ System cleanup"
echo -e "+7 days   └─ Full system maintenance"
echo

echo -e "$(get_color "accent_cyan")📈 Recent Activity:${RESET}"
echo -e "2 hours ago   $(get_color "success")✅ Full maintenance run (4 modules, 2m 34s)${RESET}"
echo -e "Yesterday     $(get_color "warning")⚠️ Flatpak update skipped (interval not met)${RESET}"
echo -e "2 days ago    $(get_color "success")✅ Emergency cleanup (98% disk usage)${RESET}"
echo -e "1 week ago    $(get_color "success")✅ Scheduled maintenance (all modules)${RESET}"
echo

# =============================================================================
# 15. PERFORMANCE CONTEXT
# =============================================================================
echo "15. Performance Context:"
echo

draw_box "success" "APT UPDATE COMPLETE" \
    "✅ 12 packages updated successfully" \
    "📊 Performance: Faster than usual (+23s vs 65s average)" \
    "💾 Impact: 147MB downloaded, 12 packages updated" \
    "🔄 Next run: 7 days (configured interval)"
echo

# =============================================================================
# FINAL SUMMARY
# =============================================================================
echo "=== Enhanced Visual Design Check Complete ==="
echo
echo -e "$(get_color "success")✅ All design elements demonstrated successfully!${RESET}"
echo
echo "Design elements showcased:"
echo "• Enhanced ASCII branding"
echo "• Terminal-first dark theme color palette"
echo "• Enhanced box drawing system"
echo "• Module overview tables"
echo "• Progress indicators"
echo "• Dashboard status display"
echo "• Section headers & dividers"
echo "• Status icons & indicators"
echo "• Enhanced spinner"
echo "• Legacy compatibility"
echo "• Responsive design"
echo "• Contextual help & guidance"
echo "• Time display components"
echo "• State timeline visualization"
echo "• Performance context"
echo
echo -e "$(get_color "accent_cyan")🎨 Visual design system ready for production use!${RESET}"
