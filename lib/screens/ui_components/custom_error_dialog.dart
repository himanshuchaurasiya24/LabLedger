import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart'; // For defaultPadding, etc.
import 'package:labledger/screens/ui_components/tinted_container.dart'; // For TintedContainer

/// A reusable, stylized error dialog with a scrollable message.
class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    required this.title,
    required this.errorMessage,
    this.height,
    this.width,
  });

  final String title;
  final String errorMessage;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      child: TintedContainer(
        baseColor: theme.colorScheme.error,
        height: height,
        width: width ?? 620,
        intensity: 0.05,
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 32,
              ),
            ),
            SizedBox(height: defaultHeight),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Spacer(),
            SizedBox(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity, // Ensures container takes full width
                  padding: EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.2),
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
              ),
            ),
            SizedBox(height: defaultHeight),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
