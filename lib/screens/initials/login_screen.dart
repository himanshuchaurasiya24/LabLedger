// screens/initials/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/authentication/auth_repository.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/screens/home/home_screen.dart';
import 'package:labledger/screens/ui_components/reusable_ui_components.dart';
import 'package:version/version.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';

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

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
      // If the version check itself fails, show a persistent error screen.
      debugPrint("Error checking version: $e.");
      if (mounted) {
        setState(() {
          _versionStatus = VersionCheckStatus.versionCheckFailed;
        });
      }
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Username is required';
    if (value.length < 3) return 'Username must be at least 3 characters';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 4) return 'Password must be at least 4 characters';
    return null;
  }

  void _login() async {
    // Block login attempts if an update is required or the check failed
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
              return HomeScreen(authResponse: authResponse,);
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
            child: _buildBody(),
          ),
        ),
      ),
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

  Widget _buildVersionCheckFailedUI() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 60,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 24),
          Text(
            'Verification Failed',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Could not verify the application version. Please check your internet connection and restart the app.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ReusableButton(
            text: 'Contact Support',
            onPressed: () {},
            width: 253,
            variant: ButtonVariant.elevated,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateRequiredUI() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.system_update_alt,
            size: 60,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Update Required',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'A new version of the app is available. Please update to\nversion $_requiredVersion to continue.',
            style: theme.textTheme.bodyLarge,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ReusableButton(
            text: 'Contact Support to Update',
            onPressed: () {},
            width: 253,
            variant: ButtonVariant.elevated,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm({required bool isEnabled}) {
    final theme = Theme.of(context);
    final bool formEnabled = isEnabled && !isLoading;
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                      child: CircularProgressIndicator(strokeWidth: 3),
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
                  color: theme.colorScheme.errorContainer.withAlpha(204),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.error.withAlpha(77),
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
              enabled: formEnabled,
            ),
            SizedBox(height: defaultHeight),
            ReusableTextField(
              controller: passwordController,
              label: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              showTogglePasswordVisibility: true,
              validator: _validatePassword,
              onSubmitted: (_) => formEnabled ? _login() : null,
              enabled: formEnabled,
            ),
            SizedBox(height: defaultHeight),
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: formEnabled
                      ? (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        }
                      : null,
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
            SizedBox(height: defaultHeight),
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
            SizedBox(height: defaultHeight),
            Text(
              "$appName $appVersion | $appDescription",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withAlpha(178),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
