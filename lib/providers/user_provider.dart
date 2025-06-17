import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/models/user_model.dart';
import 'package:labledger/providers/custom_providers.dart';

class UserNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final Ref ref;
  UserNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchUsers();
  }
  final String usersUrl = "${baseURL}auth/staffs/staff/";
  Future<void> fetchSingleUser({required int id}) async {
    try {
      final token = await ref.read(tokenProvider.future);
      final response = await http.get(
        Uri.parse("$usersUrl$id/?list_format=true"),
        headers: {"Authorisation": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final users = data.map((e) => User.fromJson(e)).toList().cast<User>();
        state = AsyncValue.data(users);
      } else {
        throw Exception(
          "Failed to fetch single user: ${response.statusCode.toString()}",
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> fetchUsers() async {
    try {
      final token = await ref.read(tokenProvider.future);
      final response = await http.get(
        Uri.parse(usersUrl),
        headers: {"Authorisation": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final users = data.map((e) => User.fromJson(e)).toList().cast<User>();
        state = AsyncValue.data(users);
      } else {
        throw Exception(
          "Failed to fetch users: ${response.body}",
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateUser({
    required int userId,
    required Map<String, dynamic> updatedUserData,
  }) async {
    try {
      final token = await ref.read(tokenProvider.future);
      final response = await http.patch(
        Uri.parse("$usersUrl$userId/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(updatedUserData),
      );
      if (response.statusCode == 200) {
        await fetchUsers();
      } else {
        throw Exception("Failed to update this user: ${response.body}");
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteUser({required int userId}) async {
    try {
      final token = await ref.read(tokenProvider.future);
      final response = await http.delete(
        Uri.parse("$usersUrl$userId/"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 204) {
        final currentUsers = state.value ?? [];
        final updatedUsers = currentUsers
            .where((usr) => usr.id != userId)
            .toList();
        state = AsyncValue.data(updatedUsers);
      } else {
        throw Exception("Failed to delele this user: ${response.body}");
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, AsyncValue<List<User>>>((
  ref,
) {
  return UserNotifier(ref);
});
