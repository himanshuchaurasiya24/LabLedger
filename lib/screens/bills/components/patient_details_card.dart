import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/bills/components/bill_section_card.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/searchable_dropdown_field.dart';

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

  @override
  Widget build(BuildContext context) {
    return BillSectionCard(
      baseColor: defaultColor,
      height: height ?? 258,
      icon: Icons.person_outline,
      title: 'Patient Details',
      child: Column(
        children: [
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
    );
  }
}
