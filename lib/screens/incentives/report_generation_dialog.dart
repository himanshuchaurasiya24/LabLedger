import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class ReportGenerationDialog extends StatefulWidget {
  const ReportGenerationDialog({super.key});

  @override
  State<ReportGenerationDialog> createState() => _ReportGenerationDialogState();
}

class _ReportGenerationDialogState extends State<ReportGenerationDialog> {
  final _titleController = TextEditingController(text: 'Incentive Report');

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
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _onGeneratePressed() {
    if (_selectedFields.values.any((isSelected) => isSelected)) {
      Navigator.of(context).pop({
        'generate': true,
        'selectedFields': _selectedFields,
        'title': _titleController.text,
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
        height: 800,
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
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
                        'Select fields to include in your report',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.9,
                          ),
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

            // Fields Selection Header
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
                    color: theme.colorScheme.secondary.withValues(alpha: 0.15),
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
                        color: theme.colorScheme.secondary.withValues(
                          alpha: 0.3,
                        ),
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
                        color: theme.colorScheme.error.withValues(alpha: 0.3),
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
                  // padding: EdgeInsets.symmetric(
                  //   horizontal: defaultPadding / 2,
                  //   vertical: defaultPadding / 2,
                  // ),
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
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  )
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary.withValues(
                                        alpha: 0.15,
                                      )
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                _fieldIcons[key] ?? Icons.description,
                                size: 16,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.5,
                                      ),
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
                OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).pop({'generate': false}),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: defaultPadding * 2,
                      vertical: defaultPadding * 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Cancel'),
                ),
                SizedBox(width: defaultWidth),
                OutlinedButton(
                  onPressed: _selectedCount > 0 ? _onGeneratePressed : null,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: defaultPadding * 2,
                      vertical: defaultPadding * 1.5,
                    ),
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text('Generate PDF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
