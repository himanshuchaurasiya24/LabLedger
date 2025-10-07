import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/user_model.dart';

final String staffsBaseUrl = "${globalBaseUrl}auth/staffs/staff";

typedef UserLockStatusInput = ({int userId, bool isLocked});

final usersDetailsProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final response = await AuthHttpClient.get(ref, "$staffsBaseUrl/");
  final List<dynamic> jsonList = jsonDecode(response.body);
  return jsonList.map((item) => User.fromJson(item)).toList();
});

final singleUserDetailsProvider =
    FutureProvider.family.autoDispose<User, int>((ref, id) async {
  final response = await AuthHttpClient.get(ref, "$staffsBaseUrl/$id/");
  return User.fromJson(jsonDecode(response.body));
});


final createUserProvider =
    FutureProvider.family.autoDispose<User, Map<String, dynamic>>((ref, userData) async {
  final response = await AuthHttpClient.post(
    ref,
    "$staffsBaseUrl/",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(userData),
  );
  ref.invalidate(usersDetailsProvider);
  return User.fromJson(jsonDecode(response.body));
});

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
    "$staffsBaseUrl/${user.id}/",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(updateData),
  );
  _invalidateUserCache(ref, user.id);
  return User.fromJson(jsonDecode(response.body));
});

final toggleUserLockStatusProvider =
    FutureProvider.family.autoDispose<User, UserLockStatusInput>((ref, params) async {
  final response = await AuthHttpClient.put( 
    ref,
    "$staffsBaseUrl/${params.userId}/",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({'is_locked': params.isLocked}),
  );
  _invalidateUserCache(ref, params.userId);
  return User.fromJson(jsonDecode(response.body));
});

final deleteUserProvider =
    FutureProvider.family.autoDispose<bool, int>((ref, id) async {
  await AuthHttpClient.delete(ref, "$staffsBaseUrl/$id/");
  _invalidateUserCache(ref, id);
  return true;
});

void _invalidateUserCache(Ref ref, int userId) {
  ref.invalidate(usersDetailsProvider);
  ref.invalidate(singleUserDetailsProvider(userId));
}