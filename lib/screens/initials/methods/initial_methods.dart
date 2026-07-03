import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:window_manager/window_manager.dart';
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/constants/urls.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/screens/home/home_screen.dart';
import 'package:labledger/screens/setup/setup_screen.dart';
import 'package:labledger/screens/initials/subscription_renewal_dialog.dart';

class InitialMethods extends ChangeNotifier {
  final BuildContext context;
  final WidgetRef ref;

  InitialMethods(this.context, this.ref);

  String _errorMessage = "";
  String get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPasswordObscured = true;
  bool get isPasswordObscured => _isPasswordObscured;

  bool _isSubscriptionDialogVisible = false;

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordObscured = !_isPasswordObscured;
    notifyListeners();
  }

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 4) return 'Password must be at least 4 characters';
    return null;
  }

  Future<void> login({
    required GlobalKey<FormState> formKey,
    required String username,
    required String password,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      final credentials = LoginCredentials(
        username: username.trim(),
        password: password,
      );
      final authResponse = await ref.read(loginProvider(credentials).future);
      if (!context.mounted) return;

      if (!authResponse.hasAcceptedLicense) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SetupScreen(authResponse: authResponse),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(authResponse: authResponse),
          ),
        );
      }
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();

      if (e is SubscriptionInactiveException ||
          e.message.toLowerCase().contains('subscription')) {
        await handleSubscriptionRestriction(username.trim());
      }
    } catch (e) {
      _errorMessage = "An unexpected error occurred. Please try again.";
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleSubscriptionRestriction(String identifier) async {
    final shouldShowDialog = await _shouldShowUpgradeDialog(identifier);
    if (shouldShowDialog) {
      await showSubscriptionDialog(identifier);
    }
  }

  Future<bool> _shouldShowUpgradeDialog(String identifier) async {
    if (identifier.isEmpty) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$globalBaseUrl${AppUrls.subscriptionPlanContext}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': identifier}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return false;
      }

      return (decoded['can_show_upgrade_dialog'] as bool?) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> showSubscriptionDialog(String identifier) async {
    if (!context.mounted || _isSubscriptionDialogVisible) return;

    _isSubscriptionDialogVisible = true;
    await _setSubscriptionDialogWindowSize();

    try {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => SubscriptionRenewalDialog(
          loginIdentifier: identifier,
        ),
      );
    } finally {
      _isSubscriptionDialogVisible = false;
      await setWindowBehavior(isForLogin: true);
    }
  }

  Future<void> _setSubscriptionDialogWindowSize() async {
    try {
      const dialogSize = Size(1000, 700);
      await windowManager.setMinimumSize(dialogSize);
      await windowManager.setSize(dialogSize);
      await windowManager.center();
    } catch (_) {}
  }
}
