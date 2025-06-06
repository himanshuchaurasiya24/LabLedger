import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/home_screen.dart';
import 'package:labledger/screens/initials/animated_progress_indicator.dart';
import 'package:labledger/screens/login_screen.dart';
import 'package:window_manager/window_manager.dart';

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
    setWindowBehavior(isForLogin: true);
    widget.onLoginScreen.value = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  LoginScreen()),
    );
  }

  void _goToHome() {
    setWindowBehavior();
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
    debugPrint("before checking auth");
    _checkAuth();
    debugPrint("after checking auth");
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
    debugPrint("checking auth");
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: 'access_token');

    if (token == null) {
      await Future.delayed(ref.read(splashScreenTimeProvider));
      _goToLogin();
      return;
    }

    try {
      debugPrint('${ref.read(baseUrlProvider)}verify-auth/');
      debugPrint('trying url');
      final response = await http
          .get(
            Uri.parse('${ref.read(baseUrlProvider)}verify-auth/'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        await Future.delayed(ref.read(splashScreenTimeProvider));
        _goToHome();
      } else {
        await Future.delayed(ref.read(splashScreenTimeProvider));
        _goToLogin();
      }
    } catch (e) {
      await Future.delayed(ref.read(splashScreenTimeProvider), () {
        setState(() {
          tileText = "Oops! Server is not responding yet, retrying...";
        });
      });
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
