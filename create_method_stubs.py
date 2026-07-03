import os

screens_dir = r"c:\Users\himan\Documents\Repositories\LabLedger\lib\screens"

for item in os.listdir(screens_dir):
    item_path = os.path.join(screens_dir, item)
    if os.path.isdir(item_path):
        methods_dir = os.path.join(item_path, "methods")
        if not os.path.exists(methods_dir):
            os.makedirs(methods_dir)
        
        # Determine the name for the methods file based on folder name
        # e.g., 'bills' -> 'bill_methods.dart', 'categories' -> 'category_methods.dart'
        name = item
        if name.endswith('ies'):
            name = name[:-3] + 'y'
        elif name.endswith('s') and name not in ['ui_components', 'diagnosis_types', 'franchise_labs']:
            name = name[:-1]
            
        file_name = f"{name}_methods.dart"
        file_path = os.path.join(methods_dir, file_name)
        
        if not os.path.exists(file_path):
            with open(file_path, 'w') as f:
                class_name = ''.join(word.capitalize() for word in name.split('_')) + 'Methods'
                f.write(f"import 'package:flutter/material.dart';\n\nclass {class_name} extends ChangeNotifier {{\n  final BuildContext context;\n\n  {class_name}(this.context);\n\n  // TODO: Move {name} state and methods here\n}}\n")
            print(f"Created {file_path}")
