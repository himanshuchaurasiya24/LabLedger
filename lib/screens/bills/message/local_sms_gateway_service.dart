import 'dart:convert';

import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/providers/local_sms_gateway_provider.dart';

Future<void> sendLocalSmsGatewayMessage({
  required dynamic ref,
  required String phoneNumber,
  required String message,
}) {
  final config = ref.read(localSmsGatewayConfigProvider);
  return AuthHttpClient.post(
    ref,
    config.url,
    body: jsonEncode({config.phoneKey: phoneNumber, config.messageKey: message}),
    timeout: const Duration(seconds: 15),
  ).then((_) {});
}
