#!/bin/bash
# Simple test for core layout builder components

echo "Testing core layout builder components..."

# Test 1: Palette system
echo "1. Testing palette system..."
source scripts/core/palette.sh
if [[ "$(get_emoji success)" == "✅" ]]; then
    echo "   ✅ Palette system works"
else
    echo "   ❌ Palette system failed"
    exit 1
fi

# Test 2: Width helpers
echo "2. Testing width helpers..."
if [[ "$(python3 scripts/core/width_helpers.py width 'hello')" == "5" ]]; then
    echo "   ✅ Width helpers work"
else
    echo "   ❌ Width helpers failed"
    exit 1
fi

# Test 3: Box builder
echo "3. Testing box builder..."
source scripts/core/box_builder.sh
if [[ "$(make_text 'hello')" == "text;hello" ]]; then
    echo "   ✅ Box builder works"
else
    echo "   ❌ Box builder failed"
    exit 1
fi

# Test 4: Layout loader
echo "4. Testing layout loader..."
source scripts/core/layout_loader.sh
box_id=$(box_new 40 "Test" info)
if [[ -n "$box_id" ]]; then
    echo "   ✅ Layout loader works"
else
    echo "   ❌ Layout loader failed"
    exit 1
fi

# Test 5: Simple box rendering
echo "5. Testing box rendering..."
output=$(box_render "$box_id" 2>/dev/null | head -1)
if [[ -n "$output" ]]; then
    echo "   ✅ Box rendering works"
    echo "   Output: $output"
else
    echo "   ❌ Box rendering failed"
    exit 1
fi

echo "All core components working correctly!" 