// screens/initials/window_loading_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/methods/handle_api_error.dart';
import 'package:version/version.dart';
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/authentication/auth_repository.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/auth_response_model.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/screens/home/home_screen.dart';
import 'package:labledger/screens/initials/animated_progress_indicator.dart';
import 'package:labledger/screens/initials/login_screen.dart';
import 'package:labledger/screens/window_scaffold.dart';

class WindowLoadingScreen extends ConsumerStatefulWidget {
  const WindowLoadingScreen({super.key});

  @override
  ConsumerState<WindowLoadingScreen> createState() =>
      _WindowLoadingScreenState();
}

class _WindowLoadingScreenState extends ConsumerState<WindowLoadingScreen> {
  String tileText = "Loading...";
  bool _isContentVisible = false;

  @override
  void initState() {
    super.initState();
    setWindowBehavior(isLoadingScreen: true);
    _checkAuth();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isContentVisible = true;
        });
      }
    });
  }

  Future<void> _checkAuth() async {
    try {
      setState(() {
        tileText = "Verifying session...";
      });

      // 1. Define all three asynchronous operations to run in parallel.
      final authFuture = ref.read(verifyAuthProvider.future);
      final versionFuture = AuthRepository.instance.fetchMinimumAppVersion();
      final delayFuture = Future.delayed(const Duration(seconds: 3));

      // 2. Wait for all three to complete.
      final results = await Future.wait([
        authFuture,
        versionFuture,
        delayFuture,
      ]);

      // 3. Extract the results.
      final authResponse = results[0] as AuthResponse;
      final requiredVersionString = results[1] as String;
      // 4. Perform the version check.
      final currentVersion = Version.parse(appVersion);
      debugPrint(currentVersion.toString());

      final requiredVersion = Version.parse(requiredVersionString);
      debugPrint(requiredVersionString);
      debugPrint(requiredVersionString);

      if (currentVersion < requiredVersion) {
        // VERSION IS OUTDATED. Navigate to LoginScreen which will show the update message.
        if (mounted) {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
              // The LoginScreen's internal logic will handle showing the update UI.
              builder: (context) => const LoginScreen(),
            ),
          );
        }
        return; // Stop execution here.
      }

      // 5. If version is OK, proceed to HomeScreen.
      setState(() {
        tileText = "Authentication successful!";
      });

      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        final userData = authResponse.toHomeScreenData();
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return WindowScaffold(
                allowFullScreen: true,
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
    } on AuthException catch (e) {
      // This will catch true auth failures (like an expired token).
      handleApiError(e);
    } catch (e) {
      // Handle other errors (like network failure during the initial load).
      // Navigate to LoginScreen without a message; its internal version check
      // will run and show the appropriate error UI.
      if (mounted) {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
      body: AnimatedOpacity(
        opacity: _isContentVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeIn,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            appIconName(
              context: context,
              firstName: "Lab",
              secondName: "Ledger",
              fontSize: 100,
              alignment: MainAxisAlignment.center,
            ),
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
