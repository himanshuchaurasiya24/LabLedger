import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class FullScreenErrorWidget extends StatelessWidget {
  final String message;
  final String title;
  final Color themeColor;
  final VoidCallback onRetry;

  const FullScreenErrorWidget({
    super.key,
    required this.message,
    this.title = 'Error Loading Data',
    required this.themeColor,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(xlargePadding),
        child: TintedContainer(
          baseColor: theme.colorScheme.error,
          intensity: isDark ? 0.2 : 0.1,
          elevationLevel: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              SizedBox(height: defaultHeight),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: defaultHeight / 2),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: defaultHeight),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultRadius),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
