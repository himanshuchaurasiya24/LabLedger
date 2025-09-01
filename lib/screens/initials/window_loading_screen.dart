import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/screens/home/home_screen.dart';
import 'package:labledger/screens/initials/animated_progress_indicator.dart';
import 'package:labledger/screens/initials/login_screen.dart';
import 'package:labledger/screens/window_scaffold.dart';

class WindowLoadingScreen extends ConsumerStatefulWidget {
  const WindowLoadingScreen({super.key});

  @override
  ConsumerState<WindowLoadingScreen> createState() => _WindowLoadingScreenState();
}

class _WindowLoadingScreenState extends ConsumerState<WindowLoadingScreen> {
  String tileText = "Loading...";

  @override
  void initState() {
    super.initState();
    setWindowBehavior(isForLogin: true); // Block F11 on loading screen
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      setState(() {
        tileText = "Verifying credentials...";
      });

      final authResponse = await ref.read(verifyAuthProvider.future);

      setState(() {
        tileText = "Authentication successful!";
      });

      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        final userData = authResponse.toHomeScreenData();
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return WindowScaffold(
                allowFullScreen: true, // Enable F11 for home screen
                isInitialScreen: true,
                centerWidget: Text(
                  "${userData['centerDetail']['center_name'].toString().toUpperCase()}, ${userData["centerDetail"]['address']}",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                child: HomeScreen(
                  id: userData['id'],
                  firstName: userData['firstName'],
                  lastName: userData['lastName'],
                  username: userData['username'],
                  isAdmin: userData['isAdmin'],
                  centerDetail: userData['centerDetail'],
                ),
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
    } on SubscriptionInactiveException {
      _navigateToLogin("Account locked - contact administrator");
    } on SubscriptionExpiredException catch (e) {
      _navigateToLogin("Subscription expired - $e please renew");
    } on ServerException catch (e) {
      _navigateToLogin("Server error: ${e.message}");
    } catch (e) {
      _navigateToLogin("Unexpected error occurred");
    }
  }

  void _navigateToLogin(String reason) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        tileText = reason;
      });

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Lab",
                style: TextStyle(
                  fontSize: 90,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary
                ),
              ),
              Text(
                "Ledger",
                style: TextStyle(
                  fontSize: 90,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary
                ),
              ),
            ],
          ),
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
    );
  }
}