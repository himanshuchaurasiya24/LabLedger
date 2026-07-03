import os
import glob
import shutil

lib_dir = r'c:\Users\himan\Documents\Repositories\LabLedger\lib'
ui_components_dir = os.path.join(lib_dir, 'screens', 'ui_components')
screens_dir = os.path.join(lib_dir, 'screens')

# Map component file name -> target module
moves = {
    'amount_details_card.dart': 'bills',
    'billing_details_card.dart': 'bills',
    'bill_header_card.dart': 'bills',
    'diagnosis_details_card.dart': 'bills',
    'full_screen_error_widget.dart': 'bills',
    'patient_details_card.dart': 'bills',
    'section_header.dart': 'bills',
    'update_report_dialog.dart': 'bills',
    'card_header.dart': 'bills',
    'error_field.dart': 'bills',
    'loading_field.dart': 'bills',
    
    'doctor_details_form_card.dart': 'doctors',
    'doctor_incentives_form_card.dart': 'doctors',
    
    'center_subscription_info_card.dart': 'home',
    'custom_filter_chips.dart': 'home',
    'about_app_dialog.dart': 'home',
    
    'animated_progress_indicator.dart': 'incentives',
    'incentive_ui_components.dart': 'incentives',
    
    'subscription_ui_cards.dart': 'initials',
}

# 1. Create target directories and move files
for file_name, module in moves.items():
    source = os.path.join(ui_components_dir, file_name)
    target_dir = os.path.join(screens_dir, module, 'widgets')
    
    if os.path.exists(source):
        if not os.path.exists(target_dir):
            os.makedirs(target_dir)
        
        target = os.path.join(target_dir, file_name)
        shutil.move(source, target)
        print(f"Moved {file_name} to {module}/widgets")
    else:
        print(f"Warning: {file_name} not found in ui_components")

# 2. Update imports in all dart files
dart_files = glob.glob(os.path.join(lib_dir, '**', '*.dart'), recursive=True)

old_import_base = "package:labledger/screens/ui_components/"

for dart_file in dart_files:
    try:
        with open(dart_file, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        continue
        
    modified = False
    new_content = content
    
    for file_name, module in moves.items():
        old_import = old_import_base + file_name
        new_import = f"package:labledger/screens/{module}/widgets/{file_name}"
        
        if old_import in new_content:
            new_content = new_content.replace(old_import, new_import)
            modified = True
            
    if modified:
        with open(dart_file, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated imports in {os.path.relpath(dart_file, lib_dir)}")

print("Done!")
