import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:labledger/providers/custom_providers.dart';
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
