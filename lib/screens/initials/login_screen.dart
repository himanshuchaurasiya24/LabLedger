import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = "";

  Future<Map<String, bool>> attemptLogin({
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
      String statusNumber = response.statusCode.toString();
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        String token = body['access'];
        await storage.write(key: 'access_token', value: token);
        return {
          'success': true,
          'is_admin': body['is_admin'],
        }; // Return the admin status for further use if needed
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
        errorMessage = "Some error occurred.\nCheck server status...";
      });
    }
    return {"success": false, "is_admin": false};
  }

  void login() async {
    debugPrint("Login PRessed.");
    final value = await attemptLogin(
      username: usernameController.text,
      password: passwordController.text,
    );

    if (!mounted) return; // ✅ Prevent using context if the widget is disposed
    if (value['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(isAdmin: value["is_admin"]!),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    setWindowBehavior(isForLogin: true);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.none,
      borderRadius: BorderRadius.circular(24),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Container(
            color: Colors.transparent,
            width: 700,
            height: 350,
            child: Material(
              shadowColor: Colors.black26,
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24),
              child: Row(
                children: [
                  // Left side
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        appIconNameWidget(
                          context: context,
                          forLogInScreen: true,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Medical Records Made Simple",
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                Theme.of(context).colorScheme.brightness ==
                                    Brightness.light
                                ? Colors.black54
                                : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Colors.grey,
                  ),

                  // Right side
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Welcome to ${ref.watch(appNameProvider)}",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.brightness ==
                                        Brightness.light
                                    ? Colors.black87
                                    : Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                labelText: "Username",
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: () {
                                  // login logic here...
                                  login();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: Text(
                                  "Log In",
                                  style: TextStyle(
                                    color:
                                        Theme.of(
                                              context,
                                            ).colorScheme.brightness ==
                                            Brightness.light
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (errorMessage.isNotEmpty)
                              Text(
                                errorMessage,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
