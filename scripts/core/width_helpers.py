#!/usr/bin/env python3
"""
upKep Layout Builder - Unicode Width Calculation Helper
Provides accurate display width calculation for Unicode characters, emoji, and multi-byte sequences.
Based on layout_builder_spec.md v1.2

Uses wcwidth for accurate Unicode width calculation, supporting:
- Emoji and combining characters
- Multi-byte sequences
- Zero-width and double-width characters
- Python std-lib only (no external dependencies)
"""

import sys
import unicodedata
from typing import List, Tuple, Union


def wcwidth(char: str) -> int:
    """
    Calculate the display width of a Unicode character.
    
    Args:
        char: Single Unicode character
        
    Returns:
        Display width (0, 1, or 2)
    """
    if not char:
        return 0
    
    # Handle common cases first for performance
    if ord(char) < 0x20:  # Control characters
        return 0
    elif ord(char) < 0x7F:  # ASCII
        return 1
    
    # Use unicodedata for Unicode width calculation
    try:
        # Check for combining characters (zero width)
        if unicodedata.combining(char):
            return 0
        
        # Check for specific Unicode categories
        category = unicodedata.category(char)
        
        # Zero-width characters
        if category in ('Cf', 'Cc', 'Cs', 'Co', 'Cn'):  # Format, Control, Surrogate, Private, Unassigned
            return 0
        
        # Double-width characters (East Asian)
        if category in ('W', 'F'):  # Wide, Fullwidth
            return 2
        
        # Check for specific Unicode ranges
        code_point = ord(char)
        
        # Check for variation selectors (zero width)
        if 0xFE00 <= code_point <= 0xFE0F:
            return 0
        
        # Comprehensive emoji ranges (double-width)
        if (0x1F600 <= code_point <= 0x1F64F or  # Emoticons
            0x1F300 <= code_point <= 0x1F5FF or  # Miscellaneous Symbols and Pictographs
            0x1F680 <= code_point <= 0x1F6FF or  # Transport and Map Symbols
            0x1F1E0 <= code_point <= 0x1F1FF or  # Regional Indicator Symbols
            0x2600 <= code_point <= 0x26FF or    # Miscellaneous Symbols
            0x2700 <= code_point <= 0x27BF or    # Dingbats
            0x1F900 <= code_point <= 0x1F9FF or  # Supplemental Symbols and Pictographs
            0x1F018 <= code_point <= 0x1F270 or  # Various emoji ranges
            0x23F0 <= code_point <= 0x23FF or    # Technical Symbols (includes ⏱)
            0x231A <= code_point <= 0x231B or    # Miscellaneous Technical (includes ⌚)
            0x2194 <= code_point <= 0x2199 or    # Arrows (includes ↔)
            0x21A9 <= code_point <= 0x21AA or    # Arrows (includes ↩)
            0x2934 <= code_point <= 0x2935 or    # Arrows (includes ⤴)
            0x2B05 <= code_point <= 0x2B07 or    # Arrows (includes ⬅)
            0x2B1B <= code_point <= 0x2B1C or    # Geometric Shapes (includes ⬛)
            0x2B50 <= code_point <= 0x2B50 or    # White Medium Star
            0x3030 <= code_point <= 0x3030 or    # Wavy Dash
            0x303D <= code_point <= 0x303D or    # Part Alternation Mark
            0x3297 <= code_point <= 0x3299 or    # Circled Ideographs
            0x3299 <= code_point <= 0x3299):     # Circled Ideograph Secret
            return 2
        
        # Default to single width
        return 1
        
    except (ValueError, TypeError):
        # Fallback for invalid characters
        return 1


def string_width(text: str) -> int:
    """
    Calculate the display width of a string.
    
    Args:
        text: Unicode string
        
    Returns:
        Total display width
    """
    if not text:
        return 0
    
    # Let wcwidth handle all characters automatically
    # No special cases needed - the Unicode ranges in wcwidth should cover all emojis
    
    return sum(wcwidth(char) for char in text)


def truncate_string(text: str, max_width: int, mode: str = "ellipsis") -> str:
    """
    Truncate a string to fit within a specified display width.
    
    Args:
        text: Input string
        max_width: Maximum display width
        mode: Truncation mode ("ellipsis" or "wrap")
        
    Returns:
        Truncated string
    """
    if not text or max_width <= 0:
        return ""
    
    if mode == "ellipsis":
        return truncate_with_ellipsis(text, max_width)
    elif mode == "wrap":
        return truncate_with_wrap(text, max_width)
    else:
        raise ValueError(f"Unknown truncation mode: {mode}")


