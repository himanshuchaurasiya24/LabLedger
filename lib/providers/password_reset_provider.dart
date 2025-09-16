import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
// ... other existing imports

final String _staffsBaseUrl = "$globalBaseUrl/auth/staffs/staff";

/// Using a Dart 3 record for a more concise data structure.
// typedef PasswordResetInput = ({int userId, Map<String, String> data});
class PasswordResetInput {
  final int userId;
  final Map<String, String> data;
  
  PasswordResetInput({required this.userId, required this.data});
}

/// Resets a user's password.
/// All complex error handling is now managed by AuthHttpClient.
final resetPasswordProvider =
    FutureProvider.family.autoDispose<bool, PasswordResetInput>((ref, input) async {
  final endpoint = "$_staffsBaseUrl/${input.userId}/reset_password/";

  await AuthHttpClient.post(
    ref,
    endpoint,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(input.data),
  );

  // If the request succeeds, we simply return true.
  // If it fails, AuthHttpClient throws a perfectly formatted ValidationException.
  return true;
});