import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/screens/home/home_screen.dart';
import 'package:labledger/screens/window_scaffold.dart';
import 'package:http/http.dart' as http;

// 2. LOGIN SCREEN
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = "";
  @override
  void initState() {
    super.initState();
    setWindowBehavior(isForLogin: true); // Block F11 and window controls
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> attemptLogin({
    required String username,
    required String password,
  }) async {
    final storage = FlutterSecureStorage();

    try {
      final response = await http
          .post(
            Uri.parse("$globalBaseUrl/api/token/"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 5));
      String statusNumber = response.statusCode.toString();
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        String accessToken = body['access'];
        String refreshToken = body['refresh'];
        await storage.write(key: 'access_token', value: accessToken);
        await storage.write(key: 'refresh_token', value: refreshToken);
        return {
          'success': true,
          'is_admin': body['is_admin'],
          'username': body['username'],
          'first_name': body['first_name'],
          'last_name': body['last_name'],
          'id': body['id'],
          'center_detail': body['center_detail'],
        };
      } else if (response.statusCode == 401) {
        String error = body['detail'];
        setState(() {
          errorMessage = "$error : Unauthorized";
        });
        return {"success": false, "is_admin": false};
      } else {
        setState(() {
          errorMessage = "Internal Server Error...: $statusNumber";
        });
        return {"success": false, "is_admin": false};
      }
    } catch (e) {
      setState(() {
        errorMessage = "Some error occurred. $e \nCheck server status...";
      });
    }
    return {"success": false, "is_admin": false};
  }

  void login() async {
    final value = await attemptLogin(
      username: usernameController.text,
      password: passwordController.text,
    );

    if (!mounted) return;

    if (value['success'] == true) {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (context) {
        return     WindowScaffold(
              allowFullScreen: true, // Enable F11 for home screen
              isInitialScreen: true,
              child: HomeScreen(
                isAdmin: value["is_admin"]!,
                firstName: value['first_name']!,
                lastName: value['last_name']!,
                username: value['username']!,
                id: value['id'],
                centerDetail: value['center_detail'],
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App logo
              appIconName(
                context: context,
                firstName: " Lab",
                secondName: "Ledger",
                fontSize: 32,
              ),
              const SizedBox(height: 32),
              // Login form
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: login,
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
