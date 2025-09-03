import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/user_model.dart';

final usersDetailsProvider = FutureProvider.family
    .autoDispose<List<User>, void>((ref, _) async {
      final endpoint = "$globalBaseUrl/auth/staffs/staff/";

      final response = await AuthHttpClient.get(ref, endpoint);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((item) => User.fromJson(item)).toList();
      } else {
        throw Exception("Failed to fetch users: ${response.statusCode}");
      }
    });

final userDetailsProvider = FutureProvider.family.autoDispose<User, int>((
  ref,
  id,
) async {
  final endpoint = "$globalBaseUrl/auth/staffs/staff/$id/";

  final response = await AuthHttpClient.get(ref, endpoint);

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to fetch user: ${response.statusCode}");
  }
});

final updateUserProvider = FutureProvider.family.autoDispose<bool, User>((
  ref,
  user,
) async {
  final endpoint = "$globalBaseUrl/auth/staffs/staff/${user.id}/";

  final response = await AuthHttpClient.put(
    ref,
    endpoint,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(user.toJson()),
  );

  if (response.statusCode == 200 || response.statusCode == 204) {
    ref.invalidate(userDetailsProvider);
    ref.invalidate(usersDetailsProvider);
    return true;
  } else {
    throw Exception("Failed to update user: ${response.statusCode}");
  }
});
