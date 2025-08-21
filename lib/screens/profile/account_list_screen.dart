import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/profile/profile_screen.dart';

class AccountListScreen extends ConsumerWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersDetailsProvider(null));

    return Scaffold(
      body: CustomCardContainer(
        xHeight: 0.95,
        xWidth: 0.7,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pageHeader(context: context, centerWidget: null),

            const SizedBox(height: 16),
            Expanded(
              child: usersAsync.when(
                data: (users) => _buildUserGrid(context, users, ref),
                loading: () => const Center(child: CircularProgressIndicator()),
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
    );
  }

  Widget _buildUserGrid(
    BuildContext context,
    List<dynamic> users,
    WidgetRef ref,
  ) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return GridCard(
          context: context,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: user.isAdmin
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                    ),
                    child: Center(
                      child: Text(
                        user.firstName[0].toUpperCase() +
                            user.lastName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ThemeData.light().scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user.firstName} ${user.lastName}",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Text(
                user.email,
                style: TextStyle(fontSize: 20),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              Text(
                user.address,
                style: const TextStyle(fontSize: 20),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              Text(
                user.phoneNumber,
                style: const TextStyle(fontSize: 20),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

class GridCard extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final Color borderColor; // make it non-nullable now
  final BuildContext context;
  final Color backgroundColor;

  GridCard({
    super.key,
    this.onTap,
    required this.child,
    Color? borderColor,
    required this.context,
    Color? backgroundColor,
  }) : borderColor =
           borderColor ??
           Theme.of(
             context,
           ).colorScheme.primary.withValues(alpha: 0.4), // fallback here
       backgroundColor = backgroundColor ?? Colors.transparent; // fallback here

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(defaultRadius),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Padding(padding: EdgeInsets.all(defaultPadding), child: child),
      ),
    );
  }
}
