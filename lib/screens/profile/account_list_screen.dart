import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/main.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/home/add_bill_screen.dart';
import 'package:labledger/screens/profile/profile_screen.dart';

class AccountListScreen extends ConsumerWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersDetailsProvider(null));

    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.95,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryFixed,
            borderRadius: BorderRadius.circular(defaultPadding / 2),
          ),
          child: Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(context),
                const SizedBox(height: 16),
                Expanded(
                  child: usersAsync.when(
                    data: (users) => _buildUserGrid(context, users, ref),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(
                      child: Text(
                        'Error: $err',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.red),
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

  Widget _buildUserGrid(
    BuildContext context,
    List<dynamic> users,
    WidgetRef ref,
  ) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return UserCard(
          user: user,
          onTap: () async {
            await navigatorKey.currentState
                ?.push(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: user.id),
                  ),
                )
                .then((_) {
                  ref.invalidate(usersDetailsProvider(null));
                });
          },
        );
      },
    );
  }
}

class UserCard extends StatelessWidget {
  final dynamic user;
  final VoidCallback? onTap; // or ValueChanged<int> if you only want to pass id

  const UserCard({super.key, required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // use the callback passed from outside
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(defaultPadding / 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Avatar + Role ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: user.isAdmin
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.2)
                          : Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                      color: user.isAdmin
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                      size: 24,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: user.isAdmin
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      user.isAdmin ? "ADMIN" : "USER",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: defaultPadding / 2),

              // --- Name ---
              Text(
                "${user.firstName} ${user.lastName}",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 2),

              // --- Email ---
              Text(
                user.email,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // --- Address ---
              Text(
                user.address,
                style: const TextStyle(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // --- Phone ---
              Row(
                children: [
                  const Icon(Icons.phone, size: 16),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      user.phoneNumber,
                      style: const TextStyle(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
