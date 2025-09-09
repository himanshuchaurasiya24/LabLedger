import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/user_model.dart';
import 'package:labledger/providers/password_reset_provider.dart';
import 'package:labledger/providers/user_provider.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class UserEditScreen extends ConsumerStatefulWidget {
  final int currentUserId; // The logged-in user's ID
  final int? targetUserId; // The user ID to edit (null means editing self)

  const UserEditScreen({
    super.key,
    required this.currentUserId,
    this.targetUserId,
  });

  @override
  ConsumerState<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends ConsumerState<UserEditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Form controllers for user details
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Password form controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isUpdating = false;
  bool _isResettingPassword = false;
  bool _isControllersInitialized = false;

  int get targetUserId => widget.targetUserId ?? widget.currentUserId;
  bool get isEditingSelf =>
      widget.targetUserId == null ||
      widget.targetUserId == widget.currentUserId;

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

  void _initializeControllersWithUserData(User user) {
    if (!_isControllersInitialized) {
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phoneNumber;
      _addressController.text = user.address;
      _isControllersInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch both current user and target user data
    final currentUserAsync = ref.watch(
      singleUserDetailsProvider(widget.currentUserId),
    );
    final targetUserAsync = ref.watch(singleUserDetailsProvider(targetUserId));

    return WindowScaffold(
      child: currentUserAsync.when(
        data: (currentUser) => targetUserAsync.when(
          data: (targetUser) {
            _initializeControllersWithUserData(targetUser);
            return _buildContent(currentUser, targetUser);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              _buildErrorWidget('Failed to load target user: $error'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            _buildErrorWidget('Failed to load current user: $error'),
      ),
    );
  }

  Widget _buildContent(User currentUser, User targetUser) {
    final bool isAdmin = currentUser.isAdmin;

    return Column(
      children: [
        _buildUserHeader(targetUser),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUserDetailsTab(targetUser),
              _buildPasswordTab(isAdmin),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.red.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Refresh the data
              ref.invalidate(singleUserDetailsProvider(widget.currentUserId));
              ref.invalidate(singleUserDetailsProvider(targetUserId));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(User user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),

      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF20B2AA),
            child: Text(
              '${user.firstName[0]}${user.lastName[0]}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: user.isAdmin
                        ? Colors.orange.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.isAdmin ? 'Admin' : 'Staff',
                    style: TextStyle(
                      fontSize: 12,
                      color: user.isAdmin
                          ? Colors.orange.shade800
                          : Colors.green.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'User Details'),
          Tab(text: 'Password'),
        ],
        labelColor: const Color(0xFF20B2AA),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF20B2AA),
      ),
    );
  }

  Widget _buildUserDetailsTab(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionCard(
              title: 'Personal Information',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'First Name',
                        _firstNameController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField('Last Name', _lastNameController),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField('Username', _usernameController),
                const SizedBox(height: 16),
                _buildTextField(
                  'Email',
                  _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Phone Number',
                  _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField('Address', _addressController, maxLines: 3),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionCard(
              title: 'Center Information',
              children: [
                _buildInfoTile('Center Name', user.centerDetail.centerName),
                _buildInfoTile('Center Address', user.centerDetail.address),
                _buildInfoTile('Owner Name', user.centerDetail.ownerName),
                _buildInfoTile('Owner Phone', user.centerDetail.ownerPhone),
                _buildInfoTile(
                  'Plan Type',
                  user.centerDetail.subscription.planType,
                ),
                _buildInfoTile(
                  'Days Left',
                  user.centerDetail.subscription.daysLeft.toString(),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.centerDetail.subscription.isActive
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.centerDetail.subscription.isActive
                        ? 'Active'
                        : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      color: user.centerDetail.subscription.isActive
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isUpdating ? null : () => _updateUserDetails(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF20B2AA),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isUpdating
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
                    : const Text(
                        'Update Details',
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
    );
  }

  Widget _buildPasswordTab(bool isAdmin) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionCard(
              title: isAdmin && !isEditingSelf
                  ? 'Reset User Password'
                  : 'Change Password',
              children: [
                if (isEditingSelf) ...[
                  _buildPasswordField(
                    'Current Password',
                    _currentPasswordController,
                    _isPasswordVisible,
                    () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildPasswordField(
                  isAdmin && !isEditingSelf ? 'New Password' : 'New Password',
                  _newPasswordController,
                  _isNewPasswordVisible,
                  () => setState(
                    () => _isNewPasswordVisible = !_isNewPasswordVisible,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  'Confirm Password',
                  _confirmPasswordController,
                  _isConfirmPasswordVisible,
                  () => setState(
                    () =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
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
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isResettingPassword
                    ? null
                    : () => _resetPassword(isAdmin),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isResettingPassword
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
                    : Text(
                        isAdmin && !isEditingSelf
                            ? 'Reset Password'
                            : 'Change Password',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return TintedContainer(
      height: 369,
      baseColor: Theme.of(context).colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return CustomTextField(
      label: label,
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        if (label == 'Email' &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isVisible,
    VoidCallback onToggleVisibility, {
    String? Function(String?)? validator,
  }) {
    return CustomTextField(
      label: label,
      controller: controller,
      obscureText: !isVisible,

      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label is required';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Updated UI methods for UserEditScreen

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
          const SnackBar(
            content: Text('User details updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        // Show detailed error in a dialog for better readability
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
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isResettingPassword = true);

    try {
      final Map<String, String> passwordData;

      if (isAdmin) {
        // Admin resetting another user's password - only needs 'password'
        passwordData = {'password': _newPasswordController.text.trim()};
      } else {
        // User changing their own password - needs 'old_password' and 'new_password'
        passwordData = {
          'old_password': _currentPasswordController.text.trim(),
          'new_password': _newPasswordController.text.trim(),
        };
      }

      final input = PasswordResetInput(
        userId: targetUserId,
        data: passwordData,
      );

      await ref.read(resetPasswordProvider(input).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Clear password fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        // Show detailed error in a dialog for better readability
        _showErrorDialog(
          'Password Update Failed',
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isResettingPassword = false);
    }
  }

  // Helper method to show detailed error dialogs
  void _showErrorDialog(String title, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: Colors.red.shade600)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The following error occurred:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  errorMessage,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.red.shade800,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Alternative: Show error in a bottom sheet for even better UX
  // void _showErrorBottomSheet(String title, String errorMessage) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder:sage) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (context) => Container(
  //       padding: const EdgeInsets.all(24),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(Icons.error_outline, color: Colors.red.shade600, size: 28),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: Text(
  //                   title,
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.red.shade600,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           const Text(
  //             'Error Details:',
  //             style: TextStyle(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.black87,
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           Container(
  //             width: double.infinity,
  //             padding: const EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color: Colors.red.shade50,
  //               borderRadius: BorderRadius.circular(12),
  //               border: Border.all(color: Colors.red.shade200),
  //             ),
  //             child: Text(
  //               errorMessage,
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 color: Colors.red.shade800,
  //                 height: 1.5,
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 24),
  //           SizedBox(
  //             width: double.infinity,
  //             height: 48,
  //             child: ElevatedButton(
  //               onPressed: () => Navigator.pop(context),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: const Color(0xFF20B2AA),
  //                 foregroundColor: Colors.white,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //               ),
  //               child: const Text('Got it', style: TextStyle(fontSize: 16)),
  //             ),
  //           ),
  //           // Add padding for bottom safe area
  //           SizedBox(height: MediaQuery.of(context).padding.bottom),
  //         ],
  //       ),
  //     ),
  //   );
  // } (context) => Container(
  //       padding: const EdgeInsets.all(24),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(Icons.error_outline, color: Colors.red.shade600, size: 28),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: Text(
  //                   title,
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.red.shade600,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           const Text(
  //             'Error Details:',
  //             style: TextStyle(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.black87,
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           Container(
  //             width: double.infinity,
  //             padding: const EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color: Colors.red.shade50,
  //               borderRadius: BorderRadius.circular(12),
  //               border: Border.all(color: Colors.red.shade200),
  //             ),
  //             child: Text(
  //               errorMessage,
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 color: Colors.red.shade800,
  //                 height: 1.5,
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 24),
  //           SizedBox(
  //             width: double.infinity,
  //             height: 48,
  //             child: ElevatedButton(
  //               onPressed: () => Navigator.pop(context),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: const Color(0xFF20B2AA),
  //                 foregroundColor: Colors.white,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //               ),
  //               child: const Text('Got it', style: TextStyle(fontSize: 16)),
  //             ),
  //           ),
  //           // Add padding for bottom safe area
  //           SizedBox(height: MediaQuery.of(context).padding.bottom),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showDeleteDialog() {
    final targetUserAsync = ref.read(singleUserDetailsProvider(targetUserId));

    targetUserAsync.when(
      data: (targetUser) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete User'),
            content: Text(
              'Are you sure you want to delete ${targetUser.firstName} ${targetUser.lastName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteUser();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      loading: () {},
      error: (_, _) {},
    );
  }

  Future<void> _deleteUser() async {
    try {
      await ref.read(deleteUserProvider(targetUserId).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
