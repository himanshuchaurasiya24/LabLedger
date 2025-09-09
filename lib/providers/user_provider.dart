import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/user_model.dart';

// Base endpoint for staff users
final String _staffsBaseUrl = "$globalBaseUrl/auth/staffs/staff";

// --- READ (List) ---
// Fetches all staff users. Refactored from .family with void to a simple provider.
final usersDetailsProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final endpoint = "$_staffsBaseUrl/"; // Note the trailing slash

  final response = await AuthHttpClient.get(ref, endpoint);

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((item) => User.fromJson(item)).toList();
  } else {
    throw Exception("Failed to fetch users: ${response.statusCode}");
  }
});

// --- READ (Detail) ---
// Fetches a single user by their ID. (Your original code was correct).
final singleUserDetailsProvider =
    FutureProvider.family.autoDispose<User, int>((
  ref,
  id,
) async {
  final endpoint = "$_staffsBaseUrl/$id/";

  final response = await AuthHttpClient.get(ref, endpoint);

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to fetch user: ${response.statusCode}");
  }
});

// --- CREATE ---
// Creates a new user. Takes a Map of the user data.
final createUserProvider =
    FutureProvider.family.autoDispose<User, Map<String, dynamic>>((
  ref,
  userData,
) async {
  final endpoint = "$_staffsBaseUrl/";

  final response = await AuthHttpClient.post(
    ref,
    endpoint,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(userData),
  );

  if (response.statusCode == 201) {
    // 201 Created is the standard success code for POST
    // When a new user is created, the list of all users is now out of date.
    ref.invalidate(usersDetailsProvider);
    // Return the new user created by the server
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to create user: ${response.statusCode}");
  }
});

// --- UPDATE ---
// Updates an existing user. Takes the full User object.
final updateUserProvider = FutureProvider.family.autoDispose<User, User>((
  ref,
  user,
) async {
  // Assume user.id is not null when updating
  final endpoint = "$_staffsBaseUrl/${user.id}/";

  final response = await AuthHttpClient.put(
    ref,
    endpoint,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(user.toJson()),
  );

  if (response.statusCode == 200) {
    // When a user is updated, both the main list and the single user detail are stale.
    // **FIX:** You MUST pass the ID to invalidate a family provider.
    ref.invalidate(singleUserDetailsProvider(user.id));
    ref.invalidate(usersDetailsProvider);
    // Return the updated user data from the server response
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to update user: ${response.statusCode}");
  }
});

// --- DELETE ---
// Deletes a user by their ID. Returns true on success.
final deleteUserProvider = FutureProvider.family.autoDispose<bool, int>((
  ref,
  id,
) async {
  final endpoint = "$_staffsBaseUrl/$id/";

  final response = await AuthHttpClient.delete(ref, endpoint);

  if (response.statusCode == 204) {
    // 204 No Content is the standard success code for DELETE
    // When a user is deleted, invalidate both the list and the single user detail.
    ref.invalidate(usersDetailsProvider);
    ref.invalidate(singleUserDetailsProvider(id));
    return true;
  } else {
    throw Exception("Failed to delete user: ${response.statusCode}");
  }
});