import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/user_model.dart';
import 'package:labledger/providers/password_reset_provider.dart';
import 'package:labledger/providers/user_provider.dart'; // Make sure this imports your updated providers file
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class UserEditScreen extends ConsumerStatefulWidget {
  const UserEditScreen({
    super.key,
    this.isAdmin = false,
    required this.targetUserId,
    required this.themeColor,
  });
  final int targetUserId;
  final bool? isAdmin;
  final Color themeColor;

  @override
  ConsumerState<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends ConsumerState<UserEditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Form controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Password controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isUpdating = false;
  bool _isResettingPassword = false;
  bool _isDataInitialized = false;

  // State variables for Account Lock
  bool _isLocking = false;
  late bool _isAccountLocked;

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

  void _initializeDataWithUserData(User user) {
    if (!_isDataInitialized) {
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phoneNumber;
      _addressController.text = user.address;
      _isAccountLocked = user.isLocked;
      _isDataInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetUserAsync = ref.watch(
      singleUserDetailsProvider(widget.targetUserId),
    );

    return WindowScaffold(
      child: targetUserAsync.when(
        data: (targetUser) {
          _initializeDataWithUserData(targetUser);
          return _buildContent(targetUser, widget.isAdmin!);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            _buildErrorWidget('Failed to load target user: $error'),
      ),
    );
  }

  Widget _buildContent(User targetUser, bool isAdmin) {
    return Column(
      children: [
        _buildUserHeaderCard(targetUser, isAdmin),
        const SizedBox(height: 24),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildLargeScreenLayout(targetUser, isAdmin);
              } else {
                return Column(
                  children: [
                    _buildTabBar(),
                    Expanded(child: _buildTabContent(targetUser, isAdmin)),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserHeaderCard(User user, bool isAdmin) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final lightThemeColor = Color.lerp(
      widget.themeColor,
      isDark ? Colors.black : Colors.white,
      isDark ? 0.3 : 0.2,
    )!;

    return TintedContainer(
      baseColor: widget.themeColor,
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
                colors: [widget.themeColor, lightThemeColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.themeColor.withValues(alpha:  0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${user.firstName.isNotEmpty ? user.firstName[0] : 'U'}${user.lastName.isNotEmpty ? user.lastName[0] : 'U'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? Colors.white70
                        : theme.colorScheme.onSurface.withValues(alpha:  0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusBadge(
                      user.isAdmin ? 'Admin' : 'Staff',
                      user.isAdmin ? Colors.orange : widget.themeColor,
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 8),
                      _buildStatusBadge('Edit Mode', Colors.purple),
                    ],
                    if (_isAccountLocked) ...[
                      const SizedBox(width: 8),
                      _buildStatusBadge('Locked', theme.colorScheme.error),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (widget.themeColor).withValues(alpha:  0.1),
              borderRadius: BorderRadius.circular(defaultRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.business, color: widget.themeColor, size: 20),
                const SizedBox(height: 4),
                Text(
                  'Center',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? Colors.white70
                        : theme.colorScheme.onSurface.withValues(alpha:  0.7),
                  ),
                ),
                Text(
                  user.centerDetail.centerName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockStatusToggle(User user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha:  isDark ? 0.1 : 0.5),
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(
          color: widget.themeColor.withValues(alpha:  isDark ? 0.2 : 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Lock',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isAccountLocked
                      ? 'Account is locked. User cannot log in.'
                      : 'Account is active.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha:  0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (_isLocking)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: widget.themeColor,
              ),
            )
          else
            Switch(
              value: _isAccountLocked,
              onChanged: (value) => _toggleLockStatus(user),
              activeThumbColor: theme.colorScheme.error,
              inactiveTrackColor: Colors.green.withValues(alpha:  0.5),
              activeTrackColor: theme.colorScheme.error.withValues(alpha:  0.5),
            ),
        ],
      ),
    );
  }

  // --- [THIS IS THE KEY METHOD] ---
  // It now calls the new, dedicated provider to handle the lock/unlock action.
  Future<void> _toggleLockStatus(User user) async {
    final bool newLockStatus = !_isAccountLocked;

    setState(() {
      _isLocking = true;
      _isAccountLocked = newLockStatus; // Optimistic UI update
    });

    try {
      // Call the new, dedicated provider for this action
      await ref.read(
        toggleUserLockStatusProvider((
          userId: user.id,
          isLocked: newLockStatus,
        )).future,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  newLockStatus ? Icons.lock : Icons.lock_open,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'User account has been ${newLockStatus ? "locked" : "unlocked"}.',
                ),
              ],
            ),
            backgroundColor: newLockStatus
                ? Theme.of(context).colorScheme.error
                : Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // On failure, revert the UI change and show an error
        setState(() {
          _isAccountLocked = !newLockStatus;
        });
        _showErrorDialog(
          'Operation Failed',
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocking = false;
        });
      }
    }
  }

  // Other methods (_updateUserDetails, _resetPassword, etc.) remain unchanged
  // --- (No changes to the rest of the file) ---

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:  0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:  0.5)),
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

  Widget _buildTabBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  isDark ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: widget.themeColor,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: isDark
            ? Colors.white70
            : theme.colorScheme.onSurface.withValues(alpha:  0.7),
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
      ),
    );
  }

  Widget _buildTabContent(User targetUser, bool isAdmin) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPersonalDetailsCard(targetUser),
        _buildSecurityCard(targetUser, isAdmin),
      ],
    );
  }

  Widget _buildLargeScreenLayout(User targetUser, bool isAdmin) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildPersonalDetailsCard(targetUser)),
        const SizedBox(width: 24),
        Expanded(child: _buildSecurityCard(targetUser, isAdmin)),
      ],
    );
  }

  Widget _buildPersonalDetailsCard(User user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TintedContainer(
      baseColor: widget.themeColor,
      height: 520,
      radius: defaultRadius,
      intensity: isDark ? 0.1 : 0.05,
      elevationLevel: 1,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.themeColor.withValues(alpha:  isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(defaultRadius),
                topRight: Radius.circular(defaultRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.themeColor.withValues(alpha:  0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.person, color: widget.themeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Personal Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: defaultHeight * 2),
          Expanded(
            child: Form(
              key: _formKey,
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
                            tintColor: widget.themeColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            label: 'Last Name',
                            controller: _lastNameController,
                            isRequired: true,
                            tintColor: widget.themeColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: defaultHeight * 2),
                    CustomTextField(
                      label: 'Username',
                      controller: _usernameController,
                      isRequired: true,
                      tintColor: widget.themeColor,
                    ),
                    SizedBox(height: defaultHeight * 2),
                    CustomTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                      tintColor: widget.themeColor,
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
                    SizedBox(height: defaultHeight * 2),
                    CustomTextField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      tintColor: widget.themeColor,
                    ),
                    SizedBox(height: defaultHeight * 2),
                    CustomTextField(
                      label: 'Address',
                      controller: _addressController,
                      tintColor: widget.themeColor,
                    ),
                    SizedBox(height: defaultHeight * 2),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isUpdating
                            ? null
                            : () => _updateUserDetails(user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.themeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(defaultRadius),
                          ),
                          elevation: 2,
                        ),
                        icon: _isUpdating
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
                            : const Icon(Icons.save),
                        label: Text(
                          _isUpdating ? 'Updating...' : 'Update Profile',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(height: defaultHeight*1.6),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(User targetUser, bool isAdmin) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TintedContainer(
      baseColor: widget.themeColor,
      radius: defaultRadius,
      intensity: isDark ? 0.1 : 0.05,
      height: isAdmin ? 520 : 395,
      elevationLevel: 1,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.themeColor.withValues(alpha:  isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(defaultRadius),
                topRight: Radius.circular(defaultRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.themeColor.withValues(alpha:  0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.security,
                    color: widget.themeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Security Settings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Form(
              key: _passwordFormKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (isAdmin) ...[
                      _buildLockStatusToggle(targetUser),
                      SizedBox(height: defaultHeight * 2),
                      Divider(color: widget.themeColor.withValues(alpha:  0.2)),
                      SizedBox(height: defaultHeight * 2),
                    ],
                    if (!isAdmin) ...[
                      CustomTextField(
                        label: 'Current Password',
                        controller: _currentPasswordController,
                        obscureText: !_isPasswordVisible,
                        isRequired: true,
                        tintColor: widget.themeColor,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                        ),
                      ),
                      SizedBox(height: defaultHeight * 2),
                    ],
                    CustomTextField(
                      label: 'New Password',
                      controller: _newPasswordController,
                      obscureText: !_isNewPasswordVisible,
                      isRequired: false, // Not required for lock/unlock
                      tintColor: widget.themeColor,
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
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: defaultHeight * 2),
                    CustomTextField(
                      label: 'Confirm New Password',
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      isRequired: false, // Not required for lock/unlock
                      tintColor: widget.themeColor,
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isResettingPassword
                            ? null
                            : () => _resetPassword(isAdmin),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.themeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(defaultRadius),
                          ),
                          elevation: 2,
                        ),
                        icon: _isResettingPassword
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
                            : const Icon(Icons.lock_reset),
                        label: Text(
                          _isResettingPassword
                              ? 'Updating...'
                              : 'Update Password',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: defaultHeight * 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserDetails(User originalUser) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isUpdating = true);
    try {
      final updatedUser = originalUser.copyWith(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );
      await ref.read(updateUserProvider(updatedUser).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Update Failed',
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _resetPassword(bool isAdmin) async {
    if (_newPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'New password field cannot be empty to update password.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() => _isResettingPassword = true);
    try {
      final Map<String, String> passwordData;
      if (isAdmin) {
        passwordData = {'password': _newPasswordController.text.trim()};
      } else {
        passwordData = {
          'old_password': _currentPasswordController.text.trim(),
          'new_password': _newPasswordController.text.trim(),
        };
      }
      final input = PasswordResetInput(
        userId: widget.targetUserId,
        data: passwordData,
      );
      await ref.read(resetPasswordProvider(input).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Password updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Password Update Failed',
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isResettingPassword = false);
    }
  }

  void _showErrorDialog(String title, String errorMessage) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: TintedContainer(
          baseColor: theme.colorScheme.error,
          intensity: 0.05,
          disablePadding: true,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha:  0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 32,
                  ),
                ),
                SizedBox(height: defaultHeight * 2),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha:  0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha:  0.2),
                    ),
                  ),
                  child: Text(
                    errorMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: TintedContainer(
          baseColor: theme.colorScheme.error,
          intensity: isDark ? 0.2 : 0.1,
          elevationLevel: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              SizedBox(height: defaultHeight * 2),
              Text(
                'Error Loading User',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(
                    singleUserDetailsProvider(widget.targetUserId),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
