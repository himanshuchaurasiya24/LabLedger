import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';

final String _staffsBaseUrl = "$globalBaseUrl/auth/staffs/staff";

class PasswordResetInput {
  final int userId;
  final Map<String, String> data;
  
  PasswordResetInput({required this.userId, required this.data});
}

final resetPasswordProvider =
    FutureProvider.family.autoDispose<bool, PasswordResetInput>((ref, input) async {
  final endpoint = "$_staffsBaseUrl/${input.userId}/reset_password/";

  await AuthHttpClient.post(
    ref,
    endpoint,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(input.data),
  );

  return true;
});