import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:labledger/providers/custom_providers.dart';
import 'package:window_manager/window_manager.dart';

void setWindowBehavior({bool? isForLogin}) async {
  bool isLogin = isForLogin ?? false;
  if (!isLogin) {
    await windowManager.setSize(const Size(1280, 720), animate: true);
    await windowManager.center();
    await windowManager.setSkipTaskbar(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
  } else {
    await windowManager.setSize(const Size(700, 350), animate: true);
    await windowManager.center();
    await windowManager.setSkipTaskbar(true);
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  }
}

Future<String> attemptLogin({
  required String username,
  required String password,
}) async {
  final storage = FlutterSecureStorage();
  try {
    final response = await http
        .post(
          Uri.parse("$baseURL/api/token/"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      setWindowBehavior();
      final body = jsonDecode(response.body);
      String token = body['access'];
      await storage.write(key: 'access_token', value: token);
      return body['is_admin'].toString(); // Return the admin status for further use if needed
    } else if (response.statusCode == 401) {
      final body = jsonDecode(response.body);
      String error = body['detail'];
      return error; // Return an error message
    } else {
      return "Internal server error: status ${response.statusCode}"; // Handle other status codes
    }
  } catch (e) {
    debugPrint('Error during login: $e');
    return e.toString();
  }
}
