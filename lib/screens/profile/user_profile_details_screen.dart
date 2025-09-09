
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/user_model.dart';
import 'package:labledger/providers/password_reset_provider.dart';
import 'package:labledger/providers/user_provider.dart';
import 'package:labledger/screens/profile/edit_profile_screen.dart';
// --- UI CODE ---

class UserProfileDetailsScreen extends ConsumerWidget {
  final int userId;
  final int loggedInUserId;

  const UserProfileDetailsScreen({
    super.key, 
    required this.userId,
    required this.loggedInUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch both the profile user's details and the logged-in user's details
    final userDetailsAsync = ref.watch(singleUserDetailsProvider(userId));
    final loggedInUserAsync = ref.watch(singleUserDetailsProvider(loggedInUserId));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // Add a refresh button to manually refetch data
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(singleUserDetailsProvider(userId));
              ref.invalidate(singleUserDetailsProvider(loggedInUserId));
            },
          )
        ],
      ),
      // We must wait for the logged-in user's details first to determine permissions
      body: loggedInUserAsync.when(
        data: (loggedInUser) {
          // Once we have the logged-in user, we can safely build the rest of the UI
          return userDetailsAsync.when(
            data: (user) {
              final canEdit = loggedInUser.isAdmin || loggedInUser.id == userId;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(context, user),
                        const SizedBox(height: 24),
                        _buildDetailsCard(context, user),
                        if (canEdit) ...[
                          const SizedBox(height: 24),
                          _buildActions(context, ref, user, loggedInUser),
                        ]
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading profile: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Could not verify user: $err')),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user) {
    String initials = (user.firstName.isNotEmpty ? user.firstName[0] : '') +
                      (user.lastName.isNotEmpty ? user.lastName[0] : '');
                      
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: const Color(0xFF00ACC1),
          child: Text(
            initials.toUpperCase(),
            style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${user.firstName} ${user.lastName}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
             if (user.isAdmin) ...[
              const SizedBox(height: 8),
              Chip(
                label: const Text('Administrator'),
                backgroundColor: const Color(0xFF00ACC1).withOpacity(0.1),
                labelStyle: const TextStyle(color: Color(0xFF00838F), fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ]
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsCard(BuildContext context, User user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              "User Details",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildDetailRow(Icons.person_outline, "Username", user.username),
            _buildDetailRow(Icons.phone_outlined, "Phone Number", user.phoneNumber),
            _buildDetailRow(Icons.location_on_outlined, "Address", user.address),
                _buildDetailRow(Icons.business_outlined, "Diagnostic Center", user.centerDetail.centerName),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, User user, User loggedInUser) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.lock_reset),
          label: const Text('Reset Password'),
          onPressed: () => _showResetPasswordDialog(context, ref, user, loggedInUser),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blueGrey,
            side: const BorderSide(color: Colors.blueGrey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit Profile'),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => EditProfileScreen(user: user, loggedInUser: loggedInUser),
            ));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00ACC1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  void _showResetPasswordDialog(BuildContext context, WidgetRef ref, User userToReset, User loggedInUser) {
    final formKey = GlobalKey<FormState>();
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    
    final bool isAdminResetting = loggedInUser.isAdmin;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isAdminResetting ? 'Reset Password for ${userToReset.firstName}' : 'Change Your Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isAdminResetting)
                  TextFormField(
                    controller: oldPasswordController,
                    decoration: const InputDecoration(labelText: 'Old Password'),
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? 'Cannot be empty' : null,
                  ),
                TextFormField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Cannot be empty';
                    if (value.length < 8) return 'Must be at least 8 characters';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                    final data = isAdminResetting
                        ? {'password': newPasswordController.text}
                        : {'old_password': oldPasswordController.text, 'new_password': newPasswordController.text};
                    
                    final input = PasswordResetInput(userId: userToReset.id, data: data);

                    try {
                        await ref.read(resetPasswordProvider(input).future);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password updated successfully!'), backgroundColor: Colors.green),
                        );
                    } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                    }
                }
              },
              child: const Text('Submit'),
            )
          ],
        );
      },
    );
  }
}
