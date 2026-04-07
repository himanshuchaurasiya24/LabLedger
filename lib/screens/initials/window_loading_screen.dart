import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/authentication/auth_repository.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/screens/home/home_screen.dart';
import 'package:labledger/screens/initials/update_required_screen.dart';
import 'package:labledger/screens/ui_components/animated_progress_indicator.dart';
import 'package:labledger/screens/initials/login_screen.dart';
import 'package:version/version.dart';

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
      if (mounted) {
        try {
          setState(() => _isContentVisible = true);
        } catch (e) {
          // Widget disposed, ignore
        }
      }
    });
  }

  Future<void> _determineInitialRoute() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      if (mounted) {
        try {
          setState(() => tileText = "Verifying app version...");
        } catch (e) {
          // Ignore if disposed
        }
      }
      if (!mounted) return;

      final requiredVersionString = await AuthRepository.instance
          .fetchMinimumAppVersion();
      if (!mounted) return;

      final currentVersionString = await getAppVersion();
      final currentVersion = Version.parse(currentVersionString);
      final requiredVersion = Version.parse(requiredVersionString);

      if (currentVersion < requiredVersion) {
        if (!mounted) return;
        _navigateTo(
          UpdateRequiredScreen(requiredVersion: requiredVersion.toString()),
        );
        return;
      }

      if (mounted) {
        try {
          setState(() => tileText = "Verifying session...");
        } catch (e) {
          // Ignore if disposed
        }
      }
      if (!mounted) return;

      final authResponse = await ref.read(currentUserProvider.future);
      if (!mounted) return;

      if (mounted) {
        try {
          setState(() => tileText = "Authentication successful!");
        } catch (e) {
          // Ignore if disposed
        }
      }
      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;

      _navigateTo(HomeScreen(authResponse: authResponse));
    } on AuthException catch (e) {
      if (mounted) {
        _navigateTo(LoginScreen(initialErrorMessage: e.message));
      }
    } catch (e, stackTrace) {
      debugPrint("ERROR in _determineInitialRoute: $e\n$stackTrace");
      if (mounted) {
        _navigateTo(
          const LoginScreen(
            initialErrorMessage: "An error occurred. Please try again.",
          ),
        );
      }
    }
  }

  void _navigateTo(Widget screen) {
    try {
      if (mounted && navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(builder: (context) => screen),
        );
      }
    } catch (e, stackTrace) {
      debugPrint("ERROR in _navigateTo: $e\n$stackTrace");
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
