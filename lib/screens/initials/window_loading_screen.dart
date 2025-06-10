import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/home_screen.dart';
import 'package:labledger/screens/initials/animated_progress_indicator.dart';
import 'package:labledger/screens/initials/login_screen.dart';

class WindowLoadingScreen extends ConsumerStatefulWidget {
  const WindowLoadingScreen({super.key, required this.onLoginScreen});
  final ValueNotifier<bool> onLoginScreen;

  @override
  ConsumerState<WindowLoadingScreen> createState() =>
      _WindowLoadingScreenState();
}

class _WindowLoadingScreenState extends ConsumerState<WindowLoadingScreen> {
  String tileText = "";

  void _goToLogin() {
    widget.onLoginScreen.value = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _goToHome({
    required bool isAdmin,
    required id,
    required firstName,
    required lastName,
    required username,
  }) {
    widget.onLoginScreen.value = false;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          isAdmin: isAdmin,
          id: id,
          firstName: firstName,
          lastName: lastName,
          username: username,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.onLoginScreen.value = true;
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    debugPrint("checking auth");
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: 'access_token');

    if (token == null) {
      debugPrint("token : null");
      await Future.delayed(ref.read(splashScreenTimeProvider));
      _goToLogin();
      return;
    }

    try {
      final response = await http
          .get(
            Uri.parse('${ref.read(baseUrlProvider)}verify-auth/'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 5));

      bool? isAdmin;
      String? username;
      String? firstName;
      String? lastName;
      int? id;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        isAdmin = body['is_admin'];
        username = body['username'];
        firstName = body['first_name'];
        lastName = body['last_name'];
        id = body['id'];
        debugPrint(body.toString());
        await Future.delayed(ref.read(splashScreenTimeProvider));
        _goToHome(isAdmin: isAdmin!, firstName: firstName, id: id, lastName: lastName, username: username);
      } else {
        debugPrint("splash timer runnig");
        await Future.delayed(ref.read(splashScreenTimeProvider));
        debugPrint("going login");
        _goToLogin();
      }
    } catch (e) {
      setState(() {
        tileText = "Oops! Server is not responding yet, retrying...";
      });
      debugPrint("error in windows loading screen");
      debugPrint("checking auth...");
      _checkAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ref.read(splashAppNameProvider),
            // SizedBox(height: 30),
            SizedBox(width: 350, child: AnimatedLabProgressIndicator()),
            SizedBox(height: 10),
            Text(
              tileText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
