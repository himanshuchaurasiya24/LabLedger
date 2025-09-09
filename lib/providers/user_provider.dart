// user_provider.dart - FIXED VERSION

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/user_model.dart';

// Base endpoint for staff users
final String _staffsBaseUrl = "$globalBaseUrl/auth/staffs/staff";

// --- READ (List) ---
final usersDetailsProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final endpoint = "$_staffsBaseUrl/";
  final response = await AuthHttpClient.get(ref, endpoint);
  
  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((item) => User.fromJson(item)).toList();
  } else {
    throw Exception("Failed to fetch users: ${response.statusCode}");
  }
});

// --- READ (Detail) ---
final singleUserDetailsProvider =
    FutureProvider.family.autoDispose<User, int>((ref, id) async {
  final endpoint = "$_staffsBaseUrl/$id/";
  final response = await AuthHttpClient.get(ref, endpoint);
  
  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to fetch user: ${response.statusCode}");
  }
});

// --- CREATE ---
final createUserProvider =
    FutureProvider.family.autoDispose<User, Map<String, dynamic>>((ref, userData) async {
  final endpoint = "$_staffsBaseUrl/";
  final response = await AuthHttpClient.post(
    ref,
    endpoint,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(userData),
  );
  
  if (response.statusCode == 201) {
    ref.invalidate(usersDetailsProvider);
    return User.fromJson(jsonDecode(response.body));
  } else {
    // Enhanced error handling for user creation
    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map<String, dynamic>) {
        String fieldErrors = '';
        errorData.forEach((key, value) {
          String fieldError = '';
          if (value is List) {
            fieldError = value.join(', ');
          } else {
            fieldError = value.toString();
          }
          fieldErrors += '$key: $fieldError\n';
        });
        throw Exception('Creation failed:\n${fieldErrors.trim()}');
      }
      throw Exception('Creation failed: ${response.body}');
    } catch (e) {
      if (e is Exception && e.toString().contains('Creation failed:')) {
        rethrow;
      }
      throw Exception('Failed to create user: Server returned status ${response.statusCode}');
    }
  }
});

// --- UPDATE (FIXED) ---
final updateUserProvider = FutureProvider.family.autoDispose<User, User>((ref, user) async {
  final endpoint = "$_staffsBaseUrl/${user.id}/";
  
  // Create a map without password field for user details update
  final updateData = {
    'username': user.username,
    'email': user.email,
    'first_name': user.firstName,
    'last_name': user.lastName,
    'phone_number': user.phoneNumber,
    'address': user.address,
    'is_admin': user.isAdmin,
  };
  
  final response = await AuthHttpClient.put(
    ref,
    endpoint,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(updateData),
  );
  
  if (response.statusCode == 200) {
    ref.invalidate(singleUserDetailsProvider(user.id));
    ref.invalidate(usersDetailsProvider);
    return User.fromJson(jsonDecode(response.body));
  } else {
    // Enhanced error handling for user update
    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map<String, dynamic>) {
        String fieldErrors = '';
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
            case 'username':
              friendlyFieldName = 'Username';
              break;
            case 'email':
              friendlyFieldName = 'Email';
              break;
            case 'first_name':
              friendlyFieldName = 'First Name';
              break;
            case 'last_name':
              friendlyFieldName = 'Last Name';
              break;
            case 'phone_number':
              friendlyFieldName = 'Phone Number';
              break;
            case 'address':
              friendlyFieldName = 'Address';
              break;
            case 'non_field_errors':
              friendlyFieldName = '';
              break;
          }
          
          if (friendlyFieldName.isNotEmpty) {
            fieldErrors += '$friendlyFieldName: $fieldError\n';
          } else {
            fieldErrors += '$fieldError\n';
          }
        });
        throw Exception(fieldErrors.trim());
      }
      throw Exception('Update failed: ${response.body}');
    } catch (e) {
      if (e is Exception && !e.toString().contains('FormatException')) {
        rethrow;
      }
      throw Exception('Update failed: Server returned status ${response.statusCode}. ${response.body}');
    }
  }
});

// --- DELETE ---
final deleteUserProvider = FutureProvider.family.autoDispose<bool, int>((ref, id) async {
  final endpoint = "$_staffsBaseUrl/$id/";
  final response = await AuthHttpClient.delete(ref, endpoint);
  
  if (response.statusCode == 204) {
    ref.invalidate(usersDetailsProvider);
    ref.invalidate(singleUserDetailsProvider(id));
    return true;
  } else {
    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map<String, dynamic>) {
        String errorMessage = errorData['error'] ?? errorData['message'] ?? 'Unknown error';
        throw Exception('Delete failed: $errorMessage');
      }
      throw Exception('Delete failed: ${response.body}');
    } catch (e) {
      if (e is Exception && e.toString().contains('Delete failed:')) {
        rethrow;
      }
      throw Exception("Failed to delete user: ${response.statusCode}");
    }
  }
});
