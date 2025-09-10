import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/authentication/auth_repository.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/screens/home/home_screen.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/reusable_ui_components.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:version/version.dart';

// An enum to manage the different states of the version check
enum VersionCheckStatus { checking, ok, updateRequired, versionCheckFailed }

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
  bool rememberMe = false;
  bool _isPasswordObscured = true; // State for password visibility

  late AnimationController _fadeController;
  // Removed the slide animation controller
  // late AnimationController _slideController;

  VersionCheckStatus _versionStatus = VersionCheckStatus.checking;
  String _requiredVersion = '';

  @override
  void initState() {
    super.initState();
    setWindowBehavior(isForLogin: true);

    // Start the version check when the screen loads
    _checkAppVersion();

    if (widget.initialErrorMessage != null) {
      errorMessage = widget.initialErrorMessage!;
    }

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Removed slide controller initialization
    _fadeController.forward();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _fadeController.dispose();
    // Removed slide controller disposal
    super.dispose();
  }

  Future<void> _checkAppVersion() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final requiredVersionString = await AuthRepository.instance
          .fetchMinimumAppVersion();
      final currentVersion = Version.parse(appVersion);
      final requiredVersion = Version.parse(requiredVersionString);

      if (currentVersion < requiredVersion) {
        if (mounted) {
          setState(() {
            _versionStatus = VersionCheckStatus.updateRequired;
            _requiredVersion = requiredVersionString;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _versionStatus = VersionCheckStatus.ok;
          });
        }
      }
    } catch (e) {
      debugPrint("Error checking version: $e.");
      if (mounted) {
        setState(() {
          _versionStatus = VersionCheckStatus.versionCheckFailed;
        });
      }
    }
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
    if (_versionStatus == VersionCheckStatus.updateRequired ||
        _versionStatus == VersionCheckStatus.versionCheckFailed) {
      return;
    }

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
            builder: (context) {
              return HomeScreen(authResponse: authResponse);
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
    // Removed the SlideTransition widget wrapper
    return Scaffold(
      body: FadeTransition(opacity: _fadeController, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (_versionStatus) {
      case VersionCheckStatus.checking:
        return _buildLoginForm(isEnabled: false);
      case VersionCheckStatus.updateRequired:
        return _buildUpdateRequiredUI();
      case VersionCheckStatus.versionCheckFailed:
        return _buildVersionCheckFailedUI();
      case VersionCheckStatus.ok:
        return _buildLoginForm(isEnabled: true);
    }
  }

  Widget _buildInfoScreen({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String buttonText,
    VoidCallback? onButtonPressed,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: TintedContainer(
          baseColor: iconColor,
          elevationLevel: 2,
          radius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: iconColor),
              const SizedBox(height: 24),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ReusableButton(
                text: buttonText,
                onPressed: onButtonPressed ?? () {},
                width: 253,
                variant: ButtonVariant.elevated,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionCheckFailedUI() {
    return _buildInfoScreen(
      icon: Icons.cloud_off_rounded,
      iconColor: Theme.of(context).colorScheme.error,
      title: 'Verification Failed',
      message:
          'Could not verify the application version. Please check your internet connection and restart the app.',
      buttonText: 'Contact Support',
    );
  }

  Widget _buildUpdateRequiredUI() {
    return _buildInfoScreen(
      icon: Icons.system_update_alt,
      iconColor: Theme.of(context).colorScheme.primary,
      title: 'Update Required',
      message:
          'A new version of the app is available. Please update to\nversion $_requiredVersion to continue.',
      buttonText: 'Contact Support to Update',
    );
  }

  Widget _buildLoginForm({required bool isEnabled}) {
    final theme = Theme.of(context);
    final bool formEnabled = isEnabled && !isLoading;

    return LayoutBuilder(
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
                        secondName: "ledger",
                      ),
                      SizedBox(height: defaultHeight),
                      if (_versionStatus == VersionCheckStatus.checking)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                "Verifying app version...",
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      if (errorMessage.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withValues(
                              alpha: 0.8,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.error.withValues(
                                alpha: 0.3,
                              ),
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
                                    color: theme.colorScheme.onErrorContainer,
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
                      CustomTextField(
                        controller: usernameController,
                        label: 'Username',
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                        keyboardType: TextInputType.text,
                        validator: _validateUsername,
                        tintColor: theme.colorScheme.primary,
                      ),
                      SizedBox(height: defaultHeight),
                      CustomTextField(
                        controller: passwordController,
                        label: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        obscureText: _isPasswordObscured,
                        validator: _validatePassword,
                        onSubmitted: (_) => formEnabled ? _login() : null,
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
                            onPressed: formEnabled
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
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
                      const Spacer(), // This is the flexible space
                      ReusableButton(
                        text: 'Sign In',
                        variant: ButtonVariant.primary,
                        icon: Icons.login,
                        onPressed: formEnabled ? _login : null,
                        isLoading: isLoading,
                        width: double.infinity,
                        height: 56,
                        borderRadius: 16,
                      ),
                      SizedBox(height: defaultHeight * 2),
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
      },
    );
  }
}

// Helper extension to simplify color modifications in TintedContainer
extension ColorValues on Color {
  /// Creates a new color by replacing specified values of the original color.
  /// Values for alpha, red, green, and blue should be between 0.0 and 1.0.
  Color withValues({double? alpha, double? red, double? green, double? blue}) {
    // Start with the original color
    Color updatedColor = this;

    // Apply new values if they are provided
    if (alpha != null) {
      updatedColor = updatedColor.withAlpha((alpha * 255).round());
    }
    if (red != null) {
      updatedColor = updatedColor.withRed((red * 255).round());
    }
    if (green != null) {
      updatedColor = updatedColor.withGreen((green * 255).round());
    }
    if (blue != null) {
      updatedColor = updatedColor.withBlue((blue * 255).round());
    }

    return updatedColor;
  }
}
