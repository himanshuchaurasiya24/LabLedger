import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class DoctorDetailsFormCard extends StatelessWidget {
  const DoctorDetailsFormCard({
    super.key,
    required this.color,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.hospitalController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
  });

  final Color color;
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController hospitalController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TintedContainer(
      baseColor: color,
      height: 510,
      radius: defaultRadius,
      elevationLevel: 1,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(defaultPadding * 1.5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(defaultRadius),
                topRight: Radius.circular(defaultRadius),
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
                  child: Icon(
                    Icons.medical_services_outlined,
                    color: color,
                    size: 20,
                  ),
                ),
                SizedBox(width: defaultWidth / 2),
                Text(
                  'Doctor Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: defaultHeight),
          Expanded(
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'First Name',
                            controller: firstNameController,
                            isRequired: true,
                            tintColor: color,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'First name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: defaultWidth / 2),
                        Expanded(
                          child: CustomTextField(
                            label: 'Last Name',
                            controller: lastNameController,
                            isRequired: true,
                            tintColor: color,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Last name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Hospital / Clinic Name',
                      controller: hospitalController,
                      isRequired: true,
                      tintColor: color,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Hospital/Clinic name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Email Address',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      tintColor: color,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Phone Number',
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      isRequired: true,
                      tintColor: color,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Address',
                      controller: addressController,
                      tintColor: color,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Address is required';
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
}
