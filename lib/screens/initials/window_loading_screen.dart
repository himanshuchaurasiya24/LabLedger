// =============================================================================
// INDIVIDUAL SCREEN IMPLEMENTATIONS
// =============================================================================

// 1. WINDOW LOADING SCREEN
import 'package:flutter/material.dart';
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/authentication/auth_repository.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/screens/home/home_screen.dart';
import 'package:labledger/screens/initials/animated_progress_indicator.dart';
import 'package:labledger/screens/initials/login_screen.dart';
import 'package:labledger/screens/window_scaffold.dart';

class WindowLoadingScreen extends StatefulWidget {
  const WindowLoadingScreen({super.key});

  @override
  State<WindowLoadingScreen> createState() => _WindowLoadingScreenState();
}

class _WindowLoadingScreenState extends State<WindowLoadingScreen> {
  String tileText = "Loading...";

  @override
  void initState() {
    super.initState();
    setWindowBehavior(isForLogin: true); // Block F11 on loading screen
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authRepo = AuthRepository.instance;
    try {
      setState(() {
        tileText = "Verifying credentials...";
      });

      final userData = await authRepo.verifyAuth();

      setState(() {
        tileText = "Authentication successful!";
      });

      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
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
    } on ServerException catch (e) {
      _navigateToLogin("Server error: ${e.message}");
    } catch (e) {
      _navigateToLogin("Unexpected error occurred");
    }
  }

  void _navigateToLogin(String reason)async  {
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            appIconName(context: context, firstName: "Lab", secondName:"Ledger", fontSize: 100),
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
