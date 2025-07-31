#!/bin/bash

# Test Attribute Ambiguity in DSL
# This demonstrates the problem with attribute names in content

# Get the script directory more reliably
SCRIPT_DIR="$(cd "$(dirname "$0")/../scripts/core" && pwd)"
source "${SCRIPT_DIR}/layout_dsl.sh"

echo "=== Attribute Ambiguity Test ==="
echo "This test shows potential problems with attribute names in content"
echo

echo "1. Problem: Content contains attribute names:"
echo "   Content: 'The color is success and the style is warning'"
echo "   This could be confused with actual attributes!"
echo

create_quick_box "Ambiguous Content" "The color is success and the style is warning" "info" 60
echo

echo "2. Problem: HTML-like content with attribute-like text:"
echo "   Content: 'Use color=success for green text'"
echo "   This could be parsed as HTML tags!"
echo

# This would be problematic if we had HTML parsing
create_quick_box "HTML-like Content" "Use color=success for green text" "info" 60
echo

echo "3. Problem: Emoji names in content:"
echo "   Content: 'The emoji is success and the status is warning'"
echo "   This could be confused with emoji keys!"
echo

create_quick_box "Emoji-like Content" "The emoji is success and the status is warning" "info" 60
echo

echo "=== Solutions ==="
echo

echo "Solution 1: Use explicit parameter names"
echo "   create_quick_box --title='Title' --content='Content' --style='info' --width=50"
echo

echo "Solution 2: Use JSON-like structure"
echo "   create_quick_box '{\"title\": \"Title\", \"content\": \"Content\", \"style\": \"info\"}'"
echo

echo "Solution 3: Use HTML-like attributes with explicit syntax"
echo "   create_quick_box '<box style=\"info\" width=\"50\">Content</box>'"
echo

echo "Solution 4: Use escape sequences for literal text"
echo "   create_quick_box 'Content with \\color=success literal text'"
echo

echo "=== Current Status ==="
echo "✅ Current DSL works for simple cases"
echo "⚠️  Potential ambiguity with attribute names in content"
echo "🔧 Need to implement one of the solutions above"
echo 