import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:labledger/screens/ui_components/blurred_dialog.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';
import 'package:labledger/screens/ui_components/custom_outlined_button.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:labledger/utils/controller_disposer.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class BillExportDialog extends StatefulWidget {
  const BillExportDialog({super.key});

  @override
  State<BillExportDialog> createState() => _BillExportDialogState();
}

class _BillExportDialogState extends State<BillExportDialog>
    with ControllerDisposer {
  // Export format: 0 = PDF, 1 = CSV
  int _selectedFormat = 0;
  
  DateTimeRange? _selectedDateRange;

  final Map<String, bool> _selectedFields = {
    'dateOfBill': true,
    'billNumber': true,
    'patientName': true,
    'ageAndSex': true,
    'patientPhone': false,
    'diagnosisType': true,
    'franchiseName': false,
    'referredByDoctor': true,
    'billStatus': true,
    'totalAmount': true,
    'paidAmount': true,
    'discByCenter': false,
    'discByDoctor': false,
    'incentiveAmount': true,
    'testDoneBy': false,
  };

  final Map<String, String> _fieldLabels = {
    'dateOfBill': 'Date of Bill',
    'billNumber': 'Bill Number',
    'patientName': 'Patient Name',
    'ageAndSex': 'Age / Sex',
    'patientPhone': 'Phone Number',
    'diagnosisType': 'Diagnosis Type',
    'franchiseName': 'Franchise Lab',
    'referredByDoctor': 'Referred By Doctor',
    'billStatus': 'Payment Status',
    'totalAmount': 'Total Amount',
    'paidAmount': 'Paid Amount',
    'discByCenter': "Center Discount",
    'discByDoctor': "Doctor Discount",
    'incentiveAmount': 'Incentive Amount',
    'testDoneBy': 'Test Done By',
  };

  final Map<String, IconData> _fieldIcons = {
    'dateOfBill': Icons.calendar_today,
    'billNumber': Icons.receipt_long,
    'patientName': Icons.person,
    'ageAndSex': Icons.info_outline,
    'patientPhone': Icons.phone,
    'diagnosisType': Icons.medical_services,
    'franchiseName': Icons.business,
    'referredByDoctor': Icons.local_hospital,
    'billStatus': Icons.payment,
    'totalAmount': Icons.currency_rupee,
    'paidAmount': Icons.check_circle_outline,
    'discByCenter': Icons.discount,
    'discByDoctor': Icons.local_offer,
    'incentiveAmount': Icons.account_balance_wallet,
    'testDoneBy': Icons.person_outline,
  };

  void _onExportPressed() {
    if (_selectedFields.values.any((isSelected) => isSelected)) {
      Navigator.of(context).pop({
        'export': true,
        'selectedFields': Map<String, bool>.from(_selectedFields),
        'format': _selectedFormat == 0 ? 'pdf' : 'csv',
        'dateRange': _selectedDateRange,
      });
    }
  }

  int get _selectedCount => _selectedFields.values.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PremiumDialog(
      width: 600,
      height: 850,
      accentColor: theme.colorScheme.primary,
      headerIcon: LucideIcons.download,
      title: 'Export Bills',
      subtitle: 'Choose format and fields to include in your export',
      onClose: () => Navigator.of(context).pop({'export': false}),
      content: Padding(
        padding: const EdgeInsets.only(
          top: smallPadding,
          left: xlargePadding,
          right: xlargePadding,
          bottom: xlargePadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: defaultHeight / 2),

            // ── Format Selection ──
            Text(
              'Export Format',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: defaultHeight / 2),
            Row(
              children: [
                Expanded(
                    child: _buildFormatCard(
                      theme: theme,
                      icon: LucideIcons.file_text,
                      label: 'PDF Document',
                      isSelected: _selectedFormat == 0,
                      onTap: () => setState(() => _selectedFormat = 0),
                    ),
                ),
                SizedBox(width: defaultWidth),
                Expanded(
                    child: _buildFormatCard(
                      theme: theme,
                      icon: LucideIcons.sheet,
                      label: 'CSV Spreadsheet',
                      isSelected: _selectedFormat == 1,
                      onTap: () => setState(() => _selectedFormat = 1),
                    ),
                ),
              ],
            ),
            SizedBox(height: defaultHeight / 2),

            // ── Date Range Filter ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date Range (Optional)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (_selectedDateRange != null)
                  TextButton.icon(
                    onPressed: () => setState(() => _selectedDateRange = null),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            SizedBox(height: defaultHeight / 2),
            Row(
              children: [
                Expanded(
                  child: AppInkWell(
                    borderRadius: BorderRadius.circular(defaultRadius),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDateRange?.start ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: _selectedDateRange?.end ?? DateTime(2100),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: theme.colorScheme,
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDateRange = DateTimeRange(
                            start: picked,
                            end: _selectedDateRange?.end ?? DateTime.now(),
                          );
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(smallPadding),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(defaultRadius),
                        border: Border.all(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Start Date",
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 16,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              SizedBox(width: smallPadding),
                              Text(
                                _selectedDateRange != null 
                                  ? DateFormat.yMMMd().format(_selectedDateRange!.start) 
                                  : "Select Date",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: defaultWidth),
                Expanded(
                  child: AppInkWell(
                    borderRadius: BorderRadius.circular(defaultRadius),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDateRange?.end ?? DateTime.now(),
                        firstDate: _selectedDateRange?.start ?? DateTime(2020),
                        lastDate: DateTime(2100),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: theme.colorScheme,
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDateRange = DateTimeRange(
                            start: _selectedDateRange?.start ?? DateTime.now(),
                            end: picked,
                          );
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(smallPadding),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(defaultRadius),
                        border: Border.all(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "End Date",
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 16,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              SizedBox(width: smallPadding),
                              Text(
                                _selectedDateRange != null 
                                  ? DateFormat.yMMMd().format(_selectedDateRange!.end) 
                                  : "Select Date",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: defaultHeight),

            // ── Field Selection Header ──
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
                    horizontal: smallPadding,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withAlpha(38),
                    borderRadius: BorderRadius.circular(dialogRadius),
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

            // ── Quick Action Buttons ──
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
                        color: theme.colorScheme.secondary.withAlpha(77),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(smallRadius),
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
                        color: theme.colorScheme.error.withAlpha(77),
                      ),
                      foregroundColor: theme.colorScheme.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(smallRadius),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: defaultHeight / 2),

            // ── Fields List ──
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

                    return AppInkWell(
                      borderRadius: BorderRadius.circular(smallRadius),
                      onTap: () =>
                          setState(() => _selectedFields[key] = !isSelected),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding,
                          vertical: formPadding,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withAlpha(26)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(smallRadius),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary.withAlpha(77)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(tinyPadding),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary.withAlpha(38)
                                    : theme
                                        .colorScheme.surfaceContainerHighest,
                                borderRadius:
                                    BorderRadius.circular(minimalBorderRadius),
                              ),
                              child: Icon(
                                _fieldIcons[key] ?? Icons.description,
                                size: 16,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withAlpha(128),
                              ),
                            ),
                            const SizedBox(width: defaultPadding),
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
            const SizedBox(height: largePadding),

            // ── Action Buttons ──
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomOutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).pop({'export': false}),
                  icon: Icon(Icons.close),
                  label: "Cancel",
                ),
                SizedBox(width: defaultWidth),
                CustomElevatedButton(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  onPressed: _selectedCount > 0 ? _onExportPressed : null,
                  icon: Icon(
                    _selectedFormat == 0
                        ? LucideIcons.file_text
                        : LucideIcons.sheet,
                  ),
                  label: _selectedFormat == 0
                      ? 'Export as PDF'
                      : 'Export as CSV',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatCard({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AppInkWell(
      borderRadius: BorderRadius.circular(smallRadius),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: defaultPadding, vertical: smallPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withAlpha(26)
              : theme.colorScheme.surfaceContainerHighest.withAlpha(128),
          borderRadius: BorderRadius.circular(smallRadius),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withAlpha(51),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withAlpha(128),
              size: 20,
            ),
            SizedBox(width: smallPadding),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
