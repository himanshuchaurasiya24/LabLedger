import 'dart:convert';

import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/constants/urls.dart';

Future<void> sendLocalSmsGatewayMessage({
  required dynamic ref,
  required String phoneNumber,
  required String message,
}) {
  return AuthHttpClient.post(
    ref,
    AppUrls.localSmsGatewaySendSmsUrl,
    body: jsonEncode({'phone': phoneNumber, 'message': message}),
    timeout: const Duration(seconds: 15),
  ).then((_) {});
}
