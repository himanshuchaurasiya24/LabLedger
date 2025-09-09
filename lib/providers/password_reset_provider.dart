import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
// ... other existing imports

// This assumes '_staffsBaseUrl' is defined in this file from our previous work:
final String _staffsBaseUrl = "$globalBaseUrl/auth/staffs/staff";

// /// Helper class to pass the required data to the resetPasswordProvider
// --- PASSWORD RESET (ENHANCED) ---
class PasswordResetInput {
  final int userId;
  final Map<String, String> data;
  
  PasswordResetInput({required this.userId, required this.data});
}
// class PasswordResetInput {
//   final int userId;
//   final Map<String, String> data;

//   PasswordResetInput({required this.userId, required this.data});

//   // Example data for Admin:
//   // { "password": "new_strong_password123" }

//   // Example data for User self-change:
//   // { "old_password": "my_old_pass", "new_password": "my_new_pass" }
// }

// --- PASSWORD RESET PROVIDER ---
/// Handles password reset for both admin (forcing) and user (self-change).
/// This is a mutation provider. You call it when needed; you don't 'watch' it.
/// It returns true on success or throws an Exception with the server error message.

// Enhanced error handling for resetPasswordProvider (improved version)

final resetPasswordProvider = FutureProvider.family
    .autoDispose<bool, PasswordResetInput>((ref, input) async {
  final endpoint = "$_staffsBaseUrl/${input.userId}/reset_password/";
  
  final response = await AuthHttpClient.post(
    ref,
    endpoint,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(input.data),
  );
  
  if (response.statusCode == 200) {
    return true;
  } else {
    // Enhanced error handling for password reset
    try {
      final errorData = jsonDecode(response.body);
      
      if (errorData is Map<String, dynamic>) {
        String errorMessage = '';
        
        errorData.forEach((key, value) {
          String fieldError = '';
          if (value is List) {
            fieldError = value.join(', ');
          } else {
            fieldError = value.toString();
          }
          
          // Make field names more user-friendly
          String friendlyFieldName = key;
          switch (key.toLowerCase()) {
            case 'old_password':
              friendlyFieldName = 'Current Password';
              break;
            case 'new_password':
              friendlyFieldName = 'New Password';
              break;
            case 'password':
              friendlyFieldName = 'Password';
              break;
            case 'non_field_errors':
              friendlyFieldName = '';
              break;
            case 'error':
              friendlyFieldName = '';
              break;
          }
          
          if (friendlyFieldName.isNotEmpty) {
            errorMessage += '$friendlyFieldName: $fieldError\n';
          } else {
            errorMessage += '$fieldError\n';
          }
        });
        
        throw Exception(errorMessage.trim());
      }
      
      throw Exception('Password reset failed: $errorData');
    } catch (e) {
      if (e is Exception && !e.toString().contains('FormatException')) {
        rethrow;
      }
      
      String errorBody = response.body.isNotEmpty ? response.body : 'Unknown error';
      throw Exception('Password reset failed (${response.statusCode}): $errorBody');
    }
  }
});
