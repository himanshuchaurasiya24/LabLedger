import 'package:flutter/material.dart';
import 'package:labledger/screens/ui_components/blurred_dialog.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';

Future<bool> showCustomConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  Widget? contentBottomWidget,
  bool isDeleteOption = true,
  bool showWarningIcon = true,
  double borderRadius = 16,
  String cancelLabel = 'Cancel',
  String confirmLabel = 'Delete',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final Color accentColor = isDeleteOption
          ? theme.colorScheme.error
          : theme.colorScheme.primary;
      final IconData confirmIcon = isDeleteOption
          ? Icons.delete_outline
          : Icons.check_circle_outline;

      return PremiumDialog(
        width: 560,
        accentColor: accentColor,
        headerIcon: showWarningIcon
            ? Icons.warning_amber_rounded
            : Icons.info_outline,
        title: title,
        subtitle: '', // No subtitle for confirmation
        expandContent: false,
        onClose: () => Navigator.of(dialogContext).pop(false),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          height: 1.45,
                        ),
                      ),
                    ),
                    if (contentBottomWidget != null) ...[
                      const SizedBox(height: 16),
                      contentBottomWidget,
                    ],
                  ],
                ),
              ),
            ),
          Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDeleteOption
                    ? theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.35,
                      )
                    : theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.25,
                      ),
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: OutlinedButton.styleFrom(
                      fixedSize: const Size(140, 44),
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                    ),
                    icon: const Icon(Icons.close_outlined),
                    label: Text(cancelLabel),
                  ),
                  const SizedBox(width: 10),
                  CustomElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    label: confirmLabel,
                    icon: Icon(confirmIcon),
                    backgroundColor: accentColor,
                    width: 160,
                    height: 44,
                    fontSize: 14,
                    iconSize: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );

  return confirmed ?? false;
}

Future<bool> showDeleteConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  bool showWarningIcon = true,
  double borderRadius = 16,
  String cancelLabel = 'Cancel',
  String confirmLabel = 'Delete',
}) {
  return showCustomConfirmationDialog(
    context: context,
    title: title,
    message: message,
    isDeleteOption: true,
    showWarningIcon: showWarningIcon,
    borderRadius: borderRadius,
    cancelLabel: cancelLabel,
    confirmLabel: confirmLabel,
  );
}
