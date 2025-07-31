#!/bin/bash

# Test HTML-like Layout Syntax
# This demonstrates the new HTML-like syntax for defining layouts

SCRIPT_DIR="$(cd "$(dirname "$0")/../scripts/core" && pwd)"
source "${SCRIPT_DIR}/layout_dsl_v3.sh"

echo "=== HTML-like Layout Syntax Test ==="
echo "This demonstrates HTML-like syntax for defining layouts"
echo

echo "1. Simple Multi-line Box:"
create_html_box "System Information" 60 "info" \
    "Operating System: Ubuntu 22.04 LTS" \
    "Kernel Version: 5.15.0-generic" \
    "Architecture: x86_64" \
    "Uptime: 3 days, 7 hours"
echo

echo "2. Table with Headers and Data:"
create_html_table "Package Status" 80 "info" \
    "Package|Status|Version|Last Updated" \
    "Package A|<color=success>✅ Installed</color>|1.2.3|2 hours ago" \
    "Package B|<color=warning>⚠️ Pending</color>|2.1.0|1 day ago" \
    "Package C|<color=error>❌ Failed</color>|0.9.5|3 days ago"
echo

echo "3. Status Report with Sections:"
create_html_report "System Status Report" 85 "major" \
    "CPU|4 cores, 25% usage, normal operation" \
    "Memory|8GB total, 85% used, high usage warning" \
    "Disk|500GB, 45% used, good condition" \
    "Network|Connected, 100Mbps, stable"
echo

echo "4. Comparison Table:"
create_html_comparison "System Comparison" 70 "info" \
    "OS" "Ubuntu 22.04" \
    "Kernel" "5.15.0" \
    "Architecture" "x86_64" \
    "Uptime" "3 days"
echo

echo "5. Raw HTML Layout Syntax:"
# Define layout as a string with HTML-like tags
layout="
# This is a comment
<header>Component|Status|Details|Actions</header>
<divider/>
<data>System|<color=success>✅ Operational</color>|All systems running|Monitor</data>
<data>Updates|<color=warning>⚠️ Pending</color>|12 packages available|Install</data>
<divider/>
<data>Security|<color=success>✅ Secure</color>|No vulnerabilities|Continue</data>
<data>Backup|<color=error>❌ Failed</color>|Last backup: 5 days ago|Fix</data>
<divider/>
<data>Summary|<color=info>📊 Mixed</color>|Mostly good, some issues|Review</data>
"

parse_html_layout "$layout" 90 "Detailed System Report" "emphasis"
echo

echo "6. Mixed Content with HTML:"
create_html_box "Installation Log" 75 "info" \
    "Starting installation process..." \
    "<color=success>✅ Dependencies resolved</color>" \
    "<color=info>📦 Downloading packages...</color>" \
    "<color=warning>⚠️ 3 packages held back</color>" \
    "<color=success>✅ Installation completed</color>"
echo

echo "7. Complex Layout with Multiple Row Types:"
complex_layout="
# Complex layout example
<row><color=info>📊 System Dashboard</color></row>
<divider/>
<cells>Component|Status|Details</cells>
<data>CPU|<color=success>✅ Normal</color>|4 cores, 25% usage</data>
<data>Memory|<color=warning>⚠️ High</color>|8GB total, 85% used</data>
<data>Disk|<color=success>✅ Good</color>|500GB, 45% used</data>
<divider/>
<row><color=info>📋 Summary</color></row>
<row>System running normally with some high memory usage</row>
"

parse_html_layout "$complex_layout" 85 "Complex Layout Example" "major"
echo

echo "=== HTML-like Layout Syntax Summary ==="
echo
echo "✅ HTML-like tags for defining layouts"
echo "✅ <row>content</row> - Simple single-cell rows"
echo "✅ <cells>cell1|cell2|cell3</cells> - Multi-cell rows"
echo "✅ <header>header1|header2</header> - Header rows"
echo "✅ <data>data1|data2</data> - Data rows"
echo "✅ <divider/> - Row dividers"
echo "✅ Comments with #"
echo "✅ Mixed content with HTML-like syntax"
echo
echo "Usage Examples:"
echo
echo "Simple box:"
echo "  create_html_box \"Title\" 60 \"info\" \"Line 1\" \"Line 2\" \"Line 3\""
echo
echo "Table:"
echo "  create_html_table \"Title\" 80 \"info\" \"Col1|Col2|Col3\" \"Data1|Data2|Data3\""
echo
echo "Status report:"
echo "  create_html_report \"Title\" 80 \"major\" \"Section1|Content1\" \"Section2|Content2\""
echo
echo "Raw layout:"
echo "  layout=\"<header>Col1|Col2</header><divider/><data>Data1|Data2</data>\""
echo "  parse_html_layout \"\$layout\" 70 \"Title\" \"info\""
echo 