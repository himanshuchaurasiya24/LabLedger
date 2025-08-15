import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/user_model.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/home/add_bill_screen.dart';
import 'package:labledger/screens/home/home_screen.dart';
import 'package:labledger/screens/home/home_screen_logic.dart';

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
  late final TextEditingController usernameController;
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
    usernameController = TextEditingController(text: user.username);
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
      usernameController,
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
        id: widget.user.id,
        username: usernameController.text.toLowerCase(),
        email: emailController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        address: addressController.text.trim(),
        isAdmin: widget.user.isAdmin,
        centerDetail: widget.user.centerDetail,
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

        if (success) {
          ref.invalidate(
            userDetailsProvider(widget.user.id),
          ); // <--- Add this line

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return HomeScreen(
                  id: widget.user.id,
                  firstName: updatedUser.firstName,
                  lastName: updatedUser.lastName,
                  username: updatedUser.username,
                  isAdmin: updatedUser.isAdmin,
                  centerDetail: updatedUser.centerDetail,
                );
              },
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 0.5,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryFixed,
            borderRadius: BorderRadius.circular(defaultPadding / 2),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: defaultPadding / 2,
              right: defaultPadding / 2,
              bottom: defaultPadding / 2,
            ),
            child: Form(
              key: _formKey,
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildHeader(context),

                    Row(
                      children: [
                        Expanded(
                          child: customTextField(
                            label: "First Name",
                            context: context,
                            controller: firstNameController,
                          ),
                        ),
                        SizedBox(width: defaultPadding / 2),
                        Expanded(
                          child: customTextField(
                            label: "Last Name",
                            context: context,
                            controller: lastNameController,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: defaultPadding / 2),

                    Row(
                      children: [
                        Expanded(
                          child: customTextField(
                            label: "Email",
                            context: context,
                            controller: emailController,
                          ),
                        ),
                        SizedBox(width: defaultPadding / 2),

                        Expanded(
                          child: customTextField(
                            label: "username",
                            context: context,
                            controller: usernameController,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: defaultPadding / 2),

                    Row(
                      children: [
                        Expanded(
                          child: customTextField(
                            label: "Phone Number",
                            context: context,
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        SizedBox(width: defaultPadding / 2),

                        Expanded(
                          child: customTextField(
                            label: "Address",
                            context: context,
                            controller: addressController,
                          ),
                        ),
                      ],
                    ),

                    Spacer(),
                    InkWell(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          _submitForm();
                        }
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(
                            defaultPadding / 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Update",
                            style: Theme.of(context).textTheme.headlineMedium!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
