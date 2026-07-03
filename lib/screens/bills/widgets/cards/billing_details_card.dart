import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/bills/widgets/cards/bill_section_card.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/searchable_dropdown_field.dart';

class BillingDetailsCard extends StatelessWidget {
  final Color defaultColor;
  final double? height;
  final TextEditingController dateOfTestController;
  final TextEditingController dateOfBillController;
  final TextEditingController billStatusController;
  final List<String> billStatusList;
  final Function(String) onTestDateSelected;
  final Function(String) onBillDateSelected;
  final Function(String) onStatusSelected;

  const BillingDetailsCard({
    super.key,
    required this.defaultColor,
    this.height,
    required this.dateOfTestController,
    required this.dateOfBillController,
    required this.billStatusController,
    required this.billStatusList,
    required this.onTestDateSelected,
    required this.onBillDateSelected,
    required this.onStatusSelected,
  });

  Widget _buildDateSelector(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required Function(String isoDate) onDateSelected,
    required Color color,
    String? Function(String?)? validator,
  }) {
    return AppInkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        HapticFeedback.selectionClick();
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          final now = DateTime.now();
          final fullDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            now.hour,
            now.minute,
            now.second,
          );
          controller.text = DateFormat('dd-MM-yyyy').format(fullDateTime);
          onDateSelected(fullDateTime.toIso8601String());
        }
      },
      child: AbsorbPointer(
        child: CustomTextField(
          label: label,
          controller: controller,
          readOnly: true,
          validator: validator,
          tintColor: color,
          suffixIcon: Icon(
            Icons.calendar_month_rounded,
            size: 22,
            color: color.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BillSectionCard(
      baseColor: defaultColor,
      height: height ?? 258,
      icon: Icons.receipt_long,
      title: 'Billing Details',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  context,
                  label: 'Date of Test',
                  controller: dateOfTestController,
                  color: defaultColor,
                  onDateSelected: onTestDateSelected,
                  validator: (v) => v!.isEmpty ? 'Test date is required' : null,
                ),
              ),
              SizedBox(width: defaultWidth / 2),
              Expanded(
                child: _buildDateSelector(
                  context,
                  label: 'Date of Bill',
                  controller: dateOfBillController,
                  color: defaultColor,
                  onDateSelected: onBillDateSelected,
                  validator: (v) => v!.isEmpty ? 'Bill date is required' : null,
                ),
              ),
            ],
          ),
          SizedBox(height: defaultHeight),
          SearchableDropdownField<String>(
            label: 'Bill Status',
            controller: billStatusController,
            items: billStatusList,
            color: defaultColor,
            valueMapper: (item) => item,
            onSelected: onStatusSelected,
            validator: (v) => v!.isEmpty ? 'Bill status is required' : null,
          ),
        ],
      ),
    );
  }
}
