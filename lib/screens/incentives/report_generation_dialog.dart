import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';
import 'package:labledger/screens/ui_components/custom_outlined_button.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:labledger/screens/ui_components/searchable_dropdown_field.dart';

class ReportGenerationDialog extends StatefulWidget {
  const ReportGenerationDialog({super.key});

  @override
  State<ReportGenerationDialog> createState() => _ReportGenerationDialogState();
}

class _ReportGenerationDialogState extends State<ReportGenerationDialog> {
  late final TextEditingController _layoutController;
  final List<String> _pdfLayouts = const [
    'LabLedger',
    'Dark Blue',
    'Light Blue',
  ];
  int _selectedLayoutIndex = 0;

  final Map<String, bool> _selectedFields = {
    'dateOfBill': true,
    'patientName': true,
    'ageAndSex': true,
    'diagnosisTypeOutput': true,
    'franchiseNameOutput': true,
    'totalAmount': true,
    'paidAmount': true,
    'discByDoctor': true,
    'discByCenter': true,
    'incentivePercentage': true,
    'incentiveAmount': true,
    'billNumber': false,
    'billStatus': false,
  };

  final Map<String, String> _fieldLabels = {
    'dateOfBill': 'Date of Bill',
    'patientName': 'Patient Name',
    'ageAndSex': 'Age/Sex',
    'diagnosisTypeOutput': 'Diagnosis',
    'franchiseNameOutput': 'Franchise Lab',
    'totalAmount': 'Total Amount',
    'paidAmount': 'Paid Amount',
    'discByDoctor': "Doctor's Discount",
    'discByCenter': "Center's Discount",
    'incentivePercentage': 'Incentive %',
    'incentiveAmount': 'Incentive Amount',
    'billNumber': 'Bill Number',
    'billStatus': 'Payment Status',
  };

  final Map<String, IconData> _fieldIcons = {
    'dateOfBill': Icons.calendar_today,
    'patientName': Icons.person,
    'ageAndSex': Icons.info_outline,
    'billStatus': Icons.payment,
    'diagnosisTypeOutput': Icons.medical_services,
    'franchiseNameOutput': Icons.business,
    'totalAmount': Icons.currency_rupee,
    'paidAmount': Icons.check_circle_outline,
    'discByDoctor': Icons.local_offer,
    'discByCenter': Icons.discount,
    'incentivePercentage': Icons.percent,
    'incentiveAmount': Icons.account_balance_wallet,
    'billNumber': Icons.receipt_long,
  };

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the default layout text
    _layoutController = TextEditingController(
      text: _pdfLayouts[_selectedLayoutIndex],
    );
  }

  @override
  void dispose() {
    _layoutController.dispose(); // Dispose the controller
    super.dispose();
  }

  void _onGeneratePressed() {
    if (_selectedFields.values.any((isSelected) => isSelected)) {
      Navigator.of(context).pop({
        'generate': true,
        'selectedFields': _selectedFields,
        'pdf_layout_index': _selectedLayoutIndex,
      });
    }
  }

  int get _selectedCount => _selectedFields.values.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        height: 850,
        padding: EdgeInsets.all(defaultPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withAlpha(51), // 0.2 alpha
                        theme.colorScheme.primary.withAlpha(26), // 0.1 alpha
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withAlpha(
                        77,
                      ), // 0.3 alpha
                    ),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate PDF Report',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Select fields and layout to include in your report',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(
                            230,
                          ), // 0.9 alpha
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      Navigator.of(context).pop({'generate': false}),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(height: defaultHeight / 2),
            Text(
              'Select PDF Layout',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: defaultHeight / 2),
            SearchableDropdownField<String>(
              label: 'PDF Layout',
              controller: _layoutController,
              items: _pdfLayouts,
              color: theme.colorScheme.primary,
              valueMapper: (layout) => layout,
              onSelected: (selectedLayout) {
                setState(() {
                  _layoutController.text = selectedLayout;
                  _selectedLayoutIndex = _pdfLayouts.indexOf(selectedLayout);
                  debugPrint("selected layoutindex is: $_selectedLayoutIndex");
                });
              },
            ),
            SizedBox(height: defaultHeight / 2),

            Row(
              children: [
                Text(
                  'Select Fields',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withAlpha(
                      38,
                    ), // 0.15 alpha
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$_selectedCount/${_selectedFields.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Quick Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(
                      () => _selectedFields.updateAll((key, value) => true),
                    ),
                    icon: Icon(
                      Icons.done_all,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    label: Text(
                      'Select All',
                      style: TextStyle(color: theme.colorScheme.secondary),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: defaultPadding * 1.5,
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.secondary.withAlpha(
                          77,
                        ), // 0.3 alpha
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(
                      () => _selectedFields.updateAll((key, value) => false),
                    ),
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear All'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: defaultPadding * 1.5,
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.error.withAlpha(
                          77,
                        ), // 0.3 alpha
                      ),
                      foregroundColor: theme.colorScheme.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: defaultHeight / 2),

            // Fields List
            Expanded(
              child: TintedContainer(
                baseColor: theme.colorScheme.surfaceContainerHighest,
                intensity: 0.5,
                radius: 12,
                elevationLevel: 0,
                disablePadding: true,
                useGradient: false,
                child: ListView.separated(
                  itemCount: _selectedFields.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: defaultHeight / 2),
                  itemBuilder: (context, index) {
                    final key = _selectedFields.keys.elementAt(index);
                    final isSelected = _selectedFields[key] ?? false;

                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () =>
                          setState(() => _selectedFields[key] = !isSelected),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withAlpha(
                                  26,
                                ) // 0.1 alpha
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary.withAlpha(
                                    77,
                                  ) // 0.3 alpha
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary.withAlpha(
                                        38,
                                      ) // 0.15 alpha
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                _fieldIcons[key] ?? Icons.description,
                                size: 16,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withAlpha(
                                        128,
                                      ), // 0.5 alpha
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _fieldLabels[key] ?? key,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Switch(
                              value: isSelected,
                              onChanged: (value) =>
                                  setState(() => _selectedFields[key] = value),
                              activeThumbColor: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomOutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).pop({'generate': false}),
                  icon: Icon(Icons.close),
                  label: "Cancel",
                ),
                SizedBox(width: defaultWidth),
                CustomElevatedButton(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  onPressed: _selectedCount > 0 ? _onGeneratePressed : null,
                  icon: Icon(Icons.picture_as_pdf_outlined),
                  label: 'Generate PDF',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
