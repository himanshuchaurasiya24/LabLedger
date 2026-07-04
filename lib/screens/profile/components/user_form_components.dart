import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/user_model.dart';
import 'package:labledger/screens/profile/methods/profile_methods.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class UserPersonalDetailsCard extends StatelessWidget {
  final ProfileMethods methods;
  final Color color;

  const UserPersonalDetailsCard({
    super.key,
    required this.methods,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TintedContainer(
      baseColor: color,
      height: 450,
      radius: defaultRadius,
      elevationLevel: 1,
      child: Column(
        children: [
          _buildCardHeader('Personal Information', Icons.person_outline, color, context),
          SizedBox(height: defaultHeight),
          Expanded(
            child: Form(
              key: methods.detailsFormKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'First Name',
                            controller: methods.firstNameController,
                            isRequired: true,
                            tintColor: color,
                          ),
                        ),
                        SizedBox(width: defaultWidth / 2),
                        Expanded(
                          child: CustomTextField(
                            label: 'Last Name',
                            controller: methods.lastNameController,
                            isRequired: true,
                            tintColor: color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Username',
                      controller: methods.usernameController,
                      isRequired: true,
                      tintColor: color,
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Email Address',
                      controller: methods.emailController,
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
                      controller: methods.phoneController,
                      keyboardType: TextInputType.phone,
                      tintColor: color,
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Address',
                      controller: methods.addressController,
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

  Widget _buildCardHeader(String title, IconData icon, Color color, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(mediumPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(mediumRadius),
          topRight: Radius.circular(mediumRadius),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(smallRadius),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: defaultWidth / 2),
          Text(title, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class UserSecurityCard extends StatelessWidget {
  final ProfileMethods methods;
  final Color color;
  final bool currentUserIsAdmin;
  final bool isEditMode;
  final User? user;

  const UserSecurityCard({
    super.key,
    required this.methods,
    required this.color,
    required this.currentUserIsAdmin,
    required this.isEditMode,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return TintedContainer(
      baseColor: color,
      height: 450,
      radius: defaultRadius,
      elevationLevel: 1,
      child: Column(
        children: [
          _buildCardHeader('Security Settings', Icons.security, color, context),
          SizedBox(height: defaultHeight),
          Expanded(
            child: Form(
              key: methods.passwordFormKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (currentUserIsAdmin) ...[
                      _buildSwitchTile(
                        context: context,
                        title: 'Administrator Privileges',
                        subtitle: methods.isAdminStatus
                            ? 'User has full system access.'
                            : 'User has standard staff access.',
                        value: methods.isAdminStatus,
                        onChanged: (val) => methods.toggleAdminStatus(val),
                        color: color,
                      ),
                      if (isEditMode) ...[
                        SizedBox(height: defaultHeight / 2),
                        _buildSwitchTile(
                          context: context,
                          title: 'Account Locked',
                          subtitle: methods.isAccountLocked
                              ? 'User cannot log in.'
                              : 'User account is active.',
                          value: methods.isAccountLocked,
                          isLoading: methods.isLocking,
                          onChanged: (val) {
                            methods.handleLockToggle(user!, val);
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
                    if (isEditMode && !currentUserIsAdmin) ...[
                      CustomTextField(
                        label: 'Current Password',
                        controller: methods.currentPasswordController,
                        obscureText: !methods.isCurrentPasswordVisible,
                        isRequired: methods.newPasswordController.text.isNotEmpty,
                        tintColor: color,
                        suffixIcon: IconButton(
                          icon: Icon(
                            methods.isCurrentPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: methods.toggleCurrentPasswordVisibility,
                        ),
                        validator: (value) {
                          if (methods.newPasswordController.text.isNotEmpty &&
                              (value == null || value.isEmpty)) {
                            return 'Current password is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: defaultHeight),
                    ],

                    CustomTextField(
                      label: isEditMode ? 'New Password' : 'Password',
                      controller: methods.newPasswordController,
                      obscureText: !methods.isNewPasswordVisible,
                      isRequired: !isEditMode,
                      tintColor: color,
                      suffixIcon: IconButton(
                        icon: Icon(
                          methods.isNewPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: methods.toggleNewPasswordVisibility,
                      ),
                      validator: (value) {
                        if (!isEditMode && (value == null || value.isEmpty)) {
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
                      label: isEditMode
                          ? 'Confirm New Password'
                          : 'Confirm Password',
                      controller: methods.confirmPasswordController,
                      obscureText: !methods.isConfirmPasswordVisible,
                      isRequired:
                          !isEditMode ||
                          methods.newPasswordController.text.isNotEmpty,
                      tintColor: color,
                      suffixIcon: IconButton(
                        icon: Icon(
                          methods.isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: methods.toggleConfirmPasswordVisibility,
                      ),
                      validator: (value) {
                        if (value != methods.newPasswordController.text) {
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

  Widget _buildCardHeader(String title, IconData icon, Color color, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(mediumPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(mediumRadius),
          topRight: Radius.circular(mediumRadius),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(smallRadius),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: defaultWidth / 2),
          Text(title, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: smallPadding),
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
}
