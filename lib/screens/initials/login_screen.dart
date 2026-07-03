import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';
import 'package:labledger/utils/controller_disposer.dart';
import 'package:labledger/screens/initials/methods/initial_methods.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? initialErrorMessage;
  const LoginScreen({super.key, this.initialErrorMessage});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin, ControllerDisposer {
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;
  final _formKey = GlobalKey<FormState>();

  late final InitialMethods _methods;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    setWindowBehavior(isForLogin: true);

    _methods = InitialMethods(context, ref);
    _methods.addListener(() {
      if (mounted) setState(() {});
    });

    if (widget.initialErrorMessage != null) {
      _methods.setErrorMessage(widget.initialErrorMessage!);
    }

    final initialError = (widget.initialErrorMessage ?? '').toLowerCase();
    if (initialError.contains('subscription')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _methods.handleSubscriptionRestriction(usernameController.text.trim());
        }
      });
    }

    usernameController = createController();
    passwordController = createController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    disposeControllers();
    _methods.dispose();
    _fadeController.dispose();
    super.dispose();
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
                          if (_methods.errorMessage.isNotEmpty) ...[
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
                                          _methods.errorMessage,
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
                            validator: _methods.validateUsername,
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
                            obscureText: _methods.isPasswordObscured,
                            validator: _methods.validatePassword,
                            onSubmitted: (_) => !_methods.isLoading
                                ? _methods.login(
                                    formKey: _formKey,
                                    username: usernameController.text,
                                    password: passwordController.text,
                                  )
                                : null,
                            tintColor: theme.colorScheme.primary,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _methods.isPasswordObscured
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                              ),
                              onPressed: _methods.togglePasswordVisibility,
                            ),
                          ),
                          SizedBox(height: defaultHeight / 2),
                          Row(
                            children: [
                              const Spacer(),
                              TextButton(
                                onPressed: !_methods.isLoading
                                    ? () {
                                        showCustomSnackBar(
                                          context: context,
                                          message: 'Contact administrator to reset password',
                                          icon: Icons.info_outline,
                                          backgroundColor: theme.colorScheme.secondary,
                                        );
                                      }
                                    : null,
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          CustomElevatedButton(
                            label: _methods.isLoading ? 'Signing In...' : 'Sign In',
                            icon: _methods.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.login),
                            onPressed: !_methods.isLoading
                                ? () => _methods.login(
                                      formKey: _formKey,
                                      username: usernameController.text,
                                      password: passwordController.text,
                                    )
                                : null,
                            width: double.infinity,
                            height: 56,
                            backgroundColor: theme.colorScheme.primary,
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
