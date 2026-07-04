import os
import re

lib_dir = r"c:\Users\himan\Documents\Repositories\LabLedger\lib"
import_str = "import 'package:labledger/constants/constants.dart';"

padding_map = {
    2.0: 'microPadding', 4.0: 'minimalPadding', 6.0: 'tinyPadding', 8.0: 'smallPadding',
    10.0: 'formPadding', 12.0: 'defaultPadding', 14.0: 'intermediatePadding', 16.0: 'mediumPadding',
    20.0: 'largePadding', 24.0: 'xlargePadding', 28.0: 'dialogPadding', 40.0: 'xxlargePadding', 50.0: 'massivePadding'
}
radius_map = {
    2.0: 'microRadius', 4.0: 'tinyRadius', 6.0: 'minimalBorderRadius', 7.0: 'skeletonRadius',
    8.0: 'smallRadius', 10.0: 'dialogRadius', 12.0: 'defaultRadius', 16.0: 'mediumRadius',
    20.0: 'largeRadius', 24.0: 'xlargeRadius', 30.0: 'pillRadius', 50.0: 'circularRadius', 99.0: 'circularRadius', 999.0: 'circularRadius'
}

def replace_padding(match):
    args = match.group(3)
    def replace_num(m):
        num_str = m.group(0)
        try:
            val = float(num_str)
            if val in padding_map:
                return padding_map[val]
        except:
            pass
        return num_str
    new_args = re.sub(r'\b\d+(\.\d+)?\b', replace_num, args)
    return match.group(1) + '(' + new_args + ')'

def replace_radius(match):
    args = match.group(4)
    def replace_num(m):
        num_str = m.group(0)
        try:
            val = float(num_str)
            if val in radius_map:
                return radius_map[val]
        except:
            pass
        return num_str
    new_args = re.sub(r'\b\d+(\.\d+)?\b', replace_num, args)
    return match.group(1) + '(' + new_args + ')'

# Patterns to match EdgeInsets.xxxx(...)
edge_pattern = re.compile(r'(EdgeInsets\.(all|symmetric|only|fromLTRB))\s*\(([^)]+)\)')
# Patterns to match Radius.circular(...) and BorderRadius.xxxx(...)
rad_pattern = re.compile(r'((BorderRadius|Radius)\.(circular|all|only))\s*\(([^)]+)\)')

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            new_content = edge_pattern.sub(replace_padding, content)
            new_content = rad_pattern.sub(replace_radius, new_content)

            if new_content != content:
                # Add import if missing
                if 'constants/constants.dart' not in new_content:
                    lines = new_content.split('\n')
                    last_import_idx = -1
                    for i, line in enumerate(lines):
                        if line.startswith('import '):
                            last_import_idx = i
                    if last_import_idx != -1:
                        lines.insert(last_import_idx + 1, import_str)
                    else:
                        lines.insert(0, import_str)
                    new_content = '\n'.join(lines)

                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
