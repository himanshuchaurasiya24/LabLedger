import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/authentication/auth_repository.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/screens/home/home_screen.dart';
import 'package:labledger/screens/ui_components/animated_progress_indicator.dart';
import 'package:labledger/screens/initials/login_screen.dart';
import 'package:version/version.dart';

// Assuming UpdateRequiredScreen is defined elsewhere
// import 'package:labledger/screens/initials/update_required_screen.dart';

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
    _determineInitialRoute();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isContentVisible = true);
    });
  }

  Future<void> _determineInitialRoute() async {
    // A minimum delay ensures the splash screen is visible briefly for a smooth UX.
    await Future.delayed(const Duration(seconds: 3));

    try {
      setState(() => tileText = "Verifying app version...");
      final requiredVersionString =
          await AuthRepository.instance.fetchMinimumAppVersion();
      final currentVersion = Version.parse(appVersion);
      final requiredVersion = Version.parse(requiredVersionString);

      if (currentVersion < requiredVersion) {
        // If version is outdated, navigate to the dedicated update screen.
        // _navigateTo(
        //   UpdateRequiredScreen(requiredVersion: requiredVersionString),
        // );
        return;
      }

      setState(() => tileText = "Verifying session...");
      
      // ✅ CORRECTED LINE:
      // We now read 'currentUserProvider', which is the single source of truth
      // for the user's authentication state.
      final authResponse = await ref.read(currentUserProvider.future);

      // If session is valid, go to the home screen.
      setState(() => tileText = "Authentication successful!");
      await Future.delayed(const Duration(milliseconds: 1000));
      _navigateTo(HomeScreen(authResponse: authResponse));

    } on AuthException catch (e) {
      // If any auth error occurs (expired token, locked account), go to the login screen
      // with a clear message explaining why.
      _navigateTo(LoginScreen(initialErrorMessage: e.message));
    } catch (e) {
      // For any other error (e.g., network failure during version check),
      // go to the login screen with a generic error message.
      _navigateTo(
        const LoginScreen(
          initialErrorMessage: "Network error. Please check your connection.",
        ),
      );
    }
  }

  void _navigateTo(Widget screen) {
    if (mounted) {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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