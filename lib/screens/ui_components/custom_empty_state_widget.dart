import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

Widget buildEmptyState({
  required BuildContext context,
  Color? effectiveColor,
  VoidCallback? onAddPressed,
  required String title,
  required String subtitle,
  IconData? icon,
  String? label,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final resolvedColor = effectiveColor ?? colorScheme.secondary;
  final showButton = onAddPressed != null && label != null && label.isNotEmpty;

  return Center(
    child: TintedContainer(
      height: 400,
      width: 400,
      baseColor: resolvedColor,
      intensity: 0.08,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon ?? Icons.inbox_rounded, size: 94, color: resolvedColor),
          SizedBox(height: defaultPadding),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (showButton) ...[
            const Spacer(),
            CustomElevatedButton(
              width: double.infinity,
              onPressed: onAddPressed,
              label: label,
              backgroundColor: resolvedColor,
              icon: const Icon(Icons.add),
            ),
          ],
        ],
      ),
    ),
  );
}
