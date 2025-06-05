import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/home_screen.dart';
import 'package:labledger/screens/login_screen.dart';
import 'package:window_manager/window_manager.dart';


class WindowLoadingScreen extends ConsumerStatefulWidget {
  const WindowLoadingScreen({super.key, required this.onLoginScreen});
  final ValueNotifier<bool> onLoginScreen;

  @override
  ConsumerState<WindowLoadingScreen> createState() => _WindowLoadingScreenState();
}

class _WindowLoadingScreenState extends ConsumerState<WindowLoadingScreen> {
  String tileText = "Connecting to Server...";

  void _goToLogin() {
    widget.onLoginScreen.value = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _goToHome() {
    widget.onLoginScreen.value = false;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.onLoginScreen.value = true;
    _checkAuth();
  }

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

  Future<void> _checkAuth() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: 'access_token');

    if (token == null) {
      await Future.delayed(const Duration(seconds: 2));
      setWindowBehavior(isForLogin: true);
      _goToLogin();
      return;
    }

    try {
      final response = await http
          .get(
            Uri.parse('${ref.read(baseUrlProvider)}verify-auth/'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        await Future.delayed(const Duration(seconds: 2));
        setWindowBehavior();
        _goToHome();
      } else {
        await Future.delayed(const Duration(seconds: 2));
        setWindowBehavior(isForLogin: true);
        _goToLogin();
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          tileText = "Retrying.. Check if you have started the server";
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ref.watch(appNameProvider),
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
            Text(tileText, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
