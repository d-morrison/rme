#!/usr/bin/env python3
"""
Script to detect non-standard characters in .qmd and .R files.

This script checks for curly quotes and other non-standard characters that
can cause issues in Quarto/R projects, such as:
- " (U+201C) - Left double quotation mark
- " (U+201D) - Right double quotation mark
- ' (U+2018) - Left single quotation mark
- ' (U+2019) - Right single quotation mark
- – (U+2013) - En dash
- — (U+2014) - Em dash

These should typically be replaced with their ASCII equivalents:
- " (U+0022) - Quotation mark
- ' (U+0027) - Apostrophe
- - (U+002D) - Hyphen-minus
"""

import sys
from pathlib import Path
from typing import List, Tuple, Dict

# Non-standard characters to detect
NON_STANDARD_CHARS = {
    '\u201C': 'Left double quotation mark',
    '\u201D': 'Right double quotation mark',
    '\u2018': 'Left single quotation mark',
    '\u2019': 'Right single quotation mark',
    '\u2013': 'En dash',
    '\u2014': 'Em dash',
}


def check_file(file_path: Path) -> List[Tuple[int, int, str, str]]:
    """
    Check a file for non-standard characters.
    
    Args:
        file_path: Path to the file to check
        
    Returns:
        List of tuples (line_number, column, character, description)
    """
    issues = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line_num, line in enumerate(f, start=1):
                for col, char in enumerate(line, start=1):
                    if char in NON_STANDARD_CHARS:
                        issues.append((
                            line_num,
                            col,
                            char,
                            NON_STANDARD_CHARS[char]
                        ))
    except UnicodeDecodeError as e:
        print(f"Error: {file_path} has encoding issues: {e}", file=sys.stderr)
        return []
    except Exception as e:
        print(f"Error reading {file_path}: {e}", file=sys.stderr)
        return []
    
    return issues


def find_files(root_dir: Path, extensions: List[str]) -> List[Path]:
    """
    Find all files with given extensions in the directory tree.
    
    Args:
        root_dir: Root directory to search
        extensions: List of file extensions to search for (e.g., ['.qmd', '.R'])
        
    Returns:
        List of matching file paths
    """
    files = []
    for ext in extensions:
        files.extend(root_dir.glob(f'**/*{ext}'))
    return sorted(files)


def main() -> int:
    """
    Main function to check all .qmd and .R files for non-standard characters.
    
    Returns:
        0 if no issues found, 1 if issues found
    """
    root_dir = Path('.')
    extensions = ['.qmd', '.R']
    
    print("Checking for non-standard characters in .qmd and .R files...\n")
    
    files = find_files(root_dir, extensions)
    
    if not files:
        print("No .qmd or .R files found.")
        return 0
    
    total_issues = 0
    files_with_issues: Dict[Path, List[Tuple[int, int, str, str]]] = {}
    
    for file_path in files:
        issues = check_file(file_path)
        if issues:
            files_with_issues[file_path] = issues
            total_issues += len(issues)
    
    if not files_with_issues:
        print(f"✓ No non-standard characters found in {len(files)} file(s).")
        return 0
    
    # Print detailed report
    print(f"✗ Found {total_issues} non-standard character(s) in {len(files_with_issues)} file(s):\n")
    
    for file_path, issues in files_with_issues.items():
        print(f"{file_path}:")
        for line_num, col, char, description in issues:
            print(f"  Line {line_num}, Column {col}: {description}")
            # Show the character in a visible way
            print(f"    Found: '{char}' (U+{ord(char):04X})")
        print()
    
    print("Please replace these characters with their ASCII equivalents:")
    print('  \u201C or \u201D -> " (standard double quote)')
    print('  \u2018 or \u2019 -> \' (standard single quote)')
    print('  \u2013 or \u2014 -> - (standard hyphen)')
    print()
    
    return 1


if __name__ == '__main__':
    sys.exit(main())
