import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/screens/home/home_screen.dart';
import 'package:labledger/screens/initials/ui_components/reusable_ui_components.dart';
import 'package:labledger/screens/window_scaffold.dart';
import 'package:labledger/authentication/auth_exceptions.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

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
  bool rememberMe = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    setWindowBehavior(isForLogin: true);

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 4) {
      return 'Password must be at least 4 characters';
    }
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
        final userData = authResponse.toHomeScreenData();
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return WindowScaffold(
                allowFullScreen: true,
                isInitialScreen: true,
                child: HomeScreen(
                  isAdmin: userData["isAdmin"]!,
                  firstName: userData['firstName']!,
                  lastName: userData['lastName']!,
                  username: userData['username']!,
                  id: userData['id'],
                  centerDetail: userData['centerDetail'],
                ),
              );
            },
          ),
        );
      }
    } on InvalidCredentialsException {
      setState(() {
        errorMessage = "Invalid username or password. Please try again.";
      });
    } on SubscriptionInactiveException {
      setState(() {
        errorMessage =
            "Your account has been locked. Please contact administrator.";
      });
    } on SubscriptionExpiredException {
      setState(() {
        errorMessage =
            "Your subscription has expired. Please renew to continue.";
      });
    } on NetworkException {
      setState(() {
        errorMessage =
            "Network error. Please check your connection and try again.";
      });
    } on ServerException catch (e) {
      setState(() {
        errorMessage = "Server error: ${e.message}";
      });
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: defaultPadding * 2,
              vertical: defaultPadding,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(defaultRadius),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  appIconName(
                    context: context,
                    firstName: "Lab",
                    secondName: "ledger",
                  ),

                  SizedBox(height: defaultHeight),

                  // Error Message
                  if (errorMessage.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer.withValues(
                          alpha: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.3),
                        ),
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
                                color: theme.colorScheme.error,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: defaultHeight * 2),
                  ],

                  ReusableTextField(
                    controller: usernameController,
                    label: 'Username',
                    hintText: 'Enter your username',
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.text,
                    validator: _validateUsername,
                    enabled: !isLoading,
                  ),

                  SizedBox(height: defaultHeight),

                  // Password Field
                  ReusableTextField(
                    controller: passwordController,
                    label: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    showTogglePasswordVisibility: true,
                    validator: _validatePassword,
                    onSubmitted: (_) => _login(),
                    enabled: !isLoading,
                  ),

                  SizedBox(height: defaultHeight),

                  // Remember Me & Forgot Password
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  rememberMe = value ?? false;
                                });
                              },
                        activeColor: theme.colorScheme.primary,
                      ),
                      Text(
                        'Remember me',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      ReusableButton(
                        text: 'Forgot Password?',
                        variant: ButtonVariant.text,
                        onPressed: isLoading
                            ? null
                            : () {
                                // Handle forgot password
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Contact administrator to reset password',
                                    ),
                                  ),
                                );
                              },
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),

                  SizedBox(height: defaultHeight),

                  // Login Button
                  ReusableButton(
                    text: 'Sign In',
                    variant: ButtonVariant.primary,
                    icon: Icons.login,
                    onPressed: isLoading ? null : _login,
                    isLoading: isLoading,
                    width: double.infinity,
                    height: 56,
                    borderRadius: 16,
                  ),

                  SizedBox(height: defaultHeight),

                  // Footer
                  Text(
                    "$appName $appVersion | $appDescription",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
