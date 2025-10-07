import 'package:flutter/material.dart';
import 'package:labledger/screens/ui_components/reusable_ui_components.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateRequiredScreen extends StatelessWidget {
  final String requiredVersion;
  const UpdateRequiredScreen({super.key, required this.requiredVersion});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

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
              'A new version of the app is available. Please update to\nversion v$requiredVersion to continue.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ReusableButton(
              text: 'Click here to download',
              onPressed: () {
                _launchURL(
                  "https://github.com/himanshuchaurasiya24/LabLedger/releases/",
                );
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
