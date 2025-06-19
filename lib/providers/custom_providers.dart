import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/models/user_model.dart';

final String baseURL = 'http://127.0.0.1:8000/';
final double defaultPadding = 12;
final double minimalBorderRadius = 6;
final titleBarStatusProvider = FutureProvider<String?>((ref) {
  final storage = FlutterSecureStorage();
  return storage.read(key: 'removeTitleBar');
});
final splashScreenTimeProvider = Provider<Duration>((ref) {
  return const Duration(seconds: 3); // Duration for splash screen
});
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});
final tokenProvider = FutureProvider.autoDispose<String?>((ref) {
  final storage = FlutterSecureStorage();
  return storage.read(key: 'access_token');
});
final appNameProvider = Provider<String>((ref) {
  return 'LabLedger';
});
final appVersionProvider = Provider<String>((ref) {
  return '1.0.0';
});
final appDescriptionProvider = Provider<String>((ref) {
  return 'Medical Records Made Simple';
});
final baseUrlProvider = Provider<String>((ref) {
  return baseURL; // Replace with your actual base URL
});
final userDetailsProvider = FutureProvider.family.autoDispose<User?, int>((
  ref,
  id,
) async {
  final token = await ref.watch(
    tokenProvider.future,
  ); // ⬅️ await the future here
  final baseUrl = ref.read(baseUrlProvider);

  if (token == null) {
    // Handle token error gracefully
    throw Exception("No access token found");
  }

  final response = await http.get(
    Uri.parse("$baseUrl/auth/staffs/staff/$id/"),
    headers: {"Authorization": "Bearer $token"},
  );

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
  final token = await ref.watch(tokenProvider.future);
  final baseUrl = ref.read(baseUrlProvider);

  if (token == null) {
    throw Exception("No access token found");
  }

  final response = await http.patch(
    Uri.parse("$baseUrl/auth/staffs/staff/${user.id}/"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode(user.toJson()),
  );

  if (response.statusCode == 200 || response.statusCode == 204) {
    return true;
  } else {
    throw Exception("Failed to update user: ${response.statusCode}");
  }
});

final splashAppNameProvider = Provider<Widget>((ref) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Lab",
        style: TextStyle(
          fontSize: 90,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 0, 110, 164),
        ),
      ),
      Text(
        "Ledger",
        style: TextStyle(
          fontSize: 90,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 2, 166, 36),
        ),
      ),
    ],
  );
});



final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((
  ref,
) {
  final storage = ref.watch(secureStorageProvider);
  return ThemeNotifier(storage);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'theme_mode';
  final FlutterSecureStorage _storage;

  ThemeNotifier(this._storage) : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await _storage.read(key: _key);
    switch (mode) {
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'light':
        state = ThemeMode.light;
        break;
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> toggleTheme(ThemeMode mode) async {
    state = mode;

    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };

    await _storage.write(key: _key, value: value);
  }
}
