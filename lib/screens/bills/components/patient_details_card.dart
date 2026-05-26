import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/searchable_dropdown_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class PatientDetailsCard extends StatelessWidget {
  final Color defaultColor;
  final double? height;
  final TextEditingController nameController;
  final TextEditingController sexController;
  final TextEditingController ageController;
  final TextEditingController phoneController;
  final List<String> sexDropDownList;
  final void Function(String) onSexSelected;

  const PatientDetailsCard({
    super.key,
    required this.defaultColor,
    this.height,
    required this.nameController,
    required this.sexController,
    required this.ageController,
    required this.phoneController,
    required this.sexDropDownList,
    required this.onSexSelected,
  });

  Widget _buildCardHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(width: defaultWidth / 2),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return TintedContainer(
      baseColor: defaultColor,
      height: height ?? 258,
      radius: defaultRadius,
      elevationLevel: 1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            _buildCardHeader(
              icon: Icons.person_outline,
              title: 'Patient Details',
              color: defaultColor,
            ),
            SizedBox(height: defaultHeight),
            CustomTextField(
              label: 'Patient Name',
              controller: nameController,
              isRequired: true,
              tintColor: defaultColor,
            ),
            SizedBox(height: defaultHeight),
            Row(
              children: [
                Expanded(
                  child: SearchableDropdownField<String>(
                    label: 'Select Sex',
                    controller: sexController,
                    items: sexDropDownList,
                    color: defaultColor,
                    onSelected: onSexSelected,
                    valueMapper: (item) => item,
                    validator: (v) => v!.isEmpty ? 'Please select sex' : null,
                  ),
                ),
                SizedBox(width: defaultWidth / 2),
                Expanded(
                  child: CustomTextField(
                    label: 'Age',
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    isRequired: true,
                    isNumeric: true,
                    tintColor: defaultColor,
                  ),
                ),
                SizedBox(width: defaultWidth / 2),
                Expanded(
                  child: CustomTextField(
                    label: 'Phone Number',
                    controller: phoneController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    isRequired: true,
                    isNumeric: true,
                    tintColor: defaultColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
