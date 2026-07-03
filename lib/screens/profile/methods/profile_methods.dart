import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/user_model.dart';
import 'package:labledger/providers/user_provider.dart';
import 'package:labledger/providers/password_reset_provider.dart';
import 'package:labledger/screens/ui_components/custom_confirmation_dialog.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';
import 'package:labledger/screens/ui_components/custom_error_dialog.dart';

class ProfileMethods extends ChangeNotifier {
  final BuildContext context;
  final WidgetRef ref;

  // Form Keys
  final detailsFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  // Controllers for user details
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  // Controllers for password
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State variables
  bool isSaving = false;
  bool isDeleting = false;
  bool isDataInitialized = false;

  // Security state variables
  bool isLocking = false;
  bool isAdminStatus = false;
  bool isAccountLocked = false;
  bool isCurrentPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  ProfileMethods(this.context, this.ref);

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void initializeData(User user) {
    if (!isDataInitialized) {
      usernameController.text = user.username;
      emailController.text = user.email;
      firstNameController.text = user.firstName;
      lastNameController.text = user.lastName;
      phoneController.text = user.phoneNumber;
      addressController.text = user.address;
      isAdminStatus = user.isAdmin;
      isAccountLocked = user.isLocked;
      isDataInitialized = true;
      // notifyListeners is typically not called during build if this is called directly in build,
      // but since we are modifying state, let's defer it.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void toggleAdminStatus(bool val) {
    isAdminStatus = val;
    notifyListeners();
  }

  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible = !isCurrentPasswordVisible;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible = !isNewPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    notifyListeners();
  }

  void showErrorDialog(String title, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        errorMessage: errorMessage,
      ),
    );
  }

  Future<void> handleLockToggle(User user, bool newLockStatus) async {
    isLocking = true;
    isAccountLocked = newLockStatus; // Optimistic UI update
    notifyListeners();

    try {
      await ref.read(
        toggleUserLockStatusProvider((
          userId: user.id,
          isLocked: newLockStatus,
        )).future,
      );

      if (context.mounted) {
        showSuccessSnackBar(
          context,
          'User account has been ${newLockStatus ? "locked" : "unlocked"}.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        isAccountLocked = !newLockStatus; // revert
        showErrorDialog('Operation Failed', e.toString());
      }
    } finally {
      isLocking = false;
      notifyListeners();
    }
  }

  Future<bool> handleSave(User? originalUser, bool isEditMode, bool currentUserIsAdmin, int? targetUserId) async {
    final detailsValid = detailsFormKey.currentState!.validate();
    final passwordValid = passwordFormKey.currentState!.validate();

    if (!detailsValid || !passwordValid) {
      return false; // Tells UI to focus first tab if details are invalid
    }

    isSaving = true;
    notifyListeners();

    try {
      if (isEditMode) {
        // --- UPDATE LOGIC ---
        final updatedUser = originalUser!.copyWith(
          username: usernameController.text.trim(),
          email: emailController.text.trim(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          address: addressController.text.trim(),
          isAdmin: isAdminStatus,
        );
        await ref.read(updateUserProvider(updatedUser).future);

        // Separate logic for password update
        if (newPasswordController.text.trim().isNotEmpty) {
          final Map<String, String> passwordData;

          if (currentUserIsAdmin) {
            passwordData = {'password': newPasswordController.text.trim()};
          } else {
            passwordData = {
              'old_password': currentPasswordController.text.trim(),
              'new_password': newPasswordController.text.trim(),
            };
          }

          final input = PasswordResetInput(
            userId: targetUserId!,
            data: passwordData,
          );
          await ref.read(resetPasswordProvider(input).future);
        }

        if (context.mounted) {
          showSuccessSnackBar(context, 'User updated successfully!');
        }
      } else {
        // --- CREATE LOGIC ---
        final userData = {
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'first_name': firstNameController.text.trim(),
          'last_name': lastNameController.text.trim(),
          'phone_number': phoneController.text.trim(),
          'address': addressController.text.trim(),
          'password': newPasswordController.text.trim(),
          'is_admin': isAdminStatus,
          'is_locked': isAccountLocked,
        };
        await ref.read(createUserProvider(userData).future);
        if (context.mounted) {
          showSuccessSnackBar(context, 'User created successfully!');
        }
      }

      // Clear password fields and pop on success
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        showErrorDialog('Operation Failed', e.toString());
      }
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> handleDelete(User user) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: 'Confirm Deletion',
      message:
          'Are you sure you want to delete ${user.firstName} ${user.lastName}? This action cannot be undone.',
      showWarningIcon: false,
    );

    if (!confirmed) return;

    isDeleting = true;
    notifyListeners();

    try {
      await ref.read(deleteUserProvider(user.id).future);
      if (context.mounted) {
        showSuccessSnackBar(context, 'User deleted successfully!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (context.mounted) {
        showErrorDialog('Delete Failed', e.toString());
      }
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }
}
