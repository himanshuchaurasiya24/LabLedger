import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/screens/home_screen.dart';
import 'package:labledger/screens/login_screen.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WindowLoadingScreen extends StatefulWidget {
  const WindowLoadingScreen({super.key});

  @override
  State<WindowLoadingScreen> createState() => _WindowLoadingScreenState();
}

class _WindowLoadingScreenState extends State<WindowLoadingScreen> {
  String tileText = "Connecting to Server...";
  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void setWindowBehavior() async {
    await windowManager.setSize(const Size(1280, 720), animate: true);
    await windowManager.center();
    await windowManager.setSkipTaskbar(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    // await windowManager.setFullScreen(true);
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    // final token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzQ5MTIxNDcyLCJpYXQiOjE3NDkxMjA1NzIsImp0aSI6IjA0ZDNiODlmYTViNjRmNDdiYTljNmU5ZjA4ODgxNzBjIiwidXNlcl9pZCI6MX0.clgZKsaIP6FtK8jw-TSWAYarRAPRf-yQDjaIlpBPYdA";


    if (token == null) {
      await Future.delayed(const Duration(seconds: 1), ()  {
        setWindowBehavior();
        // No token found, redirect to login
        _goToLogin();
      });

      return;
    }

    try {
      final response = await http
          .get(
            Uri.parse('http://localhost:8000/verify-auth/'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        await Future.delayed(const Duration(seconds: 2));
        setWindowBehavior();
        _goToHome();
      } else {
        await Future.delayed(const Duration(seconds: 2));
        setWindowBehavior();

        _goToLogin();
      }
    } catch (e) {
      // Server not ready yet, wait and retry
      await Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          tileText = "Retrying.. Check if you have started the server";
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[400],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'LabLedger',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Text(tileText, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
