#!/bin/bash

# Test Approach Comparison
# This demonstrates the difference between manual, DSL v2, and HTML-like approaches

SCRIPT_DIR="$(cd "$(dirname "$0")/../scripts/core" && pwd)"
source "${SCRIPT_DIR}/box_builder.sh"
source "${SCRIPT_DIR}/layout_dsl_v2.sh"
source "${SCRIPT_DIR}/layout_dsl_v3.sh"

echo "=== Layout Approach Comparison ==="
echo "This demonstrates the difference between approaches"
echo

echo "1. MANUAL APPROACH (Writing row data directly):"
echo "┌─────────────────────────────────────────────────────────┐"
echo "│ Requires: box_new, row_new, row_add_cell, box_add_row  │"
echo "│ Pros: Maximum control, direct access to primitives     │"
echo "│ Cons: Verbose, repetitive, error-prone                 │"
echo "└─────────────────────────────────────────────────────────┘"

# Manual approach example
box_data=$(box_new 60 "Manual Approach" "info")
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Name")")
row_data=$(row_add_cell "$row_data" "$(make_text "Status")")
box_data=$(box_add_row "$box_data" "$row_data")
row_data="divider"
box_data=$(box_add_row "$box_data" "$row_data")
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Package A")")
row_data=$(row_add_cell "$row_data" "$(make_html '<color=success>✅ Installed</color>')")
box_data=$(box_add_row "$box_data" "$row_data")
box_render "$box_data"
echo

echo "2. DSL v2 APPROACH (Explicit parameters):"
echo "┌─────────────────────────────────────────────────────────┐"
echo "│ Requires: create_table function                        │"
echo "│ Pros: Clear parameter names, no ambiguity              │"
echo "│ Cons: Still requires manual cell separation            │"
echo "└─────────────────────────────────────────────────────────┘"

create_table --title="DSL v2 Approach" --width="60" --style="info" \
    --headers "Name" "Status" \
    --data "Package A|<color=success>✅ Installed</color>" \
    --divider \
    --data "Package B|<color=warning>⚠️ Pending</color>"
echo

echo "3. HTML-LIKE APPROACH (Declarative syntax):"
echo "┌─────────────────────────────────────────────────────────┐"
echo "│ Requires: create_html_table function                   │"
echo "│ Pros: Familiar syntax, readable, declarative          │"
echo "│ Cons: Learning curve for custom layouts               │"
echo "└─────────────────────────────────────────────────────────┘"

create_html_table "HTML-like Approach" 60 "info" \
    "Name|Status" \
    "Package A|<color=success>✅ Installed</color>" \
    "Package B|<color=warning>⚠️ Pending</color>"
echo

echo "4. RAW HTML LAYOUT (Direct layout definition):"
echo "┌─────────────────────────────────────────────────────────┐"
echo "│ Requires: parse_html_layout function                   │"
echo "│ Pros: Maximum flexibility, familiar HTML-like syntax  │"
echo "│ Cons: More complex for simple layouts                 │"
echo "└─────────────────────────────────────────────────────────┘"

layout="
<header>Name|Status</header>
<divider/>
<data>Package A|<color=success>✅ Installed</color></data>
<data>Package B|<color=warning>⚠️ Pending</color></data>
"
parse_html_layout "$layout" 60 "Raw HTML Layout" "info"
echo

echo "=== Approach Comparison Summary ==="
echo
echo "📊 COMPLEXITY vs CONTROL:"
echo "   Manual     → High control, High complexity"
echo "   DSL v2     → Medium control, Medium complexity"
echo "   HTML-like  → Low complexity, High readability"
echo "   Raw HTML   → High flexibility, Medium complexity"
echo
echo "🎯 USE CASES:"
echo "   Manual     → Custom layouts, learning, debugging"
echo "   DSL v2     → Simple tables, explicit parameters"
echo "   HTML-like  → Common patterns, readable code"
echo "   Raw HTML   → Complex layouts, maximum flexibility"
echo
echo "📝 CODE COMPARISON:"
echo
echo "Manual (15 lines):"
echo "  box_data=\$(box_new 60 \"Title\" \"info\")"
echo "  row_data=\$(row_new)"
echo "  row_data=\$(row_add_cell \"\$row_data\" \"\$(make_text \"Name\")\")"
echo "  row_data=\$(row_add_cell \"\$row_data\" \"\$(make_text \"Status\")\")"
echo "  box_data=\$(box_add_row \"\$box_data\" \"\$row_data\")"
echo "  row_data=\"divider\""
echo "  box_data=\$(box_add_row \"\$box_data\" \"\$row_data\")"
echo "  row_data=\$(row_new)"
echo "  row_data=\$(row_add_cell \"\$row_data\" \"\$(make_text \"Item\")\")"
echo "  row_data=\$(row_add_cell \"\$row_data\" \"\$(make_html '<color=success>✅</color>')\")"
echo "  box_data=\$(box_add_row \"\$box_data\" \"\$row_data\")"
echo "  box_render \"\$box_data\""
echo
echo "DSL v2 (3 lines):"
echo "  create_table --title=\"Title\" --width=\"60\" --style=\"info\" \\"
echo "    --headers \"Name\" \"Status\" \\"
echo "    --data \"Item|<color=success>✅</color>\""
echo
echo "HTML-like (2 lines):"
echo "  create_html_table \"Title\" 60 \"info\" \\"
echo "    \"Name|Status\" \"Item|<color=success>✅</color>\""
echo
echo "Raw HTML (4 lines):"
echo "  layout=\"<header>Name|Status</header><divider/><data>Item|<color=success>✅</color></data>\""
echo "  parse_html_layout \"\$layout\" 60 \"Title\" \"info\""
echo 