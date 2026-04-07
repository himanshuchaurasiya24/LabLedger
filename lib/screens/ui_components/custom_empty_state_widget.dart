
  import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

Widget buildEmptyState({required BuildContext context, Color? effectiveColor, required VoidCallback onAddPressed, required String title, required String subtitle, IconData? icon, required String label}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: TintedContainer(
        height: 400,
        width: 400,
        baseColor: effectiveColor?? colorScheme.secondary,
        intensity: 0.08,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 94,
              color: effectiveColor?? colorScheme.secondary,
            ), // Updated Icon
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
            Spacer(),
            CustomElevatedButton(
              width: double.infinity,
              onPressed: onAddPressed,
              label: label,
              backgroundColor: effectiveColor,
              icon: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }