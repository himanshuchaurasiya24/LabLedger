import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

Widget buildErrorState({required BuildContext context, required Object error, required ThemeData theme, required VoidCallback onTap, required String errorHeading, required String errorTitle, required String buttonLabel, required Widget icon}) {
    return Center(
      child: TintedContainer(
        height: 400,
        width: 400,
        baseColor: theme.colorScheme.error,
        intensity: 0.08,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              color: Theme.of(context).colorScheme.error,
              size: 94,
            ),
            SizedBox(height: defaultPadding),
            Text(
              errorHeading,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            Spacer(),
            CustomElevatedButton(
              width: double.infinity,
              onPressed: onTap,
              label: buttonLabel,
              backgroundColor: theme.colorScheme.error,
              icon: icon,
            ),
          ],
        ),
      ),
    );
  }
