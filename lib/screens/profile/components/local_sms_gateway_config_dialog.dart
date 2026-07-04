import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/providers/local_sms_gateway_provider.dart';
import 'package:labledger/screens/ui_components/blurred_dialog.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';

class LocalSmsGatewayConfigDialog extends ConsumerStatefulWidget {
  const LocalSmsGatewayConfigDialog({super.key});

  @override
  ConsumerState<LocalSmsGatewayConfigDialog> createState() =>
      _LocalSmsGatewayConfigDialogState();
}

class _LocalSmsGatewayConfigDialogState
    extends ConsumerState<LocalSmsGatewayConfigDialog> {
  late TextEditingController _urlController;
  late TextEditingController _phoneKeyController;
  late TextEditingController _messageKeyController;

  @override
  void initState() {
    super.initState();
    final config = ref.read(localSmsGatewayConfigProvider);
    _urlController = TextEditingController(text: config.url);
    _phoneKeyController = TextEditingController(text: config.phoneKey);
    _messageKeyController = TextEditingController(text: config.messageKey);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _phoneKeyController.dispose();
    _messageKeyController.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(localSmsGatewayConfigProvider.notifier).updateConfig(
          url: _urlController.text.trim(),
          phoneKey: _phoneKeyController.text.trim(),
          messageKey: _messageKeyController.text.trim(),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return PremiumDialog(
      width: 500,
      accentColor: accentColor,
      headerIcon: Icons.settings_rounded,
      title: 'Local SMS Gateway Settings',
      subtitle: 'Configure connection details for your local SMS gateway app',
      expandContent: false,
      content: Padding(
        padding: const EdgeInsets.all(dialogPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter the full URL where the gateway app receives POST requests.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            CustomTextField(
              controller: _urlController,
              label: 'Gateway URL',
              tintColor: accentColor,
              prefixIcon: Icon(Icons.link_rounded, color: accentColor),
              disableCapitalization: true,
            ),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parameter name for phone (e.g. phone).',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: _phoneKeyController,
                        label: 'Phone Field Name',
                        tintColor: accentColor,
                        prefixIcon: Icon(Icons.phone_rounded, color: accentColor),
                        disableCapitalization: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parameter name for SMS text (e.g. message).',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: _messageKeyController,
                        label: 'Message Field Name',
                        tintColor: accentColor,
                        prefixIcon: Icon(Icons.message_rounded, color: accentColor),
                        disableCapitalization: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            CustomElevatedButton(
              onPressed: _save,
              label: 'Save Configuration',
              backgroundColor: accentColor,
              icon: const Icon(Icons.check_circle_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