def truncate_with_ellipsis(text: str, max_width: int) -> str:
    """
    Truncate string with ellipsis if it exceeds max_width.
    
    Args:
        text: Input string
        max_width: Maximum display width
        
    Returns:
        Truncated string with ellipsis if needed
    """
    if string_width(text) <= max_width:
        return text
    
    # Account for ellipsis width
    ellipsis = "…"
    ellipsis_width = string_width(ellipsis)
    available_width = max_width - ellipsis_width
    
    if available_width <= 0:
        return ellipsis
    
    # Find the truncation point
    current_width = 0
    for i, char in enumerate(text):
        char_width = wcwidth(char)
        if current_width + char_width > available_width:
            return text[:i] + ellipsis
        current_width += char_width
    
    return text + ellipsis


def truncate_with_wrap(text: str, max_width: int) -> str:
    """
    Wrap text to fit within max_width, respecting word boundaries.
    
    Args:
        text: Input string
        max_width: Maximum display width per line
        
    Returns:
        Wrapped text
    """
    if not text or max_width <= 0:
        return ""
    
    words = text.split()
    lines = []
    current_line = ""
    current_width = 0
    
    for word in words:
        word_width = string_width(word)
        
        # Check if word fits on current line
        if current_width + word_width + (1 if current_line else 0) <= max_width:
            if current_line:
                current_line += " " + word
                current_width += 1 + word_width
            else:
                current_line = word
                current_width = word_width
        else:
            # Start new line
            if current_line:
                lines.append(current_line)
            current_line = word
            current_width = word_width
    
    if current_line:
        lines.append(current_line)
    
    return "\n".join(lines)


def fit_cell(text: str, width: int, mode: str = "ellipsis") -> str:
    """
    Fit text to a cell of specified width.
    
    Args:
        text: Input text
        width: Cell width
        mode: Fitting mode ("ellipsis" or "wrap")
        
    Returns:
        Fitted text
    """
    return truncate_string(text, width, mode)


def get_column_widths(texts: List[str], min_width: int = 5) -> List[int]:
    """
    Calculate optimal column widths for a list of texts.
    
    Args:
        texts: List of text strings
        min_width: Minimum width per column
        
    Returns:
        List of calculated widths
    """
    if not texts:
        return []
    
    # Calculate natural widths
    natural_widths = [max(string_width(text), min_width) for text in texts]
    
    return natural_widths


def distribute_extra_space(widths: List[int], total_available: int) -> List[int]:
    """
    Distribute extra space among columns proportionally.
    
    Args:
        widths: Current column widths
        total_available: Total available width
        
    Returns:
        Adjusted column widths
    """
    if not widths:
        return []
    
    total_min = sum(widths)
    
    if total_min <= total_available:
        # Distribute extra space round-robin
        extra = total_available - total_min
        adjusted = widths.copy()
        
        for i in range(extra):
            adjusted[i % len(adjusted)] += 1
        
        return adjusted
    else:
        # Shrink proportionally, maintaining minimum width
        min_width = 5
        adjusted = []
        
        for width in widths:
            # Calculate proportional reduction
            ratio = total_available / total_min
            new_width = max(int(width * ratio), min_width)
            adjusted.append(new_width)
        
        return adjusted


# Command-line interface for testing
def main():
    """Command-line interface for testing width calculations."""
    if len(sys.argv) < 2:
        print("Usage: width_helpers.py <command> [args...]")
        print("Commands:")
        print("  width <text>           - Calculate string width")
        print("  truncate <text> <width> [mode] - Truncate text")
        print("  fit <text> <width> [mode]      - Fit text to width")
        return 1
    
    command = sys.argv[1]
    
    if command == "width":
        if len(sys.argv) < 3:
            print("Error: text required")
            return 1
        text = sys.argv[2]
        print(string_width(text))
    
    elif command == "truncate":
        if len(sys.argv) < 4:
            print("Error: text and width required")
            return 1
        text = sys.argv[2]
        width = int(sys.argv[3])
        mode = sys.argv[4] if len(sys.argv) > 4 else "ellipsis"
        print(truncate_string(text, width, mode))
    
    elif command == "fit":
        if len(sys.argv) < 4:
            print("Error: text and width required")
            return 1
        text = sys.argv[2]
        width = int(sys.argv[3])
        mode = sys.argv[4] if len(sys.argv) > 4 else "ellipsis"
        print(fit_cell(text, width, mode))
    
    else:
        print(f"Unknown command: {command}")
        return 1
    
    return 0


if __name__ == "__main__":
    sys.exit(main()) 