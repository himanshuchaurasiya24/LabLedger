import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/bills/components/bill_section_card.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';

class AmountDetailsCard extends StatelessWidget {
  final Color defaultColor;
  final double? height;
  final int totalAmount;
  final TextEditingController paidAmountController;
  final TextEditingController discByDoctorController;
  final TextEditingController discByCenterController;

  const AmountDetailsCard({
    super.key,
    required this.defaultColor,
    this.height,
    required this.totalAmount,
    required this.paidAmountController,
    required this.discByDoctorController,
    required this.discByCenterController,
  });

  @override
  Widget build(BuildContext context) {
    return BillSectionCard(
      baseColor: defaultColor,
      height: height ?? 318,
      icon: Icons.payments_rounded,
      title: 'Amount Details',
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: defaultColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: defaultColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹$totalAmount',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: defaultColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: defaultHeight),
          CustomTextField(
            label: 'Paid Amount',
            controller: paidAmountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            isRequired: true,
            isNumeric: true,
            tintColor: defaultColor,
          ),
          SizedBox(height: defaultHeight),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: "Doctor's Discount",
                  controller: discByDoctorController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  tintColor: defaultColor,
                  isNumeric: true,
                ),
              ),
              SizedBox(width: defaultWidth),
              Expanded(
                child: CustomTextField(
                  label: "Center's Discount",
                  controller: discByCenterController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  tintColor: defaultColor,
                  isNumeric: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
