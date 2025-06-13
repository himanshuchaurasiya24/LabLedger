import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/custom_models.dart';
import 'package:labledger/providers/custom_providers.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  final User user;

  const UpdateProfileScreen({super.key, required this.user});

  @override
  ConsumerState<UpdateProfileScreen> createState() =>
      _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends ConsumerState<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  late final TextEditingController centerNameController;
  late final TextEditingController centerAddressController;
  late final TextEditingController ownerNameController;
  late final TextEditingController ownerPhoneController;
  Future<bool> updateUserData(User user, WidgetRef ref) async {
    try {
      final result = await ref.read(updateUserProvider(user).future);
      return result;
    } catch (e) {
      debugPrint("Update failed: $e");
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    final user = widget.user;

    firstNameController = TextEditingController(text: user.firstName);
    lastNameController = TextEditingController(text: user.lastName);
    emailController = TextEditingController(text: user.email);
    phoneController = TextEditingController(text: user.phoneNumber);
    addressController = TextEditingController(text: user.address);

    centerNameController = TextEditingController(
      text: user.centerDetail.centerName,
    );
    centerAddressController = TextEditingController(
      text: user.centerDetail.address,
    );
    ownerNameController = TextEditingController(
      text: user.centerDetail.ownerName,
    );
    ownerPhoneController = TextEditingController(
      text: user.centerDetail.ownerPhone,
    );
  }

  @override
  void dispose() {
    for (final controller in [
      firstNameController,
      lastNameController,
      emailController,
      phoneController,
      addressController,
      centerNameController,
      centerAddressController,
      ownerNameController,
      ownerPhoneController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedUser = widget.user.copyWith(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        address: addressController.text.trim(),
        centerDetail: widget.user.centerDetail.copyWith(
          centerName: centerNameController.text.trim(),
          address: centerAddressController.text.trim(),
          ownerName: ownerNameController.text.trim(),
          ownerPhone: ownerPhoneController.text.trim(),
        ),
      );

      final success = await updateUserData(updatedUser, ref);
      if (!mounted) {
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Profile updated successfully!'
                  : 'Failed to update profile.',
            ),
          ),
        );

        if (success) Navigator.pop(context, updatedUser);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField("First Name", firstNameController),
              _buildField("Last Name", lastNameController),
              _buildField(
                "Email",
                emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildField(
                "Phone",
                phoneController,
                keyboardType: TextInputType.phone,
              ),
              _buildField("Address", addressController),
              const Divider(height: 32),
              _buildField("Center Name", centerNameController),
              _buildField("Center Address", centerAddressController),
              _buildField("Owner Name", ownerNameController),
              _buildField(
                "Owner Phone",
                ownerPhoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => (value == null || value.trim().isEmpty)
            ? 'Please enter $label'
            : null,
      ),
    );
  }
}
