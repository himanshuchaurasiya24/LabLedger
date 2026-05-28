import 'package:flutter/material.dart';
import 'package:labledger/screens/ui_components/blurred_dialog.dart';
import 'package:labledger/constants/constants.dart';

/// A reusable, stylized error dialog with a scrollable message.
class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    required this.title,
    required this.errorMessage,
    this.infoMessage,
    this.height,
    this.width,
  });

  final String title;
  final String errorMessage;
  final String? infoMessage;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.error;

    return PremiumDialog(
      width: width ?? 620,
      height: height,
      accentColor: accentColor,
      headerIcon: Icons.error_outline,
      title: title,
      subtitle: 'Please review the details below.',
      expandContent: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(defaultPadding * 1.5),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(defaultPadding),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer.withValues(
                            alpha: 0.28,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          errorMessage.replaceAll('Exception: ', ''),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (infoMessage != null &&
                          infoMessage!.trim().isNotEmpty) ...[
                        SizedBox(height: defaultHeight * 0.75),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(defaultPadding),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.7,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          child: Text(
                            infoMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
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
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(150, 46),
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text(
                        'Got it',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
