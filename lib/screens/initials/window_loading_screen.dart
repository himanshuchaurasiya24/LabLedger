// Updated splash screen - window_loading_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/authentication/auth_repository.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/screens/home/home_screen.dart';
import 'package:labledger/screens/initials/animated_progress_indicator.dart';
import 'package:labledger/screens/initials/login_screen.dart';

class WindowLoadingScreen extends ConsumerStatefulWidget {
  const WindowLoadingScreen({super.key});

  @override
  ConsumerState<WindowLoadingScreen> createState() =>
      _WindowLoadingScreenState();
}

class _WindowLoadingScreenState extends ConsumerState<WindowLoadingScreen> {
  String tileText = "Checking authentication...";

  @override
  void initState() {
    super.initState();
    setWindowBehavior(isForLogin: true);
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Use singleton instance instead of creating new one
    final authRepo = AuthRepository.instance;
    try {
      setState(() {
        tileText = "Verifying credentials...";
      });

      final userData = await authRepo.verifyAuth();

      setState(() {
        tileText = "Authentication successful!";
      });

      // Small delay to show success message
      await Future.delayed(const Duration(milliseconds: 500));

      // ✅ Auth valid → go to HomeScreen with validated data
      if (mounted) {
        isLoginScreen.value = false;
        setWindowBehavior(isForLogin: false);
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return HomeScreen(
                id: userData['id'],
                firstName: userData['firstName'],
                lastName: userData['lastName'],
                username: userData['username'],
                isAdmin: userData['isAdmin'],
                centerDetail: userData['centerDetail'],
              );
            },
          ),
        );
      }
    } on TokenExpiredException {
      _navigateToLogin("Session expired - please login again");
    } on InvalidCredentialsException {
      _navigateToLogin("Invalid credentials");
    } on NetworkException {
      _navigateToLogin("Network error - check connection");
    } on ServerException catch (e) {
      _navigateToLogin("Server error: ${e.message}");
    } catch (e) {
      _navigateToLogin("Unexpected error occurred");
    }
  }

  void _navigateToLogin(String reason) {
    if (mounted) {
      setState(() {
        tileText = reason;
      });

      // Show error briefly before navigating
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setWindowBehavior(isForLogin: true);
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      });
    }
  }

  final splashAppNameWidget = Row(
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            splashAppNameWidget,
            const SizedBox(width: 350, child: AnimatedLabProgressIndicator()),
            const SizedBox(height: 10),
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
