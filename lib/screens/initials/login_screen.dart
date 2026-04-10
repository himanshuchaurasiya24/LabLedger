import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/constants/urls.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/screens/home/home_screen.dart';
import 'package:labledger/screens/initials/subscription_renewal_dialog.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/reusable_ui_components.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:convert';

class LoginScreen extends ConsumerStatefulWidget {
  final String? initialErrorMessage;
  const LoginScreen({super.key, this.initialErrorMessage});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String errorMessage = "";
  bool isLoading = false;
  bool _isPasswordObscured = true;
  bool _isSubscriptionDialogVisible = false;

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    setWindowBehavior(isForLogin: true);

    if (widget.initialErrorMessage != null) {
      errorMessage = widget.initialErrorMessage!;
    }

    final initialError = (widget.initialErrorMessage ?? '').toLowerCase();
    if (initialError.contains('subscription')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleSubscriptionRestriction();
        }
      });
    }

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 4) return 'Password must be at least 4 characters';
    return null;
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final credentials = LoginCredentials(
        username: usernameController.text.trim(),
        password: passwordController.text,
      );
      final authResponse = await ref.read(loginProvider(credentials).future);
      if (mounted) {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(authResponse: authResponse),
          ),
        );
      }
    } on AppException catch (e) {
      setState(() {
        errorMessage = e.message;
      });

      if (e is SubscriptionInactiveException ||
          e.message.toLowerCase().contains('subscription')) {
        await _handleSubscriptionRestriction();
      }
    } catch (e) {
      setState(() {
        errorMessage = "An unexpected error occurred. Please try again.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSubscriptionRestriction() async {
    final identifier = usernameController.text.trim();
    final shouldShowDialog = await _shouldShowUpgradeDialog(identifier);
    if (shouldShowDialog) {
      await _showSubscriptionDialog();
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

  Future<void> _showSubscriptionDialog() async {
    if (!mounted || _isSubscriptionDialogVisible) return;

    _isSubscriptionDialogVisible = true;
    await _setSubscriptionDialogWindowSize();

    try {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => SubscriptionRenewalDialog(
          loginIdentifier: usernameController.text.trim(),
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
      await windowManager.setSkipTaskbar(false);
      await windowManager.setMinimumSize(dialogSize);
      await windowManager.setMaximumSize(dialogSize);
      await windowManager.setSize(dialogSize);
      await windowManager.center();
    } catch (_) {
      // Best effort only. Login flow should continue even if window resize fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color errorContainerColor = theme.colorScheme.errorContainer.withValues(
      alpha: 0.8,
    );
    Color errorBorderColor = theme.colorScheme.error.withValues(alpha: 0.3);
    Color footerTextColor = theme.colorScheme.onSurfaceVariant.withValues(
      alpha: 0.7,
    );

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeController,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: defaultPadding * 1.5,
                        right: defaultPadding * 1.5,
                        bottom: defaultPadding,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          appIconName(
                            context: context,
                            firstName: "Lab",
                            secondName: "Ledger",
                          ),
                          SizedBox(height: defaultHeight / 2),
                          if (errorMessage.isNotEmpty) ...[
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: errorContainerColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: errorBorderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: theme.colorScheme.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          errorMessage,
                                          style: TextStyle(
                                            color: theme
                                                .colorScheme
                                                .onErrorContainer,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: defaultHeight),
                              ],
                            ),
                          ],
                          CustomTextField(
                            controller: usernameController,
                            label: 'Username',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              size: 20,
                            ),
                            keyboardType: TextInputType.text,
                            validator: _validateUsername,
                            tintColor: theme.colorScheme.primary,
                          ),
                          SizedBox(height: defaultHeight),
                          CustomTextField(
                            controller: passwordController,
                            label: 'Password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              size: 20,
                            ),
                            obscureText: _isPasswordObscured,
                            validator: _validatePassword,
                            onSubmitted: (_) => !isLoading ? _login() : null,
                            tintColor: theme.colorScheme.primary,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordObscured
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordObscured = !_isPasswordObscured;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: defaultHeight / 2),
                          Row(
                            children: [
                              const Spacer(),
                              ReusableButton(
                                text: 'Forgot Password?',
                                variant: ButtonVariant.text,
                                onPressed: !isLoading
                                    ? () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            behavior: SnackBarBehavior.floating,

                                            content: Text(
                                              'Contact administrator to reset password',
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                          Spacer(),
                          ReusableButton(
                            text: 'Sign In',
                            variant: ButtonVariant.primary,
                            icon: Icons.login,
                            onPressed: !isLoading ? _login : null,
                            isLoading: isLoading,
                            width: double.infinity,
                            height: 56,
                            borderRadius: 16,
                          ),
                          SizedBox(height: defaultHeight),
                          FutureBuilder<String>(
                            future: getFullAppVersion(),
                            builder: (context, snapshot) {
                              final version = snapshot.data ?? 'Loading...';
                              return Text(
                                "$appName v$version | $appDescription",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: footerTextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
