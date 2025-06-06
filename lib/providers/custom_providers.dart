import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final String baseURL = 'http://127.0.0.1:8000/';
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});
final splashScreenTimeProvider = Provider<Duration>((ref) {
  return const Duration(seconds: 3); // Duration for splash screen
});
final tokenProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  return await storage.read(key: 'access_token');
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

final appIconNameWidgetProvider = Provider<Widget>((ref) {
  return Column(
    children: [
      Image.asset('assets/images/app_icon.png', width: 160, height: 160),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Lab",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 110, 164),
            ),
          ),
          Text(
            "Ledger",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 2, 166, 36),
            ),
          ),
        ],
      ),
    ],
  );
});

Future<void> attemptLogin({
  required String username,
  required String password,
  required VoidCallback function,
}) async {
  final storage = FlutterSecureStorage();
  final response = await http
      .post(Uri.parse("$baseURL/api/token/"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}))
      .timeout(const Duration(seconds: 5));
  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    debugPrint("Login response: $body");
    String token = body['access'];
    await storage.write(key: 'access_token', value: token);
    debugPrint("Login successful, token: $token");
    function(); // Call the provided function on successful login
  } else if (response.statusCode == 401) {
    final body = jsonDecode(response.body);
    String error = body['detail'];
    debugPrint("Login failed: $error");
    function();
  } else {
    debugPrint("Login failed: Internal Server Error");
  }
}
