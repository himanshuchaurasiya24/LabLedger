import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/providers/patient_report_provider.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';
import 'package:labledger/screens/ui_components/status_badge.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:labledger/screens/bills/widgets/update_report_dialog.dart';

class BillHeaderCard extends ConsumerWidget {
  final Bill? bill;
  final int? billId;
  final Color color;
  final bool isEditMode;
  final bool isDownloadingReport;
  final bool isSendingMessage;
  final bool isSubmitting;
  final VoidCallback onDownloadReport;
  final VoidCallback onDeleteReport;
  final VoidCallback onSendMessage;
  final VoidCallback onSaveBill;
  final VoidCallback onDeleteBill;

  const BillHeaderCard({
    super.key,
    this.bill,
    this.billId,
    required this.color,
    required this.isEditMode,
    required this.isDownloadingReport,
    required this.isSendingMessage,
    required this.isSubmitting,
    required this.onDownloadReport,
    required this.onDeleteReport,
    required this.onSendMessage,
    required this.onSaveBill,
    required this.onDeleteBill,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final lightThemeColor = Color.lerp(
      color,
      isDark ? Colors.black : Colors.white,
      isDark ? 0.3 : 0.2,
    )!;

    return TintedContainer(
      baseColor: color,
      height: 160,
      radius: defaultRadius,
      elevationLevel: 1,
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, lightThemeColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                isEditMode ? Icons.edit_note : Icons.add_circle_outline,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          SizedBox(width: defaultWidth),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isEditMode ? 'Edit Bill' : 'Create New Bill',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: defaultHeight / 2),
                Row(
                  children: [
                    Text(
                      isEditMode
                          ? 'Bill #${bill?.billNumber ?? 'N/A'}'
                          : 'Fill in the details to create a new bill',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? Colors.white70
                            : colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    if (isEditMode)
                      IconButton(
                        tooltip: "Copy bill number",
                        icon: Icon(
                          Icons.copy,
                          color: colorScheme.outline,
                          size: 14,
                        ),
                        onPressed: () {
                          if (bill?.billNumber != null) {
                            Clipboard.setData(
                              ClipboardData(text: bill!.billNumber!),
                            );
                            showSuccessSnackBar(
                              context,
                              "Bill number ${bill!.billNumber} copied to clipboard.",
                            );
                          }
                        },
                      ),
                  ],
                ),
                SizedBox(height: defaultHeight / 2),
                Row(
                  children: [
                    StatusBadge(
                      text: isEditMode ? 'Edit Mode' : 'New Bill',
                      color: color,
                    ),
                    if (isEditMode) ...[
                      SizedBox(width: defaultWidth / 2),
                      Consumer(
                        builder: (context, ref, child) {
                          final reportAsyncValue = bill == null
                              ? null
                              : ref.watch(getReportForBillProvider(bill!.id!));
                          final hasReport =
                              reportAsyncValue?.hasValue == true &&
                              reportAsyncValue?.value != null;

                          return Row(
                            children: [
                              AppInkWell(
                                borderRadius: BorderRadius.circular(defaultRadius),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return UpdateReportDialog(
                                        color: color,
                                        billId: billId!,
                                      );
                                    },
                                  );
                                },
                                child: StatusBadge(
                                  text: hasReport
                                      ? 'Update Report'
                                      : 'Upload Report',
                                  color: color,
                                ),
                              ),
                              if (hasReport) ...[
                                SizedBox(width: defaultWidth / 2),
                                AppInkWell(
                                  borderRadius: BorderRadius.circular(defaultRadius),
                                  onTap: isDownloadingReport
                                      ? null
                                      : onDownloadReport,
                                  child: StatusBadge(
                                    text: isDownloadingReport
                                        ? 'Downloading...'
                                        : 'Download Report',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                                SizedBox(width: defaultWidth / 2),
                                AppInkWell(
                                  borderRadius: BorderRadius.circular(defaultRadius),
                                  onTap: onDeleteReport,
                                  child: StatusBadge(
                                    text: 'Delete Report',
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      SizedBox(width: defaultWidth / 2),
                      if (bill?.isMessageSent == true) ...[
                        StatusBadge(
                          text: 'Message Sent',
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        SizedBox(width: defaultWidth / 2),
                        AppInkWell(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          onTap: isSendingMessage || bill == null
                              ? null
                              : onSendMessage,
                          child: StatusBadge(
                            text: isSendingMessage
                                ? 'Sending...'
                                : 'Resend Message',
                            color: isSendingMessage ? Colors.orange : color,
                          ),
                        ),
                      ] else ...[
                        AppInkWell(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          onTap: isSendingMessage || bill == null
                              ? null
                              : onSendMessage,
                          child: StatusBadge(
                            text: isSendingMessage
                                ? 'Sending...'
                                : 'Send Message',
                            color: isSendingMessage ? Colors.orange : color,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomElevatedButton(
                onPressed: isSubmitting ? null : onSaveBill,
                label: isSubmitting
                    ? 'Saving...'
                    : (isEditMode ? 'Update Bill' : 'Create Bill'),
                backgroundColor: color,
                icon: isSubmitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(isEditMode ? Icons.save : Icons.add, size: 16),
              ),
              if (isEditMode) ...[
                SizedBox(height: defaultHeight / 2),
                CustomElevatedButton(
                  onPressed: onDeleteBill,
                  label: 'Delete Bill',
                  foregroundColor: colorScheme.error,
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  outlined: true,
                  borderColor: Theme.of(context).colorScheme.error,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
