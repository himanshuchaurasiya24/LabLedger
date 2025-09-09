import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
// ... other existing imports

// This assumes '_staffsBaseUrl' is defined in this file from our previous work:
final String _staffsBaseUrl = "$globalBaseUrl/auth/staffs/staff";

/// Helper class to pass the required data to the resetPasswordProvider
class PasswordResetInput {
  final int userId;
  final Map<String, String> data;

  PasswordResetInput({required this.userId, required this.data});

  // Example data for Admin:
  // { "password": "new_strong_password123" }

  // Example data for User self-change:
  // { "old_password": "my_old_pass", "new_password": "my_new_pass" }
}

// --- PASSWORD RESET PROVIDER ---
/// Handles password reset for both admin (forcing) and user (self-change).
/// This is a mutation provider. You call it when needed; you don't 'watch' it.
/// It returns true on success or throws an Exception with the server error message.
final resetPasswordProvider = FutureProvider.family
    .autoDispose<bool, PasswordResetInput>((ref, input) async {
      // Constructs the correct endpoint: .../auth/staffs/staff/1/reset_password/
      final endpoint = "$_staffsBaseUrl/${input.userId}/reset_password/";

      final response = await AuthHttpClient.post(
        ref,
        endpoint,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(input.data),
      );

      if (response.statusCode == 200) {
        // Password was successfully reset
        return true;
      } else {
        // Handle validation errors from the server (e.g., "Old password incorrect")
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          // This will parse errors like {"old_password": ["Error message."]}
          // and format them into a single string to show the user.
          String message = errorData.entries
              .map((e) => '${e.key}: ${e.value.toString()}')
              .join(', ');
          throw Exception('Update failed: $message');
        } catch (e) {
          // Fallback for non-JSON errors or unexpected formats
          throw Exception(
            "Failed to reset password. Status: ${response.statusCode}",
          );
        }
      }
    });
