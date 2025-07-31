#!/bin/bash

# Test Advanced DSL Functions
# This demonstrates the new advanced DSL functions for complex layouts

SCRIPT_DIR="$(cd "$(dirname "$0")/../scripts/core" && pwd)"
source "${SCRIPT_DIR}/layout_dsl_v2.sh"

echo "=== Advanced DSL Functions Test ==="
echo "This demonstrates the new advanced DSL functions"
echo

echo "1. Multi-line Box:"
create_multiline_box --title="System Information" --width="60" \
    "Operating System: Ubuntu 22.04 LTS" \
    "Kernel Version: 5.15.0-generic" \
    "Architecture: x86_64" \
    "Uptime: 3 days, 7 hours"
echo

echo "2. Advanced Table with Headers and Data:"
create_table --title="Package Status" --width="80" --style="info" \
    --headers "Package" "Status" "Version" "Last Updated" \
    --data "Package A|<color=success>✅ Installed</color>|1.2.3|2 hours ago" \
    --data "Package B|<color=warning>⚠️ Pending</color>|2.1.0|1 day ago" \
    --data "Package C|<color=error>❌ Failed</color>|0.9.5|3 days ago" \
    --divider \
    --data "Total|3 packages|Mixed|Various"
echo

echo "3. Status Report with Sections:"
create_status_report --title="System Status Report" --width="85" --style="major" \
    --section="CPU|4 cores, 25% usage, normal operation" \
    --section="Memory|8GB total, 85% used, high usage warning" \
    --section="Disk|500GB, 45% used, good condition" \
    --section="Network|Connected, 100Mbps, stable"
echo

echo "4. Comparison Table:"
create_comparison_table --title="System Comparison" --width="70" --style="info" \
    "OS" "Ubuntu 22.04" \
    "Kernel" "5.15.0" \
    "Architecture" "x86_64" \
    "Uptime" "3 days"
echo

echo "5. Complex Table with Dividers:"
create_table --title="Detailed System Report" --width="90" --style="emphasis" \
    --headers "Component" "Status" "Details" "Actions" \
    --data "System|<color=success>✅ Operational</color>|All systems running|Monitor" \
    --data "Updates|<color=warning>⚠️ Pending</color>|12 packages available|Install" \
    --divider \
    --data "Security|<color=success>✅ Secure</color>|No vulnerabilities|Continue" \
    --data "Backup|<color=error>❌ Failed</color>|Last backup: 5 days ago|Fix" \
    --divider \
    --data "Summary|<color=info>📊 Mixed</color>|Mostly good, some issues|Review"
echo

echo "6. Multi-line with Mixed Content:"
create_multiline_box --title="Installation Log" --width="75" --style="info" \
    "Starting installation process..." \
    "<color=success>✅ Dependencies resolved</color>" \
    "<color=info>📦 Downloading packages...</color>" \
    "<color=warning>⚠️ 3 packages held back</color>" \
    "<color=success>✅ Installation completed</color>"
echo

echo "=== Advanced DSL Functions Summary ==="
echo
echo "✅ create_multiline_box -- Multiple lines of content"
echo "✅ create_table -- Complex tables with headers, data, dividers"
echo "✅ create_status_report -- Sectioned reports with dividers"
echo "✅ create_comparison_table -- Simple comparison layouts"
echo "✅ Mixed content -- HTML-like syntax with colors and emojis"
echo
echo "Usage Examples:"
echo
echo "Multi-line box:"
echo "  create_multiline_box --title=\"Title\" --width=\"60\" \"Line 1\" \"Line 2\" \"Line 3\""
echo
echo "Advanced table:"
echo "  create_table --title=\"Title\" --headers \"Col1\" \"Col2\" --data \"Data1|Data2\" --divider"
echo
echo "Status report:"
echo "  create_status_report --title=\"Title\" --section=\"Section1|Content1\" --section=\"Section2|Content2\""
echo
echo "Comparison table:"
echo "  create_comparison_table --title=\"Title\" \"Item1\" \"Value1\" \"Item2\" \"Value2\""
echo 