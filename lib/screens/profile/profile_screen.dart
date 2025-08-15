import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/home/add_bill_screen.dart';
import 'package:labledger/screens/profile/update_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  final int userId;

  const ProfileScreen({super.key, required this.userId});

  // Outside your widget class (or as a method inside a StatefulWidget or HookWidget)
  Future<void> _handleUserTap(
    BuildContext context,
    WidgetRef ref,
    int userId,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final user = await ref.read(userDetailsProvider(userId).future);

      if (user != null) {
        final result = await navigator.push(
          MaterialPageRoute(builder: (_) => UpdateProfileScreen(user: user)),
        );

        if (result == true) {
          ref.invalidate(userDetailsProvider(userId));
        }
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Unable to load user data")),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("Errorrrr: $e")));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDetailsProvider(userId));

    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.95,
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
            child: userAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (user) {
                if (user == null) {
                  return const Center(child: Text("User not found"));
                }
                return IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildHeader(context),

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
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

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

                      Spacer(), // pushes the button to the bottom

                      InkWell(
                        onTap: () {
                          _handleUserTap(context, ref, userId);
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
                              "Update Details",
                              style: Theme.of(context).textTheme.headlineMedium!
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(value ?? '—', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
