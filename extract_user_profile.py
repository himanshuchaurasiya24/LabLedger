import os

source = r"c:\Users\himan\Documents\Repositories\LabLedger\lib\screens\profile\user_profile_widget.dart"
dest = r"c:\Users\himan\Documents\Repositories\LabLedger\lib\screens\profile\components\user_profile_dropdown_menu.dart"

with open(source, "r") as f:
    lines = f.readlines()

# find where _CustomDropdownMenu starts
idx = 0
for i, line in enumerate(lines):
    if "class _CustomDropdownMenu extends ConsumerWidget" in line:
        idx = i
        break

extracted = lines[idx:]
kept = lines[:idx]

# add imports to extracted
imports = []
for line in kept:
    if line.startswith("import "):
        imports.append(line)

imports_str = "".join(imports)
extracted_str = "".join(extracted)

# make it public
extracted_str = extracted_str.replace("class _CustomDropdownMenu", "class CustomDropdownMenu")
kept_str = "".join(kept).replace("_CustomDropdownMenu", "CustomDropdownMenu")
kept_str = kept_str.replace("import 'package:flutter_lucide/flutter_lucide.dart';", "import 'package:flutter_lucide/flutter_lucide.dart';\nimport 'package:labledger/screens/profile/components/user_profile_dropdown_menu.dart';")

with open(dest, "w") as f:
    f.write(imports_str + "\n" + extracted_str)

with open(source, "w") as f:
    f.write(kept_str)
