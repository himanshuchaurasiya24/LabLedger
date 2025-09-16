import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/user_model.dart';

// --- Base Endpoint ---
final String _staffsBaseUrl = "$globalBaseUrl/auth/staffs/staff";

// --- Type Definitions for Provider Families ---
typedef UserLockStatusInput = ({int userId, bool isLocked});

// --- Data Fetching Providers ---

/// Fetches the list of all staff users.
final usersDetailsProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final response = await AuthHttpClient.get(ref, "$_staffsBaseUrl/");
  final List<dynamic> jsonList = jsonDecode(response.body);
  return jsonList.map((item) => User.fromJson(item)).toList();
});

/// Fetches a single user's details by their ID.
final singleUserDetailsProvider =
    FutureProvider.family.autoDispose<User, int>((ref, id) async {
  final response = await AuthHttpClient.get(ref, "$_staffsBaseUrl/$id/");
  return User.fromJson(jsonDecode(response.body));
});

// --- Action Providers ---

/// Creates a new staff user.
final createUserProvider =
    FutureProvider.family.autoDispose<User, Map<String, dynamic>>((ref, userData) async {
  final response = await AuthHttpClient.post(
    ref,
    "$_staffsBaseUrl/",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(userData),
  );
  ref.invalidate(usersDetailsProvider);
  return User.fromJson(jsonDecode(response.body));
});

/// Updates a user's profile details.
final updateUserProvider =
    FutureProvider.family.autoDispose<User, User>((ref, user) async {
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
    "$_staffsBaseUrl/${user.id}/",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(updateData),
  );
  _invalidateUserCache(ref, user.id);
  return User.fromJson(jsonDecode(response.body));
});

/// Toggles a user's `is_locked` status.
final toggleUserLockStatusProvider =
    FutureProvider.family.autoDispose<User, UserLockStatusInput>((ref, params) async {
  // Using PATCH for partial updates is more efficient and semantically correct.
  final response = await AuthHttpClient.put( // Changed to PATCH
    ref,
    "$_staffsBaseUrl/${params.userId}/",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({'is_locked': params.isLocked}),
  );
  _invalidateUserCache(ref, params.userId);
  return User.fromJson(jsonDecode(response.body));
});

/// Deletes a user by their ID.
final deleteUserProvider =
    FutureProvider.family.autoDispose<bool, int>((ref, id) async {
  await AuthHttpClient.delete(ref, "$_staffsBaseUrl/$id/");
  _invalidateUserCache(ref, id);
  return true;
});


// --- Private Helper Functions ---

/// Centralized function to invalidate caches related to user data.
void _invalidateUserCache(Ref ref, int userId) {
  ref.invalidate(usersDetailsProvider);
  ref.invalidate(singleUserDetailsProvider(userId));
}