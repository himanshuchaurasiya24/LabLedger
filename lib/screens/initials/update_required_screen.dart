import 'package:flutter/material.dart';
import 'package:labledger/screens/ui_components/reusable_ui_components.dart';

class UpdateRequiredScreen extends StatelessWidget {
  final String requiredVersion;
  const UpdateRequiredScreen({super.key, required this.requiredVersion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.system_update_alt,
              size: 50,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Update Required',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'A new version of the app is available. Please update to\nversion $requiredVersion to continue.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ReusableButton(
              text: 'Contact Support to Update',
              onPressed: () {
              
              },
              width: 253,
              variant: ButtonVariant.elevated,
            ),
          ],
        ),
      ),
    );
  }
}
