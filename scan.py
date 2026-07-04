import os
import re

lib_dir = r"c:\Users\himan\Documents\Repositories\LabLedger\lib"

# Regex for finding EdgeInsets and BorderRadius
edge_insets_pattern = re.compile(r'EdgeInsets\.(all|only|symmetric|fromLTRB)\s*\(([^)]+)\)')
radius_pattern = re.compile(r'(BorderRadius|Radius)\.(circular|all|only)\s*\(([^)]+)\)')

# padding constants in constants.dart
padding_constants = ['tinyPadding', 'minimalPadding', 'smallPadding', 'defaultPadding', 'mediumPadding', 'largePadding', 'xlargePadding']
radius_constants = ['tinyRadius', 'minimalBorderRadius', 'smallRadius', 'defaultRadius', 'mediumRadius', 'largeRadius']

def has_hardcoded_number(text):
    # check if there's any standalone digit/number that isn't part of a constant name
    # simpler: if it contains any digit and doesn't contain a constant name
    return bool(re.search(r'\d+', text))

report = {}

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            for i, line in enumerate(lines):
                line_num = i + 1
                
                # Check EdgeInsets
                for match in edge_insets_pattern.finditer(line):
                    args = match.group(2)
                    if has_hardcoded_number(args) and not any(c in args for c in padding_constants):
                        if filepath not in report:
                            report[filepath] = []
                        report[filepath].append((line_num, match.group(0), 'EdgeInsets'))
                
                # Check Radius
                for match in radius_pattern.finditer(line):
                    args = match.group(3)
                    if has_hardcoded_number(args) and not any(c in args for c in radius_constants):
                        if filepath not in report:
                            report[filepath] = []
                        report[filepath].append((line_num, match.group(0), 'Radius'))

with open('hardcoded_report.txt', 'w', encoding='utf-8') as f:
    for filepath, issues in report.items():
        f.write(f"File: {filepath}\n")
        for line_num, match_text, issue_type in issues:
            f.write(f"  Line {line_num}: {match_text}\n")
        f.write("\n")
