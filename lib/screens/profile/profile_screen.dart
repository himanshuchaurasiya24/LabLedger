import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/profile/update_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  final int userId;

  ProfileScreen({super.key, required this.userId});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDetailsProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), elevation: 0),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null) return const Center(child: Text("User not found"));

          return SingleChildScrollView(
            padding: EdgeInsets.all(defaultPadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Text(
                            user.firstName.isNotEmpty
                                ? user.firstName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user.firstName} ${user.lastName}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    ProfileField(
                      label: "Account Type",
                      value: user.isAdmin ? "Administrator" : "",
                    ),
                    ProfileField(label: "Username", value: user.username),
                    ProfileField(label: "Phone", value: user.phoneNumber),
                    ProfileField(label: "Address", value: user.address),
                    ProfileField(
                      label: "Associated Center",
                      value:
                          "${user.centerDetail.centerName}, ${user.centerDetail.address}",
                    ),

                    ProfileField(
                      label: "Center Owner",
                      value: user.centerDetail.ownerName,
                    ),
                    ProfileField(
                      label: "Owner Phone",
                      value: user.centerDetail.ownerPhone,
                    ),

                    // Update Button
                    Center(
                      child: customButton(
                        context: context,
                        formKey: _formKey,
                        ontap: () {
                          ref
                              .read(userDetailsProvider(userId).future)
                              .then((user) async {
                                if (user != null) {
                                  await Navigator.of(context)
                                      .push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              UpdateProfileScreen(user: user),
                                        ),
                                      )
                                      .then((value) {
                                        if (value == true) {
                                          ref.invalidate(
                                            userDetailsProvider(userId),
                                          );
                                        }
                                      });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Unable to load user data"),
                                    ),
                                  );
                                }
                              })
                              .catchError((e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Errorrrr: $e")),
                                );
                              });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final String? value;
  const ProfileField({super.key, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(value ?? '—', style: style),
        ],
      ),
    );
  }
}
