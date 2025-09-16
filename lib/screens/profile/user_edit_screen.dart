import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/user_model.dart';
// Assuming the provider for the currently logged-in user is here
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/providers/password_reset_provider.dart';
import 'package:labledger/providers/user_provider.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class UserAddEditScreen extends ConsumerStatefulWidget {
  const UserAddEditScreen({super.key, this.targetUserId, this.baseColor});

  final int? targetUserId;
  final Color? baseColor;

  @override
  ConsumerState<UserAddEditScreen> createState() => _UserAddEditScreenState();
}

class _UserAddEditScreenState extends ConsumerState<UserAddEditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _detailsFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Controllers for user details
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Controllers for password
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State variables
  bool get _isEditMode => widget.targetUserId != null;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isDataInitialized = false;

  // Security state variables
  bool _isLocking = false;
  bool _isAdminStatus = false;
  bool _isAccountLocked = false;
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _initializeData(User user) {
    if (!_isDataInitialized) {
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phoneNumber;
      _addressController.text = user.address;
      _isAdminStatus = user.isAdmin;
      _isAccountLocked = user.isLocked;
      _isDataInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the admin status of the user currently logged into the app
    final currentUserIsAdmin =
        ref.watch(currentUserProvider).value?.isAdmin ?? false;

    final effectiveBaseColor =
        widget.baseColor ?? Theme.of(context).colorScheme.secondary;

    final content = _isEditMode
        ? ref
              .watch(singleUserDetailsProvider(widget.targetUserId!))
              .when(
                data: (user) {
                  _initializeData(user);
                  return _buildContent(
                    effectiveBaseColor,
                    currentUserIsAdmin,
                    user: user,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) =>
                    _buildErrorWidget('Failed to load user: $err'),
              )
        : _buildContent(effectiveBaseColor, currentUserIsAdmin);

    return WindowScaffold(child: content);
  }

  Widget _buildContent(Color color, bool currentUserIsAdmin, {User? user}) {
    return Column(
      children: [
        // After
        _buildUserHeaderCard(color, currentUserIsAdmin, user),
        SizedBox(height: defaultHeight),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildLargeScreenLayout(
                  color,
                  currentUserIsAdmin,
                  user: user,
                );
              } else {
                return Column(
                  children: [
                    _buildTabBar(color),
                    SizedBox(height: defaultHeight),
                    Expanded(
                      child: _buildTabContent(
                        color,
                        currentUserIsAdmin,
                        user: user,
                      ),
                    ),
                    SizedBox(height: defaultHeight),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserHeaderCard(
    Color color,
    bool currentUserIsAdmin,
    User? user,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final title = _isEditMode
        ? '${user?.firstName ?? ''} ${user?.lastName ?? ''}'
        : 'New User Profile';
    final subtitle = _isEditMode
        ? user?.email ?? ''
        : 'Enter user details below';
    final initials = _isEditMode
        ? '${user?.firstName.isNotEmpty == true ? user!.firstName[0] : 'U'}${user?.lastName.isNotEmpty == true ? user!.lastName[0] : 'U'}'
        : 'NU';

    final lightThemeColor = Color.lerp(
      color,
      isDark ? Colors.black : Colors.white,
      isDark ? 0.3 : 0.2,
    )!;

    return TintedContainer(
      baseColor: color,
      height: 160,
      radius: defaultRadius,
      intensity: isDark ? 0.15 : 0.08,
      useGradient: true,
      elevationLevel: 2,
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, lightThemeColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: defaultWidth / 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? Colors.white70
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: defaultHeight / 2),
                _buildStatusBadge(
                  _isEditMode ? 'Edit Mode' : 'Create Mode',
                  _isEditMode ? Colors.blue : Colors.green,
                ),
              ],
            ),
          ),
          // ✅ CORRECTED LOGIC: The Column is now always visible.
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _isSaving ? null : () => _handleSave(user),
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(180, 60),
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultRadius),
                  ),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_isEditMode ? Icons.update : Icons.save),
                label: Text(
                  _isSaving
                      ? 'Saving...'
                      : (_isEditMode ? 'Update User' : 'Create User'),
                ),
              ),
              // ✅ The delete button's visibility is the only part that is conditional.
              if (_isEditMode && currentUserIsAdmin) ...[
                SizedBox(height: defaultHeight / 2),
                OutlinedButton.icon(
                  onPressed: _isDeleting ? null : () => _handleDelete(user!),
                  style: OutlinedButton.styleFrom(
                    fixedSize: const Size(180, 60),
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultRadius),
                    ),
                  ),
                  icon: _isDeleting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(Color color) {
    return TabBar(
      controller: _tabController,
      indicator: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      dividerColor: Colors.transparent,
      tabs: const [
        Tab(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, size: 18),
              SizedBox(width: 8),
              Text('Personal Details'),
            ],
          ),
        ),
        Tab(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, size: 18),
              SizedBox(width: 8),
              Text('Security'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(Color color, bool currentUserIsAdmin, {User? user}) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPersonalDetailsCard(color, user),
        _buildSecurityCard(color, currentUserIsAdmin, user),
      ],
    );
  }

  Widget _buildLargeScreenLayout(
    Color color,
    bool currentUserIsAdmin, {
    User? user,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildPersonalDetailsCard(color, user)),
        SizedBox(width: defaultWidth),
        Expanded(child: _buildSecurityCard(color, currentUserIsAdmin, user)),
      ],
    );
  }

  Widget _buildPersonalDetailsCard(Color color, User? user) {
    return TintedContainer(
      baseColor: color,
      height: 450,
      radius: defaultRadius,
      elevationLevel: 1,
      child: Column(
        children: [
          _buildCardHeader('Personal Information', Icons.person_outline, color),
          SizedBox(height: defaultHeight),
          Expanded(
            child: Form(
              key: _detailsFormKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'First Name',
                            controller: _firstNameController,
                            isRequired: true,
                            tintColor: color,
                          ),
                        ),
                        SizedBox(width: defaultWidth / 2),
                        Expanded(
                          child: CustomTextField(
                            label: 'Last Name',
                            controller: _lastNameController,
                            isRequired: true,
                            tintColor: color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Username',
                      controller: _usernameController,
                      isRequired: true,
                      tintColor: color,
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                      tintColor: color,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      tintColor: color,
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Address',
                      controller: _addressController,
                      tintColor: color,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(Color color, bool currentUserIsAdmin, User? user) {
    return TintedContainer(
      baseColor: color,
      height: 450,
      radius: defaultRadius,
      elevationLevel: 1,
      child: Column(
        children: [
          _buildCardHeader('Security Settings', Icons.security, color),
          SizedBox(height: defaultHeight),
          Expanded(
            child: Form(
              key: _passwordFormKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (currentUserIsAdmin) ...[
                      _buildSwitchTile(
                        title: 'Administrator Privileges',
                        subtitle: _isAdminStatus
                            ? 'User has full system access.'
                            : 'User has standard staff access.',
                        value: _isAdminStatus,
                        onChanged: (val) =>
                            setState(() => _isAdminStatus = val),
                        color: color,
                      ),
                      if (_isEditMode) ...[
                        SizedBox(height: defaultHeight / 2),
                        _buildSwitchTile(
                          title: 'Account Locked',
                          subtitle: _isAccountLocked
                              ? 'User cannot log in.'
                              : 'User account is active.',
                          value: _isAccountLocked,
                          isLoading: _isLocking,
                          onChanged: (val) {
                            _handleLockToggle(user!, val);
                          },
                          color: color,
                        ),
                      ],
                      Divider(
                        height: defaultHeight * 2,
                        color: color.withValues(alpha: 0.2),
                      ),
                    ],

                    // --- CURRENT PASSWORD FIELD (NON-ADMINS) ---
                    if (_isEditMode && !currentUserIsAdmin) ...[
                      CustomTextField(
                        label: 'Current Password',
                        controller: _currentPasswordController,
                        obscureText: !_isCurrentPasswordVisible,
                        isRequired: _newPasswordController.text.isNotEmpty,
                        tintColor: color,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isCurrentPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _isCurrentPasswordVisible =
                                !_isCurrentPasswordVisible,
                          ),
                        ),
                        validator: (value) {
                          if (_newPasswordController.text.isNotEmpty &&
                              (value == null || value.isEmpty)) {
                            return 'Current password is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: defaultHeight),
                    ],

                    CustomTextField(
                      label: _isEditMode ? 'New Password' : 'Password',
                      controller: _newPasswordController,
                      obscureText: !_isNewPasswordVisible,
                      isRequired: !_isEditMode,
                      tintColor: color,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isNewPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _isNewPasswordVisible = !_isNewPasswordVisible,
                        ),
                      ),
                      validator: (value) {
                        if (!_isEditMode && (value == null || value.isEmpty)) {
                          return 'Password is required';
                        }
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: _isEditMode
                          ? 'Confirm New Password'
                          : 'Confirm Password',
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      isRequired:
                          !_isEditMode ||
                          _newPasswordController.text.isNotEmpty,
                      tintColor: color,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible,
                        ),
                      ),
                      validator: (value) {
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HANDLERS ---

  Future<void> _handleLockToggle(User user, bool newLockStatus) async {
    setState(() {
      _isLocking = true;
      _isAccountLocked = newLockStatus; // Optimistic UI update
    });

    try {
      await ref.read(
        toggleUserLockStatusProvider((
          userId: user.id,
          isLocked: newLockStatus,
        )).future,
      );

      if (mounted) {
        _showSuccessSnackBar(
          'User account has been ${newLockStatus ? "locked" : "unlocked"}.',
        );
      }
    } catch (e) {
      if (mounted) {
        // On failure, revert the UI change and show an error
        setState(() {
          _isAccountLocked = !newLockStatus;
        });
        _showErrorDialog('Operation Failed', e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocking = false;
        });
      }
    }
  }

  Future<void> _handleSave(User? originalUser) async {
    final detailsValid = _detailsFormKey.currentState!.validate();
    final passwordValid = _passwordFormKey.currentState!.validate();

    if (!detailsValid || !passwordValid) {
      if (!detailsValid) _tabController.animateTo(0);
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_isEditMode) {
        // --- UPDATE LOGIC ---
        final updatedUser = originalUser!.copyWith(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          isAdmin: _isAdminStatus,
        );
        await ref.read(updateUserProvider(updatedUser).future);

        // Separate logic for password update
        if (_newPasswordController.text.trim().isNotEmpty) {
          final currentUserIsAdmin =
              ref.read(currentUserProvider).value?.isAdmin ?? false;
          final Map<String, String> passwordData;

          if (currentUserIsAdmin) {
            passwordData = {'password': _newPasswordController.text.trim()};
          } else {
            passwordData = {
              'old_password': _currentPasswordController.text.trim(),
              'new_password': _newPasswordController.text.trim(),
            };
          }

          final input = PasswordResetInput(
            userId: widget.targetUserId!,
            data: passwordData,
          );
          await ref.read(resetPasswordProvider(input).future);
        }

        _showSuccessSnackBar('User updated successfully!');
      } else {
        // --- CREATE LOGIC ---
        final userData = {
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'password': _newPasswordController.text.trim(),
          'is_admin': _isAdminStatus,
          'is_locked': _isAccountLocked,
        };
        await ref.read(createUserProvider(userData).future);
        _showSuccessSnackBar('User created successfully!');
      }

      // Clear password fields and pop on success
      if (mounted) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Operation Failed', e.toString());
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleDelete(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete ${user.firstName} ${user.lastName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await ref.read(deleteUserProvider(user.id).future);
      _showSuccessSnackBar('User deleted successfully!');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Delete Failed', e.toString());
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  // --- UI HELPERS ---
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (isLoading)
            SizedBox(
              width: 50,
              height: 24,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: color,
                  ),
                ),
              ),
            )
          else
            Switch(value: value, onChanged: onChanged, activeThumbColor: color),
        ],
      ),
    );
  }

  Widget _buildCardHeader(String title, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: defaultWidth / 2),
          Text(title, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Place this method inside your _UserAddEditScreenState class

  void _showErrorDialog(String title, String errorMessage) {
    if (!mounted) return;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        child: TintedContainer(
          baseColor: theme.colorScheme.error,
          intensity: 0.05,
          child: Padding(
            padding: EdgeInsets.all(defaultPadding * 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 32,
                  ),
                ),
                SizedBox(height: defaultHeight),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: defaultHeight / 2),
                Container(
                  padding: EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    // We still clean the message here for robustness
                    errorMessage.replaceAll('Exception: ', ''),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: defaultHeight),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          widget
                              .baseColor ?? // Using baseColor from this screen
                          Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: defaultHeight),
            Text('Error Loading User', style: TextStyle(fontSize: 20)),
            SizedBox(height: defaultHeight / 2),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: defaultHeight),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.targetUserId != null) {
                  ref.invalidate(
                    singleUserDetailsProvider(widget.targetUserId!),
                  );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
